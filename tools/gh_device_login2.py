
import os, sys, time, json, urllib.request

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
SHOT = os.path.join(ROOT, 'build', 'shots')
os.makedirs(SHOT, exist_ok=True)
CODE = sys.argv[1] if len(sys.argv) > 1 else '73EA-62F3'

from playwright.sync_api import sync_playwright

def find_page(browser):
    for c in browser.contexts:
        for p in c.pages:
            if 'github.com' in (p.url or ''):
                return p
    for c in browser.contexts:
        if c.pages:
            return c.pages[0]
    return None

with sync_playwright() as pw:
    browser = pw.chromium.connect_over_cdp('http://127.0.0.1:9222', timeout=30000)
    page = find_page(browser)
    if page is None:
        print('NO_PAGE'); sys.exit(4)
    page.bring_to_front()
    print('PAGE', page.url, '|', page.title())

    if '/login' in page.url:
        page.goto('https://github.com/login/device', wait_until='domcontentloaded', timeout=60000)
        time.sleep(2)
    print('URL', page.url)
    body = page.inner_text('body')[:250].replace('\n', ' | ')
    print('BODY', body)

    el = page.query_selector('input[name="user_code"]') or page.query_selector('input#user_code')
    if not el:
        page.screenshot(path=os.path.join(SHOT, 'a_noinput.png'))
        print('NO_CODE_INPUT')
        sys.exit(3)
    el.fill(CODE)
    print('filled code')
    btn = page.query_selector('button[type="submit"]') or page.query_selector('button:has-text("Continue")')
    if btn:
        btn.click()
    else:
        el.press('Enter')
    page.wait_for_load_state('domcontentloaded', timeout=60000)
    time.sleep(3)
    print('AFTER_SUBMIT', page.url, '|', page.title())
    page.screenshot(path=os.path.join(SHOT, 'b_authorize.png'))
    print('BODY2', page.inner_text('body')[:400].replace('\n', ' | ')[:320])

    clicked = False
    for sel in ['button:has-text("Authorize")', 'button[name="authorize"]', 'input[value="Authorize"]']:
        b = page.query_selector(sel)
        if b:
            b.click(); clicked = True; print('clicked', sel); break
    print('AUTHORIZED_CLICK', clicked)
    time.sleep(4)
    print('FINAL', page.url, '|', page.title())
    page.screenshot(path=os.path.join(SHOT, 'c_result.png'))
    print('BODY3', page.inner_text('body')[:300].replace('\n', ' | ')[:250])
print('DONE')
