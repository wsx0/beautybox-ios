
import sys, zipfile, re
z = zipfile.ZipFile(sys.argv[1])
b = z.read('lib/arm64-v8a/libali.so')
print('so size', len(b))
# printable strings
strs = re.findall(rb'[ -~]{5,}', b)
dec = [x.decode('ascii', 'replace') for x in strs]
print('strings', len(dec))
pats = ['AES','aes','CBC','ECB','key','Key','iv','Java_c_abc','sign','Sign','md5','MD5','sha','SHA']
hits = [s2 for s2 in dec if any(p in s2 for p in ['AES','CBC','GCM','Java_','jni','JNI','openssl','OpenSSL','mbedtls','crypto'])]
print('--- interesting', len(hits))
for h in hits[:80]: print('  ', h)
print('--- hex-ish 16/32/64')
for s2 in dec:
    if re.fullmatch(r'[0-9a-fA-F]{16}|[0-9a-fA-F]{32}|[0-9a-fA-F]{64}', s2):
        print('  ', s2)
