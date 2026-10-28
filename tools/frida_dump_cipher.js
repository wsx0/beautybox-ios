// Frida 脚本：抓取 c.abc 的 native 加解密入参与返回值，
// 用于还原 APK 与后端之间的请求体加密方案（libali.so 由 JNI_OnLoad 动态注册，导出表里没有 ea5/da5）。
//
// 用法（设备已 root / frida-server 已起）：
//   frida -U -f com.secret.prettyhezi -l frida_dump_cipher.js --no-pause
// 输出：/data/local/tmp/bb_cipher.log

Java.perform(function () {
  var Log = {};

  function hex(bytes) {
    var out = '';
    try {
      var arr = Java.array('byte', bytes);
      for (var i = 0; i < arr.length && i < 4096; i++) {
        var v = (arr[i] + 256) % 256;
        out += ('0' + v.toString(16)).slice(-2);
      }
    } catch (e) { out = '<err ' + e + '>'; }
    return out;
  }

  function ascii(bytes) {
    try {
      return Java.use('java.lang.String').$new(Java.array('byte', bytes), 'UTF-8');
    } catch (e) { return ''; }
  }

  function hookNative(name, isEncrypt) {
    var addr = Module.findExportByName(null, name);
    if (!addr) {
      console.log('[!] 导出符号不存在: ' + name + '（说明走 RegisterNatives，需要扫 libali.so）');
      return;
    }
    Interceptor.attach(addr, {
      onEnter: function (args) {
        this.buf = args[1];
        this.len = args[2].toInt32();
        this.key = args[3].toInt32();
        this.in = '';
        try { this.in = hex(Java.vm.getEnv().getByteArrayElements(this.buf, null)); } catch (e) {}
      },
      onLeave: function (retval) {
        console.log('[native] ' + name + ' key=' + this.key + ' in=' + this.in + ' -> ' + retval);
      }
    });
  }

  // 1) 直接 hook Java 层的 abc 类（native 方法照样能被 Java hook 拦到）
  try {
    var abc = Java.use('c.abc');
    abc.ea5.implementation = function (bytes, key) {
      var r = this.ea5(bytes, key);
      console.log('[ea5] key=' + key + '\n  IN : ' + ascii(bytes) + '\n  HEX: ' + hex(bytes) + '\n  OUT: ' + hex(r));
      return r;
    };
    abc.da5.implementation = function (bytes, key) {
      var r = this.da5(bytes, key);
      console.log('[da5] key=' + key + '\n  IN : ' + hex(bytes) + '\n  OUT: ' + ascii(r));
      return r;
    };
    abc.c.implementation = function (i) {
      var r = this.c(i);
      console.log('[c] key=' + i + ' -> ' + r);
      return r;
    };
  } catch (e) {
    console.log('[!] hook c.abc 失败: ' + e);
  }

  // 2) 兜底：hook 网络层，直接看请求体与响应体
  try {
    var ServerE = Java.use('com.secret.prettyhezi.Server.e');
    ServerE.c.implementation = function (str, key) {
      var r = this.c(str, key);
      console.log('[Server.e.c] key=' + key + '\n  PLAIN: ' + str + '\n  CIPHER: ' + hex(r));
      return r;
    };
    ServerE.a.implementation = function (bytes, key) {
      var r = this.a(bytes, key);
      console.log('[Server.e.a] key=' + key + '\n  CIPHER: ' + hex(bytes) + '\n  PLAIN: ' + r);
      return r;
    };
  } catch (e) {
    console.log('[!] hook Server.e 失败: ' + e);
  }

  // 3) 打印全部落地的请求 URL（含 host 与路由）
  try {
    var j = Java.use('com.secret.prettyhezi.j');
    var ReqBuilder = Java.use('okhttp3.Request$Builder');
    j.t.overload('java.lang.String', 'java.lang.String', 'java.lang.String', 'int', 'com.secret.prettyhezi.j$e').implementation = function (url, body, token, key, cb) {
      console.log('[POST] url=' + url + ' key=' + key + '\n  BODY: ' + body);
      return this.t(url, body, token, key, cb);
    };
    j.q.overload('java.lang.String', 'java.lang.String', 'int', 'com.secret.prettyhezi.j$e').implementation = function (url, token, key, cb) {
      console.log('[GET ] url=' + url + ' key=' + key);
      return this.q(url, token, key, cb);
    };
  } catch (e) {
    console.log('[!] hook j 失败: ' + e);
  }

  console.log('[*] hooks installed');
  hookNative('Java_c_abc_ea5', true);
  hookNative('Java_c_abc_da5', false);
});
