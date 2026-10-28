
import os, time
from playwright.sync_api import sync_playwright
with sync_playwright() as pw:
    b = pw.chromium.launch(channel='chrome', headless=True)
    p = b.new_page(viewport={'width': 390, 'height': 844})
    p.goto('http://127.0.0.1:8088/index.html#/more', wait_until='networkidle', timeout=20000)
    time.sleep(1.0)
    n = p.eval_on_selector_all('[data-route]', 'e => e.length')
    print('more_actions=%d' % n)
    b.close()
