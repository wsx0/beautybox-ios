# -*- coding: utf-8 -*-
import re, os

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
MAN = os.path.join(ROOT, 'extract', 'AndroidManifest.decoded.txt')
WEB = os.path.join(ROOT, 'ios', 'webapp')
OUT = os.path.join(ROOT, 'report', '功能覆盖矩阵.md')

acts = []
for line in open(MAN, encoding='utf-8'):
    s = line.strip()
    if s.startswith('<activity'):
        m = re.search(r'name=([^\s>]+)', s)
        if m:
            acts.append(m.group(1))

def seg(a):
    p = a.split('.')
    return p[3] if len(p) > 4 else 'root'

PKG_MAP = {
    'Game': ('game / gameRecord', '夺宝玩法：期号、投注、开奖结果、记录'),
    'share': ('trade / tradeDetail / shop / recharge / withdraw / scoreLog / card', '分享与数字货币结算：挂单、充值、提现、积分记录'),
    'Upload': ('upload / audit / works', '上传、审核、举报、申诉、审核收入'),
    'User': ('me / device / payment / card / works / collect', '账号、实名凭证、支付方式、卡密、我的作品'),
    'Registration': ('register / forgot / card', '注册（买家/卖家）、注册码、找回'),
    'Device': ('device / forgot / payment', '设备绑定、停用、丢失、支付密码'),
    'ScoreExchange': ('trade / tradeDetail', '积分交易：买家/卖家订单、确认、取消'),
    'Payment': ('payment / recharge', '支付方式管理'),
    'Video': ('player / detail', '视频播放'),
    'message': ('chatList / chat', '会话、消息、举报'),
    'root': ('home / search / notice / settings / help / detail / list / works', '主框架与公共页'),
}

def screen_of(a):
    return PKG_MAP.get(seg(a), ('home', '未分类'))

js = ''
for f in ['assets/screens1.js', 'assets/screens2.js', 'assets/screens3.js', 'assets/screens4.js', 'assets/ui.js', 'assets/app.js']:
    js += open(os.path.join(WEB, f), encoding='utf-8').read()
js_routes = set(re.findall(r"A\.ROUTES\.([A-Za-z0-9_]+)", js))
# 动态调用：more 页把路由键写成字符串数组项
js_routes |= set(re.findall(r"\['([A-Za-z0-9_]+)',\s*'", js))

api_src = open(os.path.join(WEB, 'assets', 'api.js'), encoding='utf-8').read()
start = api_src.index('var R = {')
block = api_src[start:api_src.index('};', start)]
routes = re.findall(r"([A-Za-z0-9_]+):\s*'([^']+)'", block)

screens_src = ''
for f in ['assets/screens1.js', 'assets/screens2.js', 'assets/screens3.js', 'assets/screens4.js']:
    screens_src += open(os.path.join(WEB, f), encoding='utf-8').read()
screen_ids = re.findall(r'S\.([A-Za-z0-9_]+) = \{', screens_src)

sep = '|'
def row(*cols):
    return sep + sep.join(cols) + sep

L = []
L.append('# 功能覆盖矩阵（Android → iOS）')
L.append('')
L.append('由 tools/coverage.py 生成；依据：AndroidManifest（Activity 清单）+ 反编译路由表 + iOS 端源码。')
L.append('')
L.append('## 1. 总览')
L.append('')
L.append(row('指标', '数值'))
L.append(row('---', '---'))
L.append(row('安卓 Activity', str(len(acts))))
L.append(row('iOS 页面（SCREENS）', str(len(screen_ids))))
L.append(row('后端路由（API.ROUTES）', str(len(routes))))
L.append(row('页面中实际调用的路由', str(len(js_routes))))
L.append('')
L.append('## 2. Activity 映射')
L.append('')
L.append(row('安卓 Activity', '归属包', 'iOS 页面', '功能'))
L.append(row('---', '---', '---', '---'))
seen = {}
for a in acts:
    sg = seg(a)
    sc, desc = screen_of(a)
    seen[sg] = seen.get(sg, 0) + 1
    L.append(row(a, sg, sc, desc))
L.append('')
L.append('## 3. 按包统计')
L.append('')
L.append(row('包', 'Activity 数', 'iOS 页面'))
L.append(row('---', '---', '---'))
for sg, n in sorted(seen.items(), key=lambda x: -x[1]):
    L.append(row(sg, str(n), PKG_MAP.get(sg, ('home', ''))[0]))
L.append('')
L.append('## 4. 路由覆盖')
L.append('')
L.append(row('路由键', '路径', '页面是否调用'))
L.append(row('---', '---', '---'))
for key, path in routes:
    L.append(row(key, path, '是' if key in js_routes else '—'))
unused = [k for k, _ in routes if k not in js_routes]
L.append('')
L.append('未被页面直接调用的路由：%d 个（多为管理/内部接口，原生工程的 Endpoint.swift 里同样保留）。' % len(unused))
L.append('')
open(OUT, 'w', encoding='utf-8').write('\n'.join(L))
print('activities', len(acts), 'screens', len(screen_ids), 'routes', len(routes), 'used', len(js_routes))
print('unused:', ','.join(unused))
