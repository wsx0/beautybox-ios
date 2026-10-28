
import sys, qrcode
url, out = sys.argv[1], sys.argv[2]
qr = qrcode.QRCode(version=None, box_size=12, border=3)
qr.add_data(url)
qr.make(fit=True)
img = qr.make_image(fill_color="black", back_color="white")
img.save(out)
print('qr', out, url, img.size)
