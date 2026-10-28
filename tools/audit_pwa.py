
import os, time, json
from playwright.sync_api import sync_playwright

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
SHOT = os.path.join(ROOT, 'build', 'shots')
os.makedirs(SHOT, exist_ok=True)
BASE = 'http://127.0.0.1:8088/index.html'
errors = []

with sync_playwright() as pw:
    b = pw.chromium.launch(channel='chrome', headless=True)
    page = b.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2)
    page.on('console', lambda m: errors.append('console:' + m.type + ':' + m.text[:120]) if m.type == 'error' else None)
    page.on('pageerror', lambda e: errors.append('pageerror:' + str(e)[:160]))

    page.goto(BASE, wait_until='networkidle', timeout=30000)
    time.sleep(1.2)
    rep = {}
    rep['home_rows'] = page.eval_on_selector_all('.row', 'e => e.length')
    rep['home_imgs'] = page.eval_on_selector_all('.thumb img', 'e => e.length')
    rep['first_img'] = page.eval_on_selector('.thumb img', 'e => ({src: e.getAttribute("src"), nw: e.naturalWidth, nh: e.naturalHeight})')
    page.screenshot(path=os.path.join(SHOT, 'audit_home.png'))

    page.click('.tabs .t:nth-child(3)')
    time.sleep(1.0)
    rep['cat3_rows'] = page.eval_on_selector_all('.row', 'e => e.length')
    rep['cat3_img'] = page.eval_on_selector('.thumb img', 'e => e.getAttribute("src")')

    page.goto(BASE + '#/home', wait_until='networkidle'); time.sleep(0.8)
    page.click('.row'); time.sleep(1.0)
    rep['detail_cover'] = page.eval_on_selector('.cover', 'e => getComputedStyle(e).backgroundImage.slice(0, 70)')
    page.screenshot(path=os.path.join(SHOT, 'audit_detail.png'))
    page.click('#play'); time.sleep(1.8)
    rep['video'] = page.eval_on_selector('video', 'e => ({rs: e.readyState, dur: e.duration, w: e.videoWidth, h: e.videoHeight, err: e.error && e.error.code, paused: e.paused})')
    page.screenshot(path=os.path.join(SHOT, 'audit_player.png'))

    for name, hid in [('game', '#/game'), ('chatList', '#/chatList'), ('me', '#/me'), ('more', '#/more'), ('shop', '#/shop'), ('trade', '#/trade')]:
        page.goto(BASE + hid, wait_until='networkidle'); time.sleep(0.6)
        rep['page_' + name] = page.eval_on_selector('#app', 'e => e.innerText.replace(/\\s+/g," ").slice(0,60)')
        page.screenshot(path=os.path.join(SHOT, 'audit_' + name + '.png'))
    rep['more_actions'] = page.eval_on_selector_all('[data-route]', 'e => e.length')
    b.close()

out = os.path.join(ROOT, 'build', 'audit.json')
open(out, 'w', encoding='utf-8').write(json.dumps(rep, ensure_ascii=False, indent=1))
print('AUDIT_WRITTEN', out)
print('rows=%s imgs=%s video_rs=%s video_dur=%s errs=%s more=%s' % (
    rep.get('home_rows'), rep.get('home_imgs'),
    (rep.get('video') or {}).get('rs'), (rep.get('video') or {}).get('dur'),
    len(errors), rep.get('more_actions')))
for e in errors[:5]:
    print('ERR', e.encode('ascii', 'replace').decode('ascii'))
