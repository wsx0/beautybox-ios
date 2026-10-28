
import os, shutil, sys, time, json

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
SRC = os.path.expandvars(r'%LOCALAPPDATA%\Google\Chrome\User Data')
DST = os.path.join(ROOT, 'build', 'chrome_profile')

def prep():
    if os.path.exists(DST):
        shutil.rmtree(DST, ignore_errors=True)
    os.makedirs(os.path.join(DST, 'Default', 'Network'), exist_ok=True)
    pairs = [
        ('Local State', 'Local State'),
        (os.path.join('Default', 'Network', 'Cookies'), os.path.join('Default', 'Network', 'Cookies')),
        ('Default/Preferences', 'Default/Preferences'),
    ]
    for s, d in pairs:
        sp = os.path.join(SRC, s)
        dp = os.path.join(DST, d)
        if os.path.exists(sp):
            os.makedirs(os.path.dirname(dp), exist_ok=True)
            shutil.copy2(sp, dp)
            print('copied', s, os.path.getsize(dp))
        else:
            print('missing', s)

prep()

from playwright.sync_api import sync_playwright

CODE = sys.argv[1] if len(sys.argv) > 1 else '73EA-62F3'
SHOT = os.path.join(ROOT, 'build', 'shots')
os.makedirs(SHOT, exist_ok=True)

with sync_playwright() as pw:
    ctx = pw.chromium.launch_persistent_context(
        DST, channel='chrome', headless=False,
        args=['--no-first-run', '--no-default-browser-check'],
        viewport={'width': 1280, 'height': 900},
    )
    page = ctx.pages[0] if ctx.pages else ctx.new_page()
    page.goto('https://github.com/login/device', wait_until='domcontentloaded', timeout=60000)
    time.sleep(2)
    print('STEP1 url=', page.url, 'title=', page.title())
    page.screenshot(path=os.path.join(SHOT, '1_device.png'))

    # 已登录则直接是输入码页面
    body = page.inner_text('body')[:400].replace('\n', ' | ')
    print('BODY1:', body[:300])

    filled = False
    for sel in ['input[name="user_code"]', 'input#user_code', 'input[autocomplete="one-time-code"]']:
        try:
            if page.query_selector(sel):
                page.fill(sel, CODE)
                filled = True
                print('filled via', sel)
                break
        except Exception as e:
            print('fill err', sel, e)

    if not filled:
        print('NO_CODE_INPUT (可能未登录)')
        page.screenshot(path=os.path.join(SHOT, '1b_noinput.png'))
        ctx.close()
        sys.exit(3)

    for sel in ['button[type="submit"]', 'button:has-text("Continue")', 'input[type="submit"]']:
        try:
            el = page.query_selector(sel)
            if el:
                el.click()
                print('submitted via', sel)
                break
        except Exception as e:
            print('submit err', sel, e)

    page.wait_for_load_state('domcontentloaded', timeout=60000)
    time.sleep(3)
    print('STEP2 url=', page.url, 'title=', page.title())
    page.screenshot(path=os.path.join(SHOT, '2_authorize.png'))
    print('BODY2:', page.inner_text('body')[:400].replace('\n', ' | ')[:300])

    clicked = False
    for sel in ['button:has-text("Authorize")', 'button[name="authorize"]',
                'input[value="Authorize"]', 'button[type="submit"]']:
        try:
            el = page.query_selector(sel)
            if el:
                el.click()
                clicked = True
                print('authorized via', sel)
                break
        except Exception as e:
            print('auth err', sel, e)
    print('AUTHORIZE_CLICKED', clicked)
    time.sleep(4)
    print('STEP3 url=', page.url, 'title=', page.title())
    page.screenshot(path=os.path.join(SHOT, '3_result.png'))
    print('BODY3:', page.inner_text('body')[:300].replace('\n', ' | ')[:250])
    ctx.close()
print('DONE')
