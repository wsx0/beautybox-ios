
import os, math, subprocess, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\deepseek项目\软件破解\beautybox_port'
IMGDIR = os.path.join(ROOT, 'ios', 'BeautyBox', 'Resources', 'samples')
WEBDIR = os.path.join(ROOT, 'ios', 'webapp', 'media')
os.makedirs(IMGDIR, exist_ok=True)
os.makedirs(WEBDIR, exist_ok=True)

FONT = r'C:\Windows\Fonts\msyhbd.ttc'
def font(sz):
    try:
        return ImageFont.truetype(FONT, sz)
    except Exception:
        return ImageFont.load_default()

TITLES = ['夜航船', '旧城摄影', '林间小径', '街角咖啡', '胶片日记', '雨天限定', '天台落日', '泳池蓝调']
HUES = [210, 28, 140, 32, 262, 196, 18, 190]

for i, (t, h) in enumerate(zip(TITLES, HUES), start=1):
    W, H = 900, 1200
    img = Image.new('RGB', (W, H))
    d = ImageDraw.Draw(img)
    for y in range(H):
        k = y / H
        r = int(24 + 60 * (1 - k) * math.cos(h * math.pi / 180))
        g = int(26 + 70 * (1 - k) * math.cos((h + 40) * math.pi / 180))
        b = int(34 + 90 * (1 - k) * math.sin((h + 20) * math.pi / 180))
        d.line([(0, y), (W, y)], fill=(abs(r) % 256, abs(g) % 256, abs(b) % 256))
    # 装饰圆
    for k in range(5):
        r = 60 + k * 70
        cx = int(W * (0.2 + 0.15 * k))
        cy = int(H * (0.75 - 0.08 * k))
        d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(255, 255, 255, 40), width=2)
    f1 = font(86)
    f2 = font(34)
    d.text((60, H - 260), t, font=f1, fill=(255, 255, 255))
    d.text((64, H - 150), 'BeautyBox 演示素材 %02d' % i, font=f2, fill=(255, 255, 255, 200))
    d.rectangle([0, 0, W - 1, H - 1], outline=(255, 255, 255), width=0)
    p = os.path.join(IMGDIR, 'cover_%d.jpg' % i)
    img.save(p, 'JPEG', quality=86)
    img.resize((600, 800)).save(os.path.join(WEBDIR, 'cover_%d.jpg' % i), 'JPEG', quality=86)
    print('cover', p)

import imageio_ffmpeg
ff = imageio_ffmpeg.get_ffmpeg_exe()
src = os.path.join(IMGDIR, 'cover_1.jpg')
mp4 = os.path.join(IMGDIR, 'demo.mp4')
cmd = [ff, '-y', '-loop', '1', '-i', src,
       '-vf', "scale=720:1280,zoompan=z='min(zoom+0.0006,1.25)':d=180:s=720x1280:fps=30,format=yuv420p",
       '-t', '6', '-c:v', 'libx264', '-profile:v', 'baseline', '-level', '3.1',
       '-pix_fmt', 'yuv420p', '-movflags', '+faststart', '-an', mp4]
r = subprocess.run(cmd, capture_output=True, text=True)
print('ffmpeg rc', r.returncode)
print((r.stderr or '')[-600:])
if os.path.exists(mp4):
    print('mp4 size', os.path.getsize(mp4))
    import shutil
    shutil.copy2(mp4, os.path.join(WEBDIR, 'demo.mp4'))
    print('copied to webapp/media')
