
import os, sys, time

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
SHOT = os.path.join(ROOT, 'build', 'shots')
os.makedirs(SHOT, exist_ok=True)
CODE = '73EA-62F3'
PROFILE = os.path.expandvars(r'%LOCALAPPDATA%\Google\Chrome\User Data')

from playwright.sync_api import sync_playwright

with sync_playwright() as pw:
    ctx = pw.chromium.launch_persistent_context(
        PROFILE, channel='chrome', headless=False,
        args=['--no-first-run', '--no-default-browser-check', '--restore-last-session=false'],
        viewport={'width': 1280, 'height': 900},
    )
    page = ctx.pages[0] if ctx.pages else ctx.new_page()
    page.goto('https://github.com/login/device', wait_until='domcontentloaded', timeout=60000)
    time.sleep(2)
    print('URL', page.url)
    print('TITLE', page.title())
    print('BODY', page.inner_text('body')[:200].replace('\n', ' | '))
    page.screenshot(path=os.path.join(SHOT, 'r1.png'))

    el = page.query_selector('input[name="user_code"]')
    if not el:
        print('NO_CODE_INPUT -> 仍未登录')
        ctx.close(); sys.exit(3)
    el.fill(CODE)
    btn = page.query_selector('button[type="submit"]')
    (btn.click() if btn else el.press('Enter'))
    page.wait_for_load_state('domcontentloaded', timeout=60000)
    time.sleep(3)
    print('AFTER', page.url, '|', page.title())
    page.screenshot(path=os.path.join(SHOT, 'r2.png'))
    print('BODY2', page.inner_text('body')[:350].replace('\n', ' | ')[:300])

    done = False
    for sel in ['button:has-text("Authorize")', 'button[name="authorize"]', 'input[value="Authorize"]']:
        b = page.query_selector(sel)
        if b:
            b.click(); done = True; print('click', sel); break
    print('CLICKED', done)
    time.sleep(4)
    print('FINAL', page.url, '|', page.title())
    print('BODY3', page.inner_text('body')[:250].replace('\n', ' | ')[:200])
    page.screenshot(path=os.path.join(SHOT, 'r3.png'))
    ctx.close()
print('DONE')
