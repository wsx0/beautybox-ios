/* 后端接入层：路由与安卓 Server/v.f7323a 拼接一致，失败自动回落演示数据 */
window.API = (function () {
  var HOSTS = [
    'https://g333d.com:20053',
    'https://z555b.com:20053',
    'https://45.61.200.158:10053',
    'https://45.61.244.69:10053'
  ];
  var K_HOST = 'beautybox.host', K_MODE = 'beautybox.mode', K_TOKEN = 'beautybox.token';

  function get(k, d) { try { var v = localStorage.getItem(k); return v === null ? d : v; } catch (e) { return d; } }
  function set(k, v) { try { localStorage.setItem(k, v); } catch (e) {} }

  var R = {
    auth: 'auth/json', userStatus: 'user/status/json', userEdit: 'user/edit/json',
    userVerify: 'user/pverify/json', userCert: 'user/cert/json', userLevel: 'user/level/json',
    userGrade: 'user/grade/json', userGradeInfo: 'user/grade/info/json',
    userExpRecord: 'user/exp/record/json', userIntegral: 'user/integral/record/json',
    userIntegralValue: 'user/integral/value/json', userExpireInfo: 'user/expire/info/json',
    userUpuser: 'user/upuser/json', userResetToken: 'user/reset/token/json',
    userFeedback: 'user/feedback/json', userFollow: 'user/follow/json', userUnfollow: 'user/unfollow/json',
    userCard: 'user/card/json', userCardEdit: 'user/card/edit/json', userOrder: 'user/order/json',
    userOrderBuy: 'user/order/buy/json', userPayment: 'user/payment/json',
    userPaymentPassword: 'user/payment/password/json',
    forgetCertAdd: 'user/forget/cert/add/json', forgetCertDel: 'user/forget/cert/del/json',
    forgetPaymentAdd: 'user/forget/payment/add/json', forgetPaymentDel: 'user/forget/payment/del/json',
    lossCert: 'user/loss/cert/json',
    regCodeInfo: 'user/registration/code/info/json', regCode: 'user/registration/code/json',
    regCodeNew: 'user/registration/code/new/json', reg: 'registration/json',
    regSeller: 'registration/seller/json', regBuyer: 'registration/buyer/json',
    shopRegList: 'shop/reg/list', shopRegNew: 'shop/reg/new', shopRegStatus: 'shop/reg/status',
    shopRegResult: 'shop/reg/result', shopRegCancel: 'shop/reg/cancel',
    boxItems: 'box/items/json', boxTips: 'box/tips/json', boxDel: 'box/del/json',
    boxDelete: 'box/delete/json', boxEdit: 'box/edit/json', boxCollection: 'box/collection/json',
    boxCollectionMany: 'box/collection/many/json', boxUncollection: 'box/uncollection/json',
    boxUncollectionMany: 'box/uncollection/many/json', boxFollow: 'box/follow/json',
    boxUnfollow: 'box/unfollow/json', boxShowEdit: 'box/show/edit/json',
    search: 'api/search', boxList: 'api/boxlist', searchTagsRand: 'api/search/tags/rand/json',
    chat: 'chat/json', chatMsgs: 'chat/msgs/json', chatReport: 'chat/report/json',
    notifyMessageList: 'notify/message/list/json', notifyIsRead: 'notify/isread/json',
    transactionLoad: 'transaction/load/json', transactionSeller: 'transaction/seller/json',
    transactionSellerNew: 'transaction/seller/new/json',
    transactionSellerCancel: 'transaction/seller/cancel/json',
    transactionSellerConfirm: 'transaction/seller/confirm/json',
    transactionBuyerCancel: 'transaction/buyer/cancel/json',
    transactionBuyerPlace: 'transaction/buyer/place/json',
    transactionBuyerPayment: 'transaction/buyer/payment/json',
    transactionBuyerNoPayment: 'transaction/buyer/nopayment/json',
    transactionDispute: 'transaction/dispute/json',
    shopScoreList: 'shop/score/list', shopScoreRecharge: 'shop/score/recharge',
    shopScoreRechargeStatus: 'shop/score/status', shopScoreWithdraw: 'shop/score/withdraw',
    shopScoreWithdrawResult: 'shop/score/withdraw/result',
    shopScoreWithdrawCancel: 'shop/score/withdraw/cancel',
    shopScoreRechargeResult: 'shop/score/recharge/result',
    shopScoreRechargeCancel: 'shop/score/recharge/cancel', tron: 'tron/json',
    reportNew: 'repeatedly/new/json', reportAudit: 'repeatedly/audit/json',
    reportAuditShow: 'repeatedly/audit/show/json', reportAuditIncome: 'report/audit/income/json',
    reportPost: 'report/post/json', report: 'report/json', reportPerm: 'report/perm/json',
    reportAppeal: 'report/appeal/json', appealC2C: 'appeal/c2c/json', audit: 'audit/json',
    hostList: 'host/json', hostNew: 'host/new/json', hostShow: 'host/show/json',
    hostUpdate: 'host/update/json', apkNew: 'user/apk/new/json', apkStatus: 'user/apk/status/json'
  };

  function route(key) { return R[key] || key; }
  function nodeList(typeKey) { return typeKey + '/node/json'; }
  function unlock(typeKey) { return typeKey + '/unlock/json'; }
  function tryPlay(typeKey) { return typeKey + '/try/json'; }

  function host() { return get(K_HOST, HOSTS[0]); }
  function setHost(h) { set(K_HOST, h); }
  function mode() { return get(K_MODE, 'demo'); }
  function setMode(m) { set(K_MODE, m); }
  function token() { return get(K_TOKEN, ''); }

  function req(r, opt) {
    opt = opt || {};
    var qs = opt.query ? '?' + Object.keys(opt.query).map(function (k) {
      return encodeURIComponent(k) + '=' + encodeURIComponent(opt.query[k]);
    }).join('&') : '';
    var url = host().replace(/\/+$/, '') + '/' + r + qs;
    var headers = {
      'platform': 'ios', 'os': 'ios', 'version': '5.1.52', 'versionCode': '120',
      'Accept': 'application/json'
    };
    if (token()) headers['Authorization'] = 'Bearer ' + token();
    var init = { method: opt.body ? 'POST' : 'GET', headers: headers, mode: 'cors' };
    if (opt.body) {
      headers['Content-Type'] = 'application/json';
      init.body = JSON.stringify(opt.body);
    }
    return fetch(url, init).then(function (res) {
      if (!res.ok) throw new Error('HTTP ' + res.status);
      return res.json();
    }).then(function (json) {
      if (json && json.code && json.code !== 0 && json.code !== 200) {
        throw new Error(json.msg || json.message || ('code ' + json.code));
      }
      return json;
    });
  }

  /* 统一入口：演示模式直接给本地数据；直连模式失败自动回落 */
  function call(r, opt, fallback) {
    if (mode() !== 'live') {
      return Promise.resolve(typeof fallback === 'function' ? fallback() : fallback);
    }
    return req(r, opt).catch(function (err) {
      if (window.UI && UI.toast) UI.toast('后端不可达：' + err.message + '（已用演示数据）');
      return typeof fallback === 'function' ? fallback() : fallback;
    });
  }

  return {
    ROUTES: R, route: route, nodeList: nodeList, unlock: unlock, tryPlay: tryPlay,
    hosts: HOSTS, host: host, setHost: setHost, mode: mode, setMode: setMode,
    token: token, request: req, call: call
  };
})();
