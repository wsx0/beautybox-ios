
import sqlite3, shutil, os, sys, tempfile

paths = {
    'edge': os.path.expandvars(r'%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Network\Cookies'),
    'chrome': os.path.expandvars(r'%LOCALAPPDATA%\Google\Chrome\User Data\Default\Network\Cookies'),
}
for name, p in paths.items():
    if not os.path.exists(p):
        print(name, 'MISSING'); continue
    tmp = os.path.join(tempfile.gettempdir(), 'ck_' + name)
    shutil.copy2(p, tmp)
    try:
        con = sqlite3.connect(tmp)
        cur = con.cursor()
        cur.execute("select host_key, name from cookies where host_key like '%github%'")
        rows = cur.fetchall()
        print(name, 'github cookies:', len(rows))
        for h, n in rows[:12]:
            print('   ', h, n)
        cur.execute("select count(*) from cookies")
        print(name, 'total cookies:', cur.fetchone()[0])
        con.close()
    except Exception as e:
        print(name, 'ERR', e)
    finally:
        try: os.remove(tmp)
        except Exception: pass
