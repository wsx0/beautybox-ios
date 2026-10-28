/* 路由与启动 */
(function () {
  var S = window.SCREENS, U = window.UI;
  var root = null;

  function parse() {
    var h = (location.hash || '').replace(/^#\/?/, '');
    if (!h) return { id: 'home', param: '' };
    var parts = h.split('/');
    return { id: parts[0] || 'home', param: decodeURIComponent(parts[1] || '') };
  }

  window.RENDER = function () {
    var r = parse();
    var screen = S[r.id] || S.home;
    document.title = (screen.title || 'BeautyBox');
    root.innerHTML = screen.render(r.param);
    if (screen.bind) {
      try { screen.bind(root, r.param); } catch (e) { console.error(e); }
    }
    window.scrollTo(0, 0);
  };

  window.GO = U.go;

  function bindGlobal() {
    document.addEventListener('click', function (e) {
      var back = e.target.closest ? e.target.closest('[data-back]') : null;
      if (back) {
        if (history.length > 1) history.back();
        else location.hash = '#/home';
      }
    });
    window.addEventListener('hashchange', window.RENDER);
  }

  function boot() {
    root = document.getElementById('app');
    bindGlobal();
    if (!location.hash) location.hash = '#/home';
    window.RENDER();
    if ('serviceWorker' in navigator) {
      var secure = location.protocol === 'https:' || location.hostname === 'localhost' || location.hostname === '127.0.0.1';
      if (secure) navigator.serviceWorker.register('sw.js').catch(function () {});
    }
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', boot);
  else boot();
})();
