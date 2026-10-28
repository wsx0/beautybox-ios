import Foundation
import CryptoKit

/// 请求体加解密。
///
/// 安卓端在 c.abc 里用 native 方法（libali.so）处理：
///   - Server.e.c(String, int key) -> abc.ea5(byte[], int)
///   - Server.e.a(byte[], int key) -> abc.da5(byte[], int)
/// key 为 1 时加密（j.r / j.u 默认传 1），key 为 0 时明文（j.p 与所有 GET）。
/// libali.so 里这些方法由 JNI_OnLoad 动态注册，导出表只有 abl/abm/ams/amu，
/// 需要用 Frida 在运行期抓 Java_c_abc_ea5 的入参和返回值（见 tools/frida_dump_cipher.js）。
protocol BodyCipher {
    func encrypt(_ plain: Data) throws -> Data
    func decrypt(_ cipher: Data) throws -> Data
}

/// 明文模式：key=0 的接口、以及调试期直连。
struct PlainCipher: BodyCipher {
    func encrypt(_ plain: Data) throws -> Data { plain }
    func decrypt(_ cipher: Data) throws -> Data { cipher }
}

/// AES-CBC/PKCS7。密钥槽位与安卓一致（keyIndex），落地密钥从 libali.so 提取后填入。
struct AESCBCCipher: BodyCipher {
    let key: Data
    let iv: Data

    init(keyHex: String, ivHex: String) {
        self.key = Data(hexString: keyHex)
        self.iv = Data(hexString: ivHex)
    }

    func encrypt(_ plain: Data) throws -> Data {
        let box = try AES(key: Array(key), blockMode: CBC(iv: Array(iv)), padding: .pkcs7)
        return Data(try box.encrypt(Array(plain)))
    }

    func decrypt(_ cipher: Data) throws -> Data {
        let box = try AES(key: Array(key), blockMode: CBC(iv: Array(iv)), padding: .pkcs7)
        return Data(try box.decrypt(Array(cipher)))
    }
}

/// AES-GCM 备选实现（若抓包证明服务端用的是 GCM）。
struct AESGCMCipher: BodyCipher {
    let key: Data

    func encrypt(_ plain: Data) throws -> Data {
        let sealed = try AES.GCM.seal(plain, using: SymmetricKey(data: key))
        return sealed.combined ?? Data()
    }

    func decrypt(_ cipher: Data) throws -> Data {
        let box = try AES.GCM.SealedBox(combined: cipher)
        return try AES.GCM.open(box, using: SymmetricKey(data: key))
    }
}

extension Data {
    init(hexString: String) {
        var bytes = [UInt8]()
        var idx = hexString.startIndex
        while idx < hexString.endIndex {
            let next = hexString.index(idx, offsetBy: 2, limitedBy: hexString.endIndex) ?? hexString.endIndex
            if let b = UInt8(hexString[idx..<next], radix: 16) { bytes.append(b) }
            idx = next
        }
        self.init(bytes)
    }
}
