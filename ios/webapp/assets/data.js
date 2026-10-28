/* 演示数据：后端不可达时支撑全部界面 */
window.DEMO = (function () {
  var TYPES = [
    { t: 1, key: 'photo', name: '图片' },
    { t: 2, key: 'video', name: '短视频' },
    { t: 3, key: 'book', name: '小说' },
    { t: 4, key: 'film', name: '电影' },
    { t: 5, key: 'rrvideo', name: '长视频' },
    { t: 6, key: 'gallery', name: '图集' },
    { t: 7, key: 'audio', name: '音频' }
  ];

  var NAMES = ['夜航船', '旧城摄影', '林间小径', '街角咖啡', '胶片日记', '雨天限定',
    '剧场后台', '天台落日', '泳池蓝调', '书店午后', '列车窗景', '霓虹漫步'];

  function works(type, n) {
    var out = [];
    for (var i = 0; i < n; i++) {
      var idx = i % NAMES.length;
      out.push({
        id: type + '-' + (i + 1),
        title: NAMES[idx] + ' · ' + (TYPES.filter(function (x) { return x.t === type; })[0] || TYPES[1]).name + ' ' + (i + 1),
        author: '用户' + (1000 + (i * 37) % 900),
        cover: '',
        duration: 30 + (i * 13) % 420,
        views: 800 + i * 233,
        likes: 12 + i * 5,
        score: 10 + (i % 5) * 10,
        vip: i % 5 === 0,
        unlocked: i % 3 === 0,
        hue: (i * 41) % 360
      });
    }
    return out;
  }

  return {
    TYPES: TYPES,
    works: works,
    notices: [
      { id: 'n1', title: '系统公告', body: '当前为 iOS 封装版的本地演示数据，界面与交互按安卓端复原。', time: '刚刚' },
      { id: 'n2', title: '交易提醒', body: '挂单后 10 分钟内不可取消，取消会影响诚信值。', time: '2 小时前' },
      { id: 'n3', title: '审核通知', body: '作品提交后进入审核队列，可在「我的作品」查看状态。', time: '昨天' }
    ],
    chats: [
      { id: 'c1', name: '用户2031', last: '这个作品还在吗？', time: '10:24', unread: 2 },
      { id: 'c2', name: '用户1187', last: '已付款，请发货', time: '昨天', unread: 0 },
      { id: 'c3', name: '系统消息', last: '你的申诉已受理', time: '周一', unread: 1 }
    ],
    trades: [
      { id: 't1', title: '夜航船 · 图集 12P', price: 30, seller: '用户2031', state: '在售', time: '2 分钟前' },
      { id: 't2', title: '旧城摄影 · 短视频 06', price: 50, seller: '用户1187', state: '在售', time: '9 分钟前' },
      { id: 't3', title: '剧场后台 · 长视频', price: 80, seller: '用户3302', state: '已成交', time: '1 小时前' }
    ],
    shop: [
      { id: 'g1', name: '注册码 · 7 天', score: 100 },
      { id: 'g2', name: '注册码 · 30 天', score: 300 },
      { id: 'g3', name: '精华上传权限', score: 500 }
    ],
    scores: [
      { id: 's1', title: '签到奖励', value: 5, time: '今天 09:12' },
      { id: 's2', title: '解锁作品', value: -20, time: '今天 08:40' },
      { id: 's3', title: '兑换注册码', value: -100, time: '昨天 21:03' }
    ],
    issues: (function () {
      var out = [];
      for (var i = 0; i < 12; i++) {
        out.push({
          id: '2026102' + (100 + i),
          open: '2026-10-28 1' + (i % 10) + ':00',
          digits: [(i * 7) % 10, (i * 3) % 10, (i * 5) % 10],
          sum: (i * 3) % 10
        });
      }
      return out;
    })(),
    cards: [
      { id: 'k1', code: 'BX8F-2K9Q-7WQ1', state: '未使用', expire: '2027-01-01' },
      { id: 'k2', code: 'BX2M-4T8Z-3PL7', state: '已使用', expire: '2026-12-01' }
    ],
    devices: [
      { id: 'd1', name: 'iPhone 15', time: '当前设备', current: true },
      { id: 'd2', name: 'Xiaomi 13', time: '3 天前', current: false }
    ]
  };
})();
