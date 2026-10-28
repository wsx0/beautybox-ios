/* 补充域：等级 / 注册码 / 店铺注册 / 节点 / 订单 / 更新 / 全接口入口 */
(function () {
  var S = window.SCREENS = window.SCREENS || {};
  var D = window.DEMO, A = window.API, U = window.UI;

  function actList(groups) {
    return groups.map(function (g) {
      return '<div class="blk"></div><div class="wrap muted" style="padding:10px 12px 2px">' + U.esc(g.name) + '</div>' +
        g.items.map(function (it) {
          return '<a class="cell" href="#" data-route="' + it[0] + '"><span>' + U.esc(it[1]) + '</span>' +
            '<span class="v">' + it[0] + '</span></a>';
        }).join('');
    }).join('');
  }

  S.more = {
    title: '全部功能',
    render: function () {
      return U.nav('全部功能（' + Object.keys(A.ROUTES).length + ' 个接口）') +
        actList([
          { name: '账号与等级', items: [
            ['userLevel', '等级信息'], ['userGrade', '等级列表'], ['userGradeInfo', '等级详情'],
            ['userExpRecord', '经验记录'], ['userIntegral', '积分记录'], ['userIntegralValue', '积分价值'],
            ['userExpireInfo', '到期信息'], ['userUpuser', '同步资料'], ['userResetToken', '重置登录态'],
            ['userFollow', '关注用户'], ['userUnfollow', '取消关注'] ] },
          { name: '内容与盒子', items: [
            ['boxTips', '盒子详情'], ['boxList', '盒子列表'], ['boxDel', '删除作品'],
            ['boxDelete', '彻底删除'], ['boxEdit', '编辑作品'], ['boxCollectionMany', '批量收藏'],
            ['boxUncollection', '取消收藏'], ['boxUncollectionMany', '批量取消收藏'],
            ['boxFollow', '关注盒子'], ['boxUnfollow', '取消关注盒子'], ['boxShowEdit', '修改展示'],
            ['searchTagsRand', '随机标签'], ['chat', '聊天入口'], ['notifyMessageList', '通知列表'],
            ['notifyIsRead', '标记已读'] ] },
          { name: '交易与资金', items: [
            ['transactionSeller', '卖家订单'], ['transactionSellerNew', '新建挂单'],
            ['transactionSellerCancel', '卖家取消'], ['transactionSellerConfirm', '卖家确认'],
            ['transactionBuyerPayment', '买家已付款'], ['transactionBuyerNoPayment', '买家未付款'],
            ['shopScoreRechargeResult', '充值结果'], ['shopScoreRechargeCancel', '取消充值'],
            ['shopScoreWithdrawResult', '提现结果'], ['shopScoreWithdrawCancel', '取消提现'] ] },
          { name: '注册与店铺', items: [
            ['regCodeInfo', '注册码信息'], ['regCode', '我的注册码'], ['regCodeNew', '生成注册码'],
            ['shopRegList', '店铺列表'], ['shopRegNew', '店铺注册'], ['shopRegStatus', '店铺状态'],
            ['shopRegResult', '注册结果'], ['shopRegCancel', '取消注册'] ] },
          { name: '审核与举报', items: [
            ['report', '举报'], ['reportPerm', '举报权限'], ['reportAuditIncome', '审核收益'],
            ['reportAppeal', '申诉'], ['appealC2C', 'C2C 申诉'], ['audit', '审核'] ] },
          { name: '设备与支付', items: [
            ['forgetCertDel', '删除凭证'], ['forgetPaymentDel', '删除支付方式'],
            ['userCard', '卡密列表'], ['userCardEdit', '卡密编辑'], ['userOrder', '订单详情'],
            ['userOrderBuy', '购买订单'] ] },
          { name: '服务器与版本', items: [
            ['hostList', '节点列表'], ['hostNew', '新增节点'], ['hostShow', '节点详情'],
            ['hostUpdate', '更新节点'], ['apkNew', 'APK 更新'], ['apkStatus', '更新状态'] ] }
        ]) +
        '<div class="wrap muted">每个条目都会真实调用对应路由；演示模式下不联网，直连模式会发请求并回显结果。</div>';
    },
    bind: function (root) {
      root.querySelectorAll('[data-route]').forEach(function (el) {
        el.addEventListener('click', function (e) {
          e.preventDefault();
          var key = el.getAttribute('data-route');
          A.call(A.ROUTES[key], {}, function () { return { ok: 1, demo: true }; }).then(function (res) {
            U.toast(key + ' → ' + JSON.stringify(res).slice(0, 60));
          });
        });
      });
    }
  };

  S.level = {
    title: '等级',
    render: function () {
      return U.nav('等级与经验') +
        '<div class="card" style="margin:12px"><div style="font-size:17px;font-weight:600">Lv.3 · 积分等级</div>' +
        '<div class="muted" style="margin-top:6px">经验 320 / 500，升级可提高上传上限</div>' +
        '<div style="height:8px;background:#f0f0f0;border-radius:4px;margin-top:10px;overflow:hidden">' +
        '<div style="width:64%;height:100%;background:#aa0000"></div></div></div>' +
        U.cell('等级列表', '', '#/level') + U.cell('等级详情', '', '#/level') +
        U.cell('经验记录', '', '#/level') + U.cell('积分价值', '', '#/level') +
        U.cell('到期信息', '', '#/level') +
        '<div class="wrap muted">接口：' + A.ROUTES.userLevel + ' · ' + A.ROUTES.userGrade + ' · ' + A.ROUTES.userGradeInfo +
        ' · ' + A.ROUTES.userExpRecord + ' · ' + A.ROUTES.userIntegralValue + ' · ' + A.ROUTES.userExpireInfo + '</div>';
    }
  };

  S.regcode = {
    title: '注册码',
    render: function () {
      return U.nav('注册码', { action: { key: 'new', text: '生成' } }) +
        U.cell('我的注册码', '', '#/regcode') +
        U.cell('注册码信息', '有效期 / 使用记录', '#/regcode') +
        U.cell('购买注册码', '', '#/shop') +
        '<div class="wrap muted">接口：' + A.ROUTES.regCode + ' · ' + A.ROUTES.regCodeInfo + ' · ' + A.ROUTES.regCodeNew + '</div>';
    },
    bind: function (root) {
      var act = root.querySelector('[data-act="new"]');
      if (act) act.addEventListener('click', function () {
        A.call(A.ROUTES.regCodeNew, {}, function () { return { code: 'BX-DEMO-0001' }; })
          .then(function (r) { U.toast('生成注册码：' + (r.code || 'BX-DEMO-0001')); });
      });
    }
  };

  S.shopReg = {
    title: '店铺注册',
    render: function () {
      return U.nav('店铺注册') +
        U.cell('店铺列表', '', '#/shopReg') +
        U.cell('注册新店铺', '卖家 / 买家', '#/shopReg') +
        U.cell('注册状态', '', '#/shopReg') +
        U.cell('取消注册', '', '#/shopReg') +
        '<div class="wrap"><button class="btn" id="go">提交店铺注册</button></div>' +
        '<div class="wrap muted">接口：' + A.ROUTES.shopRegList + ' · ' + A.ROUTES.shopRegNew + ' · ' + A.ROUTES.shopRegStatus + '</div>';
    },
    bind: function (root) {
      root.querySelector('#go').addEventListener('click', function () {
        A.call(A.ROUTES.shopRegNew, { body: { type: 'seller' } }, function () { return { id: 'r1' }; })
          .then(function () { U.toast('已提交，等待审核'); });
      });
    }
  };

  S.hosts = {
    title: '服务器节点',
    render: function () {
      return U.nav('服务器节点', { action: { key: 'new', text: '新增' } }) +
        A.hosts.map(function (h) {
          return '<div class="cell"><span style="font-family:ui-monospace,Menlo,monospace;font-size:12px">' + U.esc(h) + '</span>' +
            '<span class="v">' + (h === A.host() ? '当前' : '<button class="btn small" data-h="' + U.esc(h) + '">切换</button>') + '</span></div>';
        }).join('') +
        '<div class="wrap"><button class="btn ghost" id="test">测速（/query?v=1.3）</button></div>' +
        '<div class="wrap muted">接口：' + A.ROUTES.hostList + ' · ' + A.ROUTES.hostNew + ' · ' + A.ROUTES.hostShow + ' · ' + A.ROUTES.hostUpdate + '</div>';
    },
    bind: function (root) {
      root.querySelectorAll('[data-h]').forEach(function (b) {
        b.addEventListener('click', function () {
          A.setHost(b.getAttribute('data-h'));
          U.toast('已切换节点');
          window.RENDER();
        });
      });
      root.querySelector('#test').addEventListener('click', function () {
        A.call(A.ROUTES.hostList, {}, function () { return { servers: A.hosts }; })
          .then(function () { U.toast('测速完成（演示）'); });
      });
    }
  };

  S.orders = {
    title: '我的订单',
    render: function () {
      return U.nav('我的订单') +
        D.trades.map(function (t) {
          return '<a class="cell" href="#/tradeDetail/' + encodeURIComponent(t.id) + '">' +
            '<span>' + U.esc(t.title) + '<div class="muted">' + U.esc(t.seller) + ' · ' + t.price + ' 积分</div></span>' +
            '<span class="v">' + U.esc(t.state) + '</span></a>';
        }).join('') +
        '<div class="wrap muted">接口：' + A.ROUTES.userOrder + ' · ' + A.ROUTES.userOrderBuy + '</div>';
    }
  };

  S.update = {
    title: '版本更新',
    render: function () {
      return U.nav('版本更新') +
        '<div class="card" style="margin:12px"><div style="font-weight:600">当前版本 5.1.52 (120)</div>' +
        '<div class="muted" style="margin-top:6px">iOS 版通过 App Store / TestFlight 分发，不做应用内安装。</div></div>' +
        '<div class="wrap"><button class="btn" id="chk">检查更新</button></div>' +
        '<div class="wrap muted">接口：' + A.ROUTES.apkNew + ' · ' + A.ROUTES.apkStatus + '</div>';
    },
    bind: function (root) {
      root.querySelector('#chk').addEventListener('click', function () {
        A.call(A.ROUTES.apkStatus, {}, function () { return { version: '5.1.52', latest: '5.1.52' }; })
          .then(function () { U.toast('已是最新版本'); });
      });
    }
  };
})();
