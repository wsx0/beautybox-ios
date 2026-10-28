/* 无浏览器环境下的渲染冒烟测试：加载全部模块，逐屏调用 render() 与 bind() */
const fs = require('fs');
const path = require('path');
const vm = require('vm');

const ROOT = process.argv[2];
const files = ['assets/data.js', 'assets/api.js', 'assets/ui.js', 'assets/screens1.js', 'assets/screens2.js', 'assets/screens3.js', 'assets/screens4.js'];

function fakeEl() {
  const el = {
    innerHTML: '', textContent: '', value: '', style: {}, dataset: {},
    classList: { add() {}, remove() {}, toggle() {} },
    addEventListener() {}, setAttribute() {}, getAttribute() { return null; },
    querySelector() { return fakeEl(); }, querySelectorAll() { return []; },
    insertAdjacentHTML() {}, appendChild() {}, closest() { return null; }
  };
  return el;
}

const store = {};
const sandbox = {
  console, setTimeout, clearTimeout, Promise, Date, Math, JSON,
  localStorage: { getItem: k => (k in store ? store[k] : null), setItem: (k, v) => { store[k] = String(v); }, removeItem: k => { delete store[k]; } },
  location: { hash: '#/home', protocol: 'http:', hostname: '127.0.0.1', href: 'http://127.0.0.1/' },
  navigator: { serviceWorker: null, userAgent: 'node' },
  document: { getElementById: () => fakeEl(), addEventListener() {}, readyState: 'complete', title: '' },
  fetch: () => Promise.reject(new Error('offline')),
  history: { length: 2, back() {} },
  scrollTo() {}
};
sandbox.window = sandbox;
vm.createContext(sandbox);

for (const f of files) {
  const code = fs.readFileSync(path.join(ROOT, f), 'utf8');
  vm.runInContext(code, sandbox, { filename: f });
}

const U = sandbox.UI;
const screens = sandbox.SCREENS;
const ids = Object.keys(screens).sort();
const params = {
  detail: '2-3', comments: '2-3', player: '2-3', tradeDetail: 't1', chat: 'c1',
  audit: '', profile: '1001', list: '2', card: '', settings: '', shop: ''
};

let bad = 0;
const known = new Set(ids);
known.add('home');
const links = new Set();

for (const id of ids) {
  const s = screens[id];
  let html = '';
  try {
    html = s.render(params[id] || '');
  } catch (e) {
    console.log('RENDER-FAIL ' + id + ' :: ' + e.message);
    bad++;
    continue;
  }
  if (!html || html.length < 40) { console.log('EMPTY ' + id); bad++; continue; }
  if (html.indexOf('undefined') >= 0) { console.log('UNDEF-IN-OUTPUT ' + id); bad++; }
  // 收集所有站内链接
  const re = /href="#\/([A-Za-z0-9_]+)/g;
  let m;
  while ((m = re.exec(html)) !== null) links.add(m[1]);
  // bind 冒烟
  try {
    const root = fakeEl();
    if (s.bind) s.bind(root, params[id] || '');
  } catch (e) {
    console.log('BIND-FAIL ' + id + ' :: ' + e.message);
    bad++;
  }
}

const missing = [...links].filter(x => !known.has(x));
console.log('screens=' + ids.length + '  links=' + links.size + '  broken=' + (missing.length ? missing.join(',') : 'none'));
console.log('ids: ' + ids.join(' '));
console.log(bad === 0 ? 'SMOKE OK' : ('SMOKE FAIL ' + bad));
process.exit(bad === 0 && missing.length === 0 ? 0 : 1);
