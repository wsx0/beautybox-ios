import Foundation
import CryptoKit
import CommonCrypto

/// 请求体加解密。
///
/// 安卓端在 c.abc 里用 native 方法（libali.so）处理：
///   - Server.e.c(String, int key) -> abc.ea5(byte[], int)
///   - Server.e.a(byte[], int key) -> abc.da5(byte[], int)
/// key 为 1 时加密（j.r / j.u 默认传 1），key 为 0 时明文（j.p 与所有 GET）。
/// 密钥要从 libali.so 里还原（见 tools/frida_dump_cipher.js）。
protocol BodyCipher {
    func encrypt(_ plain: Data) throws -> Data
    func decrypt(_ cipher: Data) throws -> Data
}

/// 明文模式：key=0 的接口、以及调试期直连。
struct PlainCipher: BodyCipher {
    func encrypt(_ plain: Data) throws -> Data { plain }
    func decrypt(_ cipher: Data) throws -> Data { cipher }
}

/// AES-CBC/PKCS7（CommonCrypto 实现，CryptoKit 只提供 GCM）。
struct AESCBCCipher: BodyCipher {
    let key: Data
    let iv: Data

    init(keyHex: String, ivHex: String) {
        self.key = Data(hexString: keyHex)
        self.iv = Data(hexString: ivHex)
    }

    func encrypt(_ plain: Data) throws -> Data {
        try crypt(plain, operation: CCOperation(kCCEncrypt))
    }

    func decrypt(_ cipher: Data) throws -> Data {
        try crypt(cipher, operation: CCOperation(kCCDecrypt))
    }

    private func crypt(_ input: Data, operation: CCOperation) throws -> Data {
        let capacity = input.count + kCCBlockSizeAES128
        var output = Data(count: capacity)
        var moved = 0
        let status: CCCryptorStatus = output.withUnsafeMutableBytes { (outBuf: UnsafeMutableRawBufferPointer) -> CCCryptorStatus in
            guard let outPtr = outBuf.baseAddress else { return CCCryptorStatus(kCCMemoryFailure) }
            return input.withUnsafeBytes { (inBuf: UnsafeRawBufferPointer) -> CCCryptorStatus in
                guard let inPtr = inBuf.baseAddress else { return CCCryptorStatus(kCCMemoryFailure) }
                return key.withUnsafeBytes { (keyBuf: UnsafeRawBufferPointer) -> CCCryptorStatus in
                    iv.withUnsafeBytes { (ivBuf: UnsafeRawBufferPointer) -> CCCryptorStatus in
                        CCCrypt(operation,
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBuf.baseAddress, key.count,
                                ivBuf.baseAddress,
                                inPtr, input.count,
                                outPtr, capacity,
                                &moved)
                    }
                }
            }
        }
        guard status == CCCryptorStatus(kCCSuccess) else {
            throw NSError(domain: "AESCBCCipher", code: Int(status),
                          userInfo: [NSLocalizedDescriptionKey: "CCCrypt status \(status)"])
        }
        return output.prefix(moved)
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
