/* 用户域：我的 / 我的作品 / 收藏 / 上传 / 审核 / 他人主页 */
(function () {
  var S = window.SCREENS = window.SCREENS || {};
  var D = window.DEMO, A = window.API, U = window.UI;

  var user = { name: '未登录', score: 0, gold: 0, level: 'Lv.0', vip: '' };

  S.me = {
    tab: 'me',
    title: '我的',
    render: function () {
      return U.nav('我的', { back: false, action: { key: 'setting', text: '设置' } }) +
        '<div class="me-head"><div class="av">B</div><div>' +
        '<div class="nm">' + U.esc(user.name) + (user.vip ? '<span class="lv">VIP</span>' : '') + '</div>' +
        '<div class="st">' + U.esc(user.level) + ' · 签到可加积分</div></div>' +
        '<button class="btn small" style="margin-left:auto" id="login">登录</button></div>' +
        '<div class="me-nums"><div><b>' + user.score + '</b><span>积分</span></div>' +
        '<div><b>' + user.gold + '</b><span>金币</span></div>' +
        '<div><b>0</b><span>关注</span></div><div><b>0</b><span>粉丝</span></div></div>' +
        U.blk() +
        U.cell('我的作品', '审核 / 已发布', '#/works') +
        U.cell('我的收藏', '', '#/collect') +
        U.cell('积分明细', '', '#/scoreLog') +
        U.cell('等级与经验', '', '#/level') +
        U.cell('卡密', '', '#/card') +
        U.cell('交易中心', '买家 / 卖家', '#/trade') +
        U.cell('上传作品', '', '#/upload') +
        U.blk() +
        U.cell('积分商城', '', '#/shop') +
        U.cell('充值', 'TRC20-USDT', '#/recharge') +
        U.cell('提现', '', '#/withdraw') +
        U.blk() +
        U.cell('设备与安全', '', '#/device') +
        U.cell('支付方式', '', '#/payment') +
        U.cell('帮助与反馈', '', '#/help') +
        U.cell('设置', '', '#/settings') +
        U.cell('更多功能', '全部接口', '#/more') +
        window.TABBAR('me');
    },
    bind: function (root) {
      var b = root.querySelector('#login');
      if (b) b.addEventListener('click', function () { U.go('login'); });
      var act = root.querySelector('[data-act="setting"]');
      if (act) act.addEventListener('click', function () { U.go('settings'); });
      A.call(A.ROUTES.userStatus, { query: { id: '0' } }, function () {
        return { nickname: '演示用户', score: 1200, gold: 30, level: 'Lv.3', vip: '2027-01-01' };
      }).then(function (u) {
        user.name = u.nickname || u.userName || '演示用户';
        user.score = u.score || u.integral || 1200;
        user.gold = u.gold || u.coin || 30;
        user.level = u.level || 'Lv.3';
        user.vip = u.vipExpire || '';
      });
    }
  };

  S.works = {
    title: '我的作品',
    render: function () {
      var rows = [
        { t: '夜航船 · 图集 12P', st: '已发布', c: '#2e9e4f' },
        { t: '旧城摄影 · 短视频 06', st: '审核中', c: '#e6a23c' },
        { t: '天台落日 · 长视频', st: '未通过', c: '#aa0000' }
      ];
      return U.nav('我的作品', { action: { key: 'new', text: '上传' } }) +
        rows.map(function (r) {
          return '<div class="row" style="display:block"><div style="display:flex;justify-content:space-between">' +
            '<span>' + U.esc(r.t) + '</span><span style="color:' + r.c + ';font-size:12px">' + r.st + '</span></div>' +
            '<div class="muted" style="margin-top:6px">播放 0 · 解锁 0 · <a href="#/audit" class="red">查看审核</a></div></div>';
        }).join('') + '<div class="wrap muted">接口：' + A.ROUTES.reportAuditShow + ' · ' + A.ROUTES.boxItems + '</div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="new"]');
      if (act) act.addEventListener('click', function () { U.go('upload'); });
    }
  };

  S.collect = {
    title: '我的收藏',
    render: function () {
      return U.nav('我的收藏') + '<div class="list">' + D.works(2, 6).map(U.row).join('') + '</div>';
    }
  };

  S.profile = {
    title: '用户主页',
    render: function (id) {
      return U.nav('用户 ' + (id || ''));
    }
  };

  S.upload = {
    title: '上传作品',
    render: function () {
      var types = D.TYPES.map(function (x) {
        return '<span class="chip" data-t="' + x.t + '">' + x.name + '</span>';
      }).join('');
      return U.nav('上传作品') +
        '<div class="form">' +
        '<div class="fld"><label>文件</label><input id="file" placeholder="点击选择视频 / 图片" readonly></div>' +
        '<div class="fld"><label>标题</label><input id="title" placeholder="不超过 40 字"></div>' +
        '<div class="fld"><label>简介</label><input id="desc" placeholder="内容介绍"></div>' +
        '<div class="fld"><label>类型</label><div style="flex:1"></div></div>' +
        '<div class="chipbox" style="padding:0 0 12px">' + types + '</div>' +
        '<div class="fld"><label>解锁积分</label><input id="score" type="number" placeholder="10" inputmode="numeric"></div>' +
        '</div>' +
        '<div class="wrap"><button class="btn" id="submit">提交审核</button>' +
        '<p class="muted">提交后进入审核队列；被驳回可在「审核」里申诉。接口：' + A.ROUTES.reportNew + '</p></div>';
    },
    bind: function (root) {
      var picked = 2;
      root.querySelectorAll('[data-t]').forEach(function (c) {
        c.addEventListener('click', function () {
          root.querySelectorAll('[data-t]').forEach(function (x) { x.classList.remove('on'); });
          c.classList.add('on');
          picked = Number(c.getAttribute('data-t'));
        });
      });
      root.querySelector('#file').addEventListener('click', function (e) {
        e.target.value = 'IMG_' + Date.now() + '.jpg（演示）';
      });
      root.querySelector('#submit').addEventListener('click', function () {
        var t = root.querySelector('#title').value.trim();
        if (!t) { U.toast('请填标题'); return; }
        A.call(A.ROUTES.reportNew, {
          body: { title: t, type: picked, desc: root.querySelector('#desc').value, score: root.querySelector('#score').value }
        }, function () { return { ok: 1, auditId: 'a1' }; }).then(function () {
          U.toast('已提交，审核中');
          U.go('works');
        });
      });
    }
  };

  S.audit = {
    title: '审核 / 申诉',
    render: function () {
      return U.nav('审核详情') +
        '<div class="card"><div style="font-weight:600">旧城摄影 · 短视频 06</div>' +
        '<div class="muted" style="margin-top:6px">状态：审核中 · 提交时间 2026-10-28 10:12</div>' +
        '<div class="muted" style="margin-top:6px">审核要点：时长、清晰度、是否重复</div></div>' +
        '<div class="card"><div style="font-weight:600">天台落日 · 长视频</div>' +
        '<div class="muted" style="margin-top:6px;color:#aa0000">未通过：画面重复度高</div>' +
        '<button class="btn ghost small" style="margin-top:10px" id="appeal">发起申诉</button></div>' +
        '<div class="wrap muted">接口：' + A.ROUTES.reportAudit + ' · ' + A.ROUTES.reportAppeal + '</div>';
    },
    bind: function (root) {
      root.querySelector('#appeal').addEventListener('click', function () {
        A.call(A.ROUTES.reportAppeal, { body: { reason: '重复判定有误' } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('申诉已提交'); });
      });
    }
  };
})();
