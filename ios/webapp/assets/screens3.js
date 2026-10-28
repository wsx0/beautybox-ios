/* 交易 / 资金 / 夺宝 / 消息 / 设置 / 认证 */
(function () {
  var S = window.SCREENS = window.SCREENS || {};
  var D = window.DEMO, A = window.API, U = window.UI;

  S.trade = {
    title: '交易中心',
    render: function () {
      return U.nav('交易中心', { action: { key: 'new', text: '挂单' } }) +
        '<div class="tabs"><div class="t on">在售</div><div class="t">我买到的</div><div class="t">我卖出的</div></div>' +
        D.trades.map(function (t) {
          return '<a class="row" href="#/tradeDetail/' + encodeURIComponent(t.id) + '">' +
            '<div class="thumb" style="background:#f0f0f0;color:#bbb">¥</div>' +
            '<div class="meta"><div class="h">' + U.esc(t.title) + '</div>' +
            '<div class="s"><span>' + U.esc(t.seller) + '</span><span>' + t.price + ' 积分</span>' +
            '<span>' + U.esc(t.state) + '</span><span>' + U.esc(t.time) + '</span></div></div></a>';
        }).join('') +
        '<div class="wrap muted">挂单 10 分钟后才能取消；取消会影响诚信值。接口：' + A.ROUTES.transactionLoad + '</div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="new"]');
      if (act) act.addEventListener('click', function () { U.toast('挂单入口（演示）：' + A.ROUTES.transactionSellerNew); });
    }
  };

  S.tradeDetail = {
    title: '交易详情',
    render: function (id) {
      var t = D.trades.filter(function (x) { return x.id === id; })[0] || D.trades[0];
      return U.nav('交易详情') +
        '<div class="card"><div style="font-size:16px;font-weight:600">' + U.esc(t.title) + '</div>' +
        '<div class="muted" style="margin-top:8px">卖家 ' + U.esc(t.seller) + ' · 价格 ' + t.price + ' 积分</div>' +
        '<div class="muted" style="margin-top:4px">下单：' + U.esc(t.time) + '</div></div>' +
        '<div class="card"><div style="font-weight:600">交易须知</div>' +
        '<div class="muted" style="margin-top:6px">1. 挂单 10 分钟后才能取消；<br>2. 取消会影响诚信值，多次取消可能导致取消数字货币权限；<br>3. 纠纷可发起申诉。</div></div>' +
        '<div class="wrap"><button class="btn" id="buy">立即购买</button>' +
        '<button class="btn line" style="margin-top:8px" id="cancel">取消交易</button>' +
        '<button class="btn line" style="margin-top:8px" id="dispute">发起申诉</button></div>';
    },
    bind: function (root) {
      var id = location.hash.split('/')[2] || '';
      root.querySelector('#buy').addEventListener('click', function () {
        A.call(A.ROUTES.transactionBuyerPlace, { body: { id: id } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已下单，等待付款'); });
      });
      root.querySelector('#cancel').addEventListener('click', function () {
        A.call(A.ROUTES.transactionBuyerCancel, { body: { id: id } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已取消（可能影响诚信值）'); });
      });
      root.querySelector('#dispute').addEventListener('click', function () {
        A.call(A.ROUTES.transactionDispute, { body: { id: id } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('申诉已提交'); });
      });
    }
  };

  S.shop = {
    title: '积分商城',
    render: function () {
      return U.nav('积分商城') +
        '<div class="tabs"><div class="t on">兑换注册码</div><div class="t">积分兑换</div><div class="t">登录值兑换</div></div>' +
        D.shop.map(function (g) {
          return '<div class="cell"><span>' + U.esc(g.name) + '</span>' +
            '<span class="v"><button class="btn small" data-g="' + g.id + '" data-s="' + g.score + '">' +
            g.score + ' 积分兑换</button></span></div>';
        }).join('') +
        '<div class="wrap"><div class="card"><div style="font-weight:600">兑换说明</div>' +
        '<div class="muted" style="margin-top:6px">注册码有效期 7/30 天，兑换后不可退；积分不够请先充值或做任务。</div></div></div>';
    },
    bind: function (root) {
      root.querySelectorAll('[data-g]').forEach(function (b) {
        b.addEventListener('click', function () {
          A.call(A.ROUTES.shopScoreList, { query: { id: b.getAttribute('data-g') } }, function () { return { ok: 1 }; })
            .then(function () { U.toast('兑换成功，注册码已发放（演示）'); });
        });
      });
    }
  };

  S.recharge = {
    title: '充值',
    render: function () {
      return U.nav('充值') +
        '<div class="form">' +
        '<div class="fld"><label>数量</label><input id="amt" type="number" placeholder="100" inputmode="numeric"></div>' +
        '<div class="fld"><label>方式</label><select id="ch"><option>TRC20-USDT</option><option>卡密兑换</option></select></div>' +
        '</div>' +
        '<div class="card" style="margin:0 12px"><div style="font-weight:600">USDT(泰达币)钱包地址</div>' +
        '<div class="muted" style="margin-top:6px;word-break:break-all">Txxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</div>' +
        '<div class="muted" style="margin-top:6px">请保存钱包图片到相册以便识别；3 分钟内只能查询一次。</div></div>' +
        '<div class="wrap"><button class="btn" id="go">我已支付，查询到账</button>' +
        '<p class="muted">接口：' + A.ROUTES.shopScoreRecharge + ' · ' + A.ROUTES.tron + '</p></div>';
    },
    bind: function (root) {
      root.querySelector('#go').addEventListener('click', function () {
        A.call(A.ROUTES.shopScoreRechargeStatus, {}, function () { return { ok: 1 }; })
          .then(function () { U.toast('系统未查到到账信息，请稍后再试'); });
      });
    }
  };

  S.withdraw = {
    title: '提现',
    render: function () {
      return U.nav('提现') +
        '<div class="form">' +
        '<div class="fld"><label>积分</label><input id="amt" type="number" placeholder="最小 100" inputmode="numeric"></div>' +
        '<div class="fld"><label>地址</label><input id="addr" placeholder="TRC20-USDT 地址"></div>' +
        '</div>' +
        '<div class="wrap"><button class="btn" id="go">提交提现</button>' +
        '<p class="muted">请输入正确的 TRC20-USDT 地址；提现审核通过后到账。接口：' + A.ROUTES.shopScoreWithdraw + '</p></div>';
    },
    bind: function (root) {
      root.querySelector('#go').addEventListener('click', function () {
        var addr = root.querySelector('#addr').value.trim();
        if (!/^T[1-9A-HJ-NP-Za-km-z]{20,}$/.test(addr)) { U.toast('请输入正确的 TRC20-USDT 地址'); return; }
        A.call(A.ROUTES.shopScoreWithdraw, { body: { addr: addr, amount: root.querySelector('#amt').value } },
          function () { return { ok: 1 }; }).then(function () { U.toast('提现申请已提交'); });
      });
    }
  };

  S.scoreLog = {
    title: '积分明细',
    render: function () {
      return U.nav('积分明细') + D.scores.map(function (s) {
        return '<div class="cell"><span>' + U.esc(s.title) + '<div class="muted">' + U.esc(s.time) + '</div></span>' +
          '<span class="v" style="color:' + (s.value < 0 ? '#aa0000' : '#2e9e4f') + '">' +
          (s.value > 0 ? '+' : '') + s.value + '</span></div>';
      }).join('');
    }
  };

  S.game = {
    tab: 'game',
    title: '夺宝',
    render: function () {
      var last = D.issues[0];
      return U.nav('夺宝', { back: false }) +
        '<div class="card" style="margin:12px"><div class="muted">最新期号</div>' +
        '<div style="font-size:18px;font-weight:600;margin:6px 0">' + last.id + '</div>' +
        '<div>' + last.digits.map(function (d) { return '<span class="ball">' + d + '</span>'; }).join('') +
        '<span class="muted" style="margin-left:6px">和值 ' + last.sum + '</span></div>' +
        '<div class="muted" style="margin-top:8px">开奖时间 ' + last.open + '</div></div>' +
        '<div class="wrap"><div class="muted" style="margin-bottom:8px">投注玩法</div>' +
        '<div class="chipbox">' + ['直选3-和值', '直选2-和值', '组选3', '组选6', '个位'].map(function (x, i) {
          return '<span class="chip' + (i === 0 ? ' on' : '') + '">' + x + '</span>';
        }).join('') + '</div>' +
        '<div class="fld" style="margin-top:10px"><label>金币/注</label><input id="bet" type="number" value="10" inputmode="numeric"></div>' +
        '<button class="btn" style="margin-top:12px" id="go">立即夺宝</button>' +
        '<a class="cell" href="#/gameRecord" style="margin-top:12px;background:transparent;border:0;padding-left:0">投注记录 ›</a>' +
        '</div>' + window.TABBAR('game');
    },
    bind: function (root) {
      root.querySelectorAll('.chip').forEach(function (c) {
        c.addEventListener('click', function () {
          root.querySelectorAll('.chip').forEach(function (x) { x.classList.remove('on'); });
          c.classList.add('on');
        });
      });
      root.querySelector('#go').addEventListener('click', function () {
        U.toast('本期已封盘 / 投注成功（演示）');
      });
    }
  };

  S.gameRecord = {
    title: '投注记录',
    render: function () {
      return U.nav('投注记录') + D.issues.slice(0, 8).map(function (i) {
        return '<div class="issue"><span>' + i.id + '</span><span>' + i.digits.join(' ') + '</span>' +
          '<span class="muted">已开奖</span></div>';
      }).join('');
    }
  };

  S.chatList = {
    tab: 'chatList',
    title: '消息',
    render: function () {
      return U.nav('消息', { back: false, action: { key: 'notice', text: '公告' } }) +
        D.chats.map(function (c) {
          return '<a class="cell" href="#/chat/' + encodeURIComponent(c.id) + '">' +
            '<span>' + U.esc(c.name) + '<div class="muted">' + U.esc(c.last) + '</div></span>' +
            '<span class="v">' + U.esc(c.time) + (c.unread ? ' · <b class="red">' + c.unread + '</b>' : '') + '</span></a>';
        }).join('') + window.TABBAR('chatList');
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="notice"]');
      if (act) act.addEventListener('click', function () { U.go('notice'); });
    }
  };

  S.chat = {
    title: '会话',
    render: function (id) {
      var c = D.chats.filter(function (x) { return x.id === id; })[0] || D.chats[0];
      return U.nav(c.name, { action: { key: 'report', text: '举报' } }) +
        '<div class="wrap" style="min-height:60vh">' +
        '<div class="card" style="max-width:78%;margin-left:auto;background:#fff5f5">你好，这个作品还在吗？</div>' +
        '<div class="card" style="max-width:78%">在的，30 积分解锁</div>' +
        '</div>' +
        '<div class="form"><div class="fld"><input id="msg" placeholder="输入消息"><span class="code" id="send">发送</span></div></div>';
    },
    bind: function (root) {
      root.querySelector('#send').addEventListener('click', function () {
        var v = root.querySelector('#msg').value.trim();
        if (!v) return;
        A.call(A.ROUTES.chatMsgs, { body: { msg: v } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已发送'); root.querySelector('#msg').value = ''; });
      });
      var act = root.querySelector('[data-act="report"]');
      if (act) act.addEventListener('click', function () {
        A.call(A.ROUTES.chatReport, {}, function () { return { ok: 1 }; }).then(function () { U.toast('已举报'); });
      });
    }
  };

  S.notice = {
    title: '公告',
    render: function () {
      return U.nav('公告') + D.notices.map(function (n) {
        return '<div class="card"><div style="font-weight:600">' + U.esc(n.title) + '</div>' +
          '<div class="muted" style="margin-top:6px">' + U.esc(n.body) + '</div>' +
          '<div class="muted" style="margin-top:6px;text-align:right">' + U.esc(n.time) + '</div></div>';
      }).join('');
    }
  };

  S.settings = {
    title: '设置',
    render: function () {
      return U.nav('设置') +
        U.cell('服务器', A.host(), '#/settings') +
        '<div class="card" style="margin:10px 12px"><div style="font-weight:600">数据模式</div>' +
        '<div class="chipbox" style="margin-top:8px">' +
        '<span class="chip' + (A.mode() === 'demo' ? ' on' : '') + '" data-mode="demo">演示数据</span>' +
        '<span class="chip' + (A.mode() === 'live' ? ' on' : '') + '" data-mode="live">直连后端</span></div>' +
        '<div class="muted" style="margin-top:8px">直连后端需请求体加密密钥（libali.so），当前仅演示可用。</div></div>' +
        U.cell('清理缓存', '0 MB', '#/settings') +
        U.cell('设备与安全', '', '#/device') +
        U.cell('服务器节点', '', '#/hosts') +
        U.cell('版本更新', '', '#/update') +
        U.cell('支付方式', '', '#/payment') +
        U.cell('卡密', '', '#/card') +
        U.cell('注册码', '', '#/regcode') +
        U.cell('我的订单', '', '#/orders') +
        U.cell('帮助与反馈', '', '#/help') +
        U.cell('关于', '5.1.52 (120)', '#/settings') +
        '<div class="wrap"><button class="btn line" id="logout">退出登录</button></div>';
    },
    bind: function (root) {
      root.querySelectorAll('[data-mode]').forEach(function (c) {
        c.addEventListener('click', function () {
          A.setMode(c.getAttribute('data-mode'));
          U.toast('已切换为' + (c.getAttribute('data-mode') === 'live' ? '直连后端' : '演示数据'));
          window.RENDER();
        });
      });
      root.querySelector('#logout').addEventListener('click', function () {
        U.toast('已退出（演示）'); U.go('login');
      });
    }
  };

  S.device = {
    title: '设备与安全',
    render: function () {
      return U.nav('设备与安全') +
        D.devices.map(function (d) {
          return '<div class="cell"><span>' + U.esc(d.name) + '<div class="muted">' + U.esc(d.time) + '</div></span>' +
            '<span class="v">' + (d.current ? '当前设备' : '<button class="btn small" data-d="' + d.id + '">停用</button>') + '</span></div>';
        }).join('') +
        U.blk() +
        U.cell('修改密码', '', '#/forgot') +
        U.cell('设置支付密码', '', '#/payment') +
        U.cell('绑定手机号', '', '#/forgot') +
        U.cell('丢失设备', '冻结 / 申诉', '#/forgot') +
        '<div class="wrap muted">接口：' + A.ROUTES.userCert + ' · ' + A.ROUTES.lossCert + ' · ' + A.ROUTES.userVerify + '</div>';
    },
    bind: function (root) {
      root.querySelectorAll('[data-d]').forEach(function (b) {
        b.addEventListener('click', function () {
          A.call(A.ROUTES.forgetCertAdd, { body: { id: b.getAttribute('data-d') } }, function () { return { ok: 1 }; })
            .then(function () { U.toast('已停用该设备'); });
        });
      });
    }
  };

  S.card = {
    title: '卡密',
    render: function () {
      return U.nav('卡密', { action: { key: 'bind', text: '绑定' } }) +
        D.cards.map(function (k) {
          return '<div class="cell"><span style="font-family:ui-monospace,Menlo,monospace">' + U.esc(k.code) +
            '<div class="muted">有效期至 ' + U.esc(k.expire) + '</div></span>' +
            '<span class="v">' + U.esc(k.state) + '</span></div>';
        }).join('') +
        '<div class="wrap muted">接口：' + A.ROUTES.userCard + ' · ' + A.ROUTES.userCardEdit + '</div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="bind"]');
      if (act) act.addEventListener('click', function () { U.toast('输入卡密绑定（演示）'); });
    }
  };

  S.payment = {
    title: '支付方式',
    render: function () {
      return U.nav('支付方式', { action: { key: 'new', text: '新增' } }) +
        U.cell('TRC20-USDT', '默认', '#/payment') +
        U.cell('修改支付密码', '', '#/payment') +
        '<div class="wrap muted">接口：' + A.ROUTES.userPayment + '?ac=list|new|edit|del · ' + A.ROUTES.userPaymentPassword + '</div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="new"]');
      if (act) act.addEventListener('click', function () { U.toast('新增支付方式（演示）'); });
    }
  };

  S.help = {
    title: '帮助与反馈',
    render: function () {
      return U.nav('帮助与反馈') +
        '<div class="card" style="margin:12px"><div style="font-weight:600">常见问题</div>' +
        '<div class="muted" style="margin-top:6px">· 积分怎么获得：签到、被收藏、被解锁<br>' +
        '· 注册码从哪来：积分商城兑换<br>· 交易纠纷：交易详情里发起申诉</div></div>' +
        '<div class="form"><div class="fld"><label>反馈</label><input id="fb" placeholder="描述你遇到的问题"></div></div>' +
        '<div class="wrap"><button class="btn" id="sub">提交反馈</button></div>';
    },
    bind: function (root) {
      root.querySelector('#sub').addEventListener('click', function () {
        A.call(A.ROUTES.userFeedback, { body: { text: root.querySelector('#fb').value } }, function () { return { ok: 1 }; })
          .then(function () { U.toast('已提交，感谢反馈'); });
      });
    }
  };

  S.login = {
    title: '登录',
    render: function () {
      return U.nav('登录', { action: { key: 'reg', text: '注册' } }) +
        '<div class="form">' +
        '<div class="fld"><label>账号</label><input id="acc" placeholder="4~12 位字母或数字" autocapitalize="off"></div>' +
        '<div class="fld"><label>密码</label><input id="pwd" type="password" placeholder="密码"></div>' +
        '<div class="fld"><label>验证码</label><input id="code" placeholder="图形验证码"><span class="code" id="img">获取</span></div>' +
        '</div>' +
        '<div class="wrap"><button class="btn" id="do">登录</button>' +
        '<div style="display:flex;justify-content:space-between;margin-top:12px" class="muted">' +
        '<a href="#/register">注册账号</a><a href="#/forgot">忘记密码</a></div></div>';
    },
    bind: function (root) {
      root.querySelector('#img').addEventListener('click', function () {
        U.toast('验证码接口：' + A.ROUTES.captcha || 'api/captcha');
      });
      root.querySelector('#do').addEventListener('click', function () {
        var acc = root.querySelector('#acc').value.trim();
        var pwd = root.querySelector('#pwd').value.trim();
        if (acc.length < 4 || !pwd) { U.toast('账号至少 4 位，密码不能为空'); return; }
        A.call(A.ROUTES.auth, { body: { username: acc, password: pwd } }, function () {
          return { token: 'demo-token', user: { nickname: acc } };
        }).then(function (res) {
          U.toast(res && res.token ? '登录成功' : '登录失败');
          if (res && res.token) { try { localStorage.setItem('beautybox.token', res.token); } catch (e) {} U.go('me'); }
        });
      });
      var act = root.querySelector('[data-act="reg"]');
      if (act) act.addEventListener('click', function () { U.go('register'); });
    }
  };

  S.register = {
    title: '注册',
    render: function () {
      return U.nav('注册') +
        '<div class="form">' +
        '<div class="fld"><label>账号</label><input id="acc" placeholder="4~12 位字母或数字"></div>' +
        '<div class="fld"><label>密码</label><input id="pwd" type="password"></div>' +
        '<div class="fld"><label>确认</label><input id="pwd2" type="password"></div>' +
        '<div class="fld"><label>注册码</label><input id="code" placeholder="向卖家购买或积分兑换"></div>' +
        '</div>' +
        '<div class="wrap"><button class="btn" id="do">注册</button>' +
        '<p class="muted">注册分「买家 / 卖家」两种：接口 ' + A.ROUTES.regBuyer + ' · ' + A.ROUTES.regSeller + '</p></div>';
    },
    bind: function (root) {
      root.querySelector('#do').addEventListener('click', function () {
        var a = root.querySelector('#acc').value.trim();
        var p = root.querySelector('#pwd').value;
        var p2 = root.querySelector('#pwd2').value;
        if (a.length < 4) { U.toast('账号至少 4 位'); return; }
        if (p !== p2) { U.toast('两次密码不一致'); return; }
        A.call(A.ROUTES.reg, { body: { username: a, password: p, code: root.querySelector('#code').value } },
          function () { return { ok: 1 }; }).then(function () { U.toast('注册成功，请登录'); U.go('login'); });
      });
    }
  };

  S.forgot = {
    title: '找回 / 安全',
    render: function () {
      return U.nav('找回') +
        U.cell('通过设备找回', '已绑定设备', '#/forgot') +
        U.cell('通过凭证找回', '证书 / 卡密', '#/forgot') +
        U.cell('通过支付方式找回', 'USDT 地址', '#/forgot') +
        U.cell('丢失设备申诉', '', '#/forgot') +
        '<div class="wrap muted">接口：' + A.ROUTES.forgetCertAdd + ' · ' + A.ROUTES.forgetPaymentAdd + ' · ' + A.ROUTES.userEdit + '?query=forget</div>';
    }
  };
})();
