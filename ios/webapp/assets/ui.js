/* 通用 UI 工具：导航栏、toast、路由跳转、列表构件 */
window.UI = (function () {
  function esc(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c];
    });
  }

  function nav(title, opt) {
    opt = opt || {};
    var back = opt.back === false ? '<span class="back"></span>'
      : '<span class="back" data-back="1">‹</span>';
    var act = opt.action ? '<span class="act" data-act="' + esc(opt.action.key) + '">' + esc(opt.action.text) + '</span>'
      : '<span class="act"></span>';
    return '<div class="nav">' + back + '<div class="ttl">' + esc(title) + '</div>' + act + '</div>';
  }

  function toast(msg) {
    var t = document.getElementById('toast');
    t.textContent = msg;
    t.classList.add('on');
    clearTimeout(toast._t);
    toast._t = setTimeout(function () { t.classList.remove('on'); }, 2200);
  }

  function go(id, param) {
    location.hash = '#/' + id + (param ? '/' + encodeURIComponent(param) : '');
  }

  function duration(sec) {
    if (!sec) return '';
    var m = Math.floor(sec / 60), s = sec % 60;
    return m + ':' + (s < 10 ? '0' + s : s);
  }

  function views(n) {
    if (n >= 10000) return (n / 10000).toFixed(1) + '万';
    return String(n || 0);
  }

  function coverStyle(w) {
    var h = w.hue || 0;
    return 'background:linear-gradient(135deg,hsl(' + h + ',42%,84%),hsl(' + ((h + 40) % 360) + ',35%,92%))';
  }

  function row(w) {
    var tags = '';
    if (w.vip) tags += '<span class="tag">VIP</span>';
    if (w.unlocked) tags += '<span class="tag" style="border-color:#2e9e4f;color:#2e9e4f">已解锁</span>';
    return '<a class="row" href="#/detail/' + encodeURIComponent(w.id) + '">' +
      '<div class="thumb" style="' + coverStyle(w) + '">' + esc(w.title.slice(0, 1)) +
      (w.duration ? '<span class="dur">' + duration(w.duration) + '</span>' : '') + '</div>' +
      '<div class="meta"><div class="h">' + tags + esc(w.title) + '</div>' +
      '<div class="s"><span>' + esc(w.author) + '</span><span>' + views(w.views) + ' 次播放</span>' +
      '<span>解锁量 ' + views(w.likes) + '</span></div></div></a>';
  }

  function cell(label, value, href) {
    return '<a class="cell" href="' + (href || '#') + '"><span>' + esc(label) + '</span>' +
      '<span class="v">' + esc(value || '') + '</span></a>';
  }

  function tabs(list, active, onclickAttr) {
    return '<div class="tabs">' + list.map(function (x, i) {
      return '<div class="t' + (i === active ? ' on' : '') + '" data-tab="' + i + '">' + esc(x) + '</div>';
    }).join('') + '</div>';
  }

  function empty(text) { return '<div class="empty">' + esc(text || '暂无数据') + '</div>'; }

  function blk() { return '<div class="blk"></div>'; }

  return { esc: esc, nav: nav, toast: toast, go: go, row: row, cell: cell, tabs: tabs,
    empty: empty, blk: blk, duration: duration, views: views, coverStyle: coverStyle };
})();

/* 底部 tabbar */
window.TABBAR = function (active) {
  var items = [
    { id: 'home', icon: '⌂', label: '首页' },
    { id: 'game', icon: '◎', label: '夺宝' },
    { id: 'chatList', icon: '✉', label: '消息' },
    { id: 'me', icon: '☺', label: '我的' }
  ];
  return '<div class="tabbar">' + items.map(function (it) {
    return '<a class="it' + (it.id === active ? ' on' : '') + '" href="#/' + it.id + '">' +
      '<i>' + it.icon + '</i>' + it.label + '</a>';
  }).join('') + '</div>';
};
