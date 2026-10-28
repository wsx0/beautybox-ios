
import os, time, sys
from playwright.sync_api import sync_playwright

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
SHOT = os.path.join(ROOT, 'build', 'shots')
os.makedirs(SHOT, exist_ok=True)

with sync_playwright() as pw:
    b = pw.chromium.launch(channel='chrome', headless=True)
    page = b.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
    page.goto('http://127.0.0.1:8088/index.html', wait_until='networkidle', timeout=30000)
    time.sleep(1.5)
    page.screenshot(path=os.path.join(SHOT, 'pwa_home.png'))
    imgs = page.eval_on_selector_all('img', 'els => els.map(e => ({src: e.getAttribute("src"), w: e.naturalWidth, h: e.naturalHeight}))')
    print('IMG COUNT', len(imgs))
    for i in imgs[:4]:
        print('  ', i)
    # 进入详情
    page.click('.row')
    time.sleep(1.2)
    page.screenshot(path=os.path.join(SHOT, 'pwa_detail.png'))
    # 进播放
    page.click('#play')
    time.sleep(1.5)
    page.screenshot(path=os.path.join(SHOT, 'pwa_player.png'))
    v = page.eval_on_selector('video', 'e => ({src: e.getAttribute("src"), rs: e.readyState, d: e.duration, w: e.videoWidth, h: e.videoHeight, err: e.error ? e.error.code : null})')
    print('VIDEO', v)
    b.close()
print('DONE')
