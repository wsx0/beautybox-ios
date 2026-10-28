'use strict';
// BeautyBox gadget hook：结果写 /sdcard/bb_keys.txt
var OUT = '/sdcard/bb_keys.txt';
function w(s) {
    console.log(s);
    try { var f = new File(OUT, 'a'); f.write(s + '\n'); f.flush(); f.close(); } catch (e) {}
}
function hex(ab) {
    try {
        var u = new Uint8Array(ab), s = '';
        for (var i = 0; i < u.length && i < 256; i++) s += ('0' + u[i].toString(16)).slice(-2);
        return s;
    } catch (e) { return '<err>'; }
}
setTimeout(function () {
    Java.perform(function () {
        w('=== start ' + new Date().toISOString() + ' ===');
        var abc;
        try { abc = Java.use('c.abc'); } catch (e) { w('[!] c.abc missing: ' + e); return; }
        function hookBytes(n) {
            try {
                var m = abc[n];
                if (!m) { w('[i] no ' + n); return; }
                m.implementation = function (a, k) {
                    var r = m.call(this, a, k);
                    w('[' + n + '] key=' + k + ' in=' + hex(a) + ' out=' + hex(r));
                    return r;
                };
                w('[+] ' + n);
            } catch (e) { w('[!] ' + n + ' ' + e); }
        }
        function hookStr(n) {
            try {
                var m = abc[n];
                if (!m) { w('[i] no ' + n); return; }
                m.implementation = function (s) {
                    var r = m.call(this, s);
                    w('[' + n + '] in=' + s + ' out=' + r);
                    return r;
                };
                w('[+] ' + n);
            } catch (e) { w('[!] ' + n + ' ' + e); }
        }
        hookBytes('ea5'); hookBytes('da5');
        hookStr('ea2'); hookStr('da2');
        hookBytes('ea3'); hookBytes('da3'); hookStr('da');
        try {
            abc.c.implementation = function (i) {
                var r = abc.c.call(this, i);
                w('[c] index=' + i + ' -> ' + r);
                return r;
            };
            w('[+] c');
        } catch (e) { w('[!] c ' + e); }
        w('=== hooks ready ===');
    });
}, 1500);
