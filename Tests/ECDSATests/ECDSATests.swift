import XCTest
import BigInt
import Foundation

@testable import ECDSA

final class ECDSATests: XCTestCase {

    func testGeneratesecp256k1AndGetPublicKey() {
        let n = BigInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let p = BigInt(2).power(256) - BigInt(2).power(32) - BigInt(977)
        let x = BigInt("79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", radix: 16)!
        let y = BigInt("483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8", radix: 16)!
        let a = BigInt(0)
        let b = BigInt(7)

        do {
            let privateKey = try PrivateKey(a: a, b: b, x: x, y: y, n: n, p: p)
            let publicKey = privateKey.getPublicKey()
            let infinitePoint = try ECCPoint(a:a,b:b,p:p,x:nil,y:nil)
            XCTAssert(publicKey.eccPoint != infinitePoint)
        } catch {
            XCTFail("Can't generate secp256k1 private key.")
        }
    }
}
