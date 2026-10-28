/* 内容域：首页 / 列表 / 搜索 / 详情 / 播放 / 评论 */
(function () {
  var S = window.SCREENS = window.SCREENS || {};
  var D = window.DEMO, A = window.API, U = window.UI;
  var TABS = D.TYPES.map(function (x) { return x.name; });
  var cur = { type: 2, page: 1 };

  S.home = {
    tab: 'home',
    title: '首页',
    render: function () {
      var works = D.works(cur.type, 14);
      return U.nav('BeautyBox', { back: false, action: { key: 'search', text: '搜索' } }) +
        U.tabs(TABS, D.TYPES.findIndex(function (x) { return x.t === cur.type; })) +
        '<div class="list" id="feed">' + works.map(U.row).join('') + '</div>' +
        '<div class="empty" id="more">上拉加载更多</div>' +
        window.TABBAR('home');
    },
    bind: function (root) {
      root.querySelectorAll('[data-tab]').forEach(function (el) {
        el.addEventListener('click', function () {
          cur.type = D.TYPES[Number(el.getAttribute('data-tab'))].t;
          window.RENDER();
        });
      });
      var act = root.querySelector('[data-act="search"]');
      if (act) act.addEventListener('click', function () { U.go('search'); });
      var more = root.querySelector('#more');
      if (more) {
        more.addEventListener('click', function () {
          cur.page += 1;
          var add = D.works(cur.type, 10);
          var box = root.querySelector('#feed');
          box.insertAdjacentHTML('beforeend', add.map(U.row).join(''));
          more.textContent = '已加载 ' + (cur.page * 10) + ' 条（演示）';
        });
      }
    }
  };

  S.list = {
    title: '列表',
    render: function (p) {
      var type = Number(p || cur.type);
      var works = D.works(type, 20);
      return U.nav('全部 · ' + (D.TYPES.filter(function (x) { return x.t === type; })[0] || {}).name) +
        '<div class="list">' + works.map(U.row).join('') + '</div>';
    }
  };

  S.search = {
    title: '搜索',
    render: function () {
      var tags = ['图集', '长视频', '胶片', '夜景', '泳池', '复古'];
      return U.nav('搜索', { action: { key: 'do', text: '搜索' } }) +
        '<div class="form"><div class="fld"><label>关键词</label>' +
        '<input id="kw" placeholder="标题 / 作者 / 标签" autocapitalize="off"></div></div>' +
        '<div class="wrap"><div class="muted" style="margin-bottom:8px">热门标签</div>' +
        '<div class="chipbox">' + tags.map(function (t) {
          return '<span class="chip" data-kw="' + t + '">' + t + '</span>';
        }).join('') + '</div></div>' +
        '<div id="result"></div>';
    },
    bind: function (root) {
      function run(kw) {
        A.call(A.ROUTES.search, { query: { name: kw } }, function () {
          return { list: D.works(cur.type, 6) };
        }).then(function (res) {
          var list = (res && (res.list || res.data)) || [];
          root.querySelector('#result').innerHTML = '<div class="list">' +
            (list.length ? list.map(U.row).join('') : U.empty('没有匹配结果')) + '</div>';
        });
      }
      root.querySelectorAll('[data-kw]').forEach(function (c) {
        c.addEventListener('click', function () {
          root.querySelector('#kw').value = c.getAttribute('data-kw');
          run(c.getAttribute('data-kw'));
        });
      });
      var act = root.querySelector('[data-act="do"]');
      if (act) act.addEventListener('click', function () { run(root.querySelector('#kw').value); });
    }
  };

  S.detail = {
    title: '详情',
    render: function (id) {
      var w = D.works(cur.type, 30).filter(function (x) { return x.id === id; })[0] || D.works(cur.type, 1)[0];
      window.__cur = w;
      return U.nav('详情', { action: { key: 'share', text: '分享' } }) +
        '<div class="cover" style="' + U.coverStyle(w) + '"><span class="play">▶</span></div>' +
        '<div class="info"><h2>' + U.esc(w.title) + '</h2>' +
        '<div class="sub"><span>作者 ' + U.esc(w.author) + '</span>' +
        '<span>播放 ' + U.views(w.views) + '</span><span>收藏量 ' + U.views(w.likes) + '</span>' +
        '<span>解锁量 ' + U.views(w.likes) + '</span><span>匹配度 ' + (85 + (w.views % 12)) + '%</span></div></div>' +
        U.blk() +
        '<div class="ops"><button class="btn" id="play">播放 / 解锁 ' + w.score + ' 积分</button>' +
        '<button class="btn ghost" id="fav">收藏</button></div>' +
        U.blk() +
        '<a class="cell" href="#/comments/' + encodeURIComponent(w.id) + '"><span>评论</span><span class="v">128 条</span></a>' +
        U.cell('举报有奖', '重复视频 / 违规', '#/help') +
        U.cell('积分不够？去兑换', '', '#/shop') +
        '<div class="wrap muted">接口：' + A.unlock('media') + ' · ' + A.ROUTES.boxCollection + '</div>';
    },
    bind: function (root) {
      var w = window.__cur;
      root.querySelector('#play').addEventListener('click', function () {
        A.call(A.unlock('video'), { body: { id: w.id } }, function () { return { ok: 1 }; }).then(function () {
          U.toast('已扣除 ' + w.score + ' 积分并解锁（演示）');
          window.GO('player', w.id);
        });
      });
      root.querySelector('#fav').addEventListener('click', function () {
        A.call(A.ROUTES.boxCollection, { body: { id: w.id } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已收藏'); });
      });
      var act = root.querySelector('[data-act="share"]');
      if (act) act.addEventListener('click', function () { U.toast('分享链接已复制（演示）'); });
    }
  };

  S.player = {
    title: '播放',
    render: function (id) {
      var w = window.__cur || {};
      return '<div class="sheet">' + U.nav('播放', { action: { key: 'close', text: '关闭' } }) +
        '<div class="stage"><div class="empty" style="color:#888">片源地址需后端返回<br>当前为演示数据<br><br>' +
        U.esc(w.title || '') + '</div></div></div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="close"]');
      if (act) act.addEventListener('click', function () { history.back(); });
    }
  };

  S.comments = {
    title: '评论',
    render: function () {
      var list = [
        { u: '用户2031', t: '画质不错，已解锁', t2: '2 分钟前' },
        { u: '用户7781', t: '这个系列还有后续吗', t2: '1 小时前' },
        { u: '用户1187', t: '举报了一条重复视频', t2: '昨天' }
      ];
      return U.nav('评论 128') +
        list.map(function (c) {
          return '<div class="row" style="display:block"><div style="font-size:13px;color:#888">' +
            U.esc(c.u) + ' · ' + U.esc(c.t2) + '</div><div style="margin-top:4px">' + U.esc(c.t) + '</div></div>';
        }).join('') +
        '<div class="wrap"><div class="fld"><input id="cm" placeholder="说点什么…"><span class="code" id="send">发送</span></div></div>';
    },
    bind: function (root) {
      root.querySelector('#send').addEventListener('click', function () {
        var v = root.querySelector('#cm').value.trim();
        if (!v) { U.toast('内容为空'); return; }
        A.call(A.ROUTES.reportPost, { body: { content: v } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已提交'); root.querySelector('#cm').value = ''; });
      });
    }
  };
})();
