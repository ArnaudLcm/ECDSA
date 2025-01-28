import BigInt
import Crypto
import Foundation

public struct PrivateKey {

  private var secret: BigInt
  private var generator: ECCPoint
  private var order: BigInt
  private var publicKey: PublicKey?

  /// Creates an ECC PrivateKey
  /// - Parameters:
  ///   - a: coefficient in elliptic curve: y**2 = x**3 + ax + b
  ///   - b: coefficient in elliptic curve: y**2 = x**3 + ax+ b
  ///   - x: x coordinate of the generator point
  ///   - y: y coordinate of the generator point
  ///   - order of the elliptic curve group
  ///   - p: prime number of the finite set underlying the curve group
  init(a: BigInt, b: BigInt, x: BigInt, y: BigInt, n: BigInt, p: BigInt) throws {

    self.generator = try ECCPoint(a: a, b: b, p: p, x: x, y: y)
    self.secret = Self.randomBigInt(between: BigInt(1), and: n)!
    self.order = n

  }

  // Returns the public key associated to this private key
  public mutating func getPublicKey() -> PublicKey {
    if(self.publicKey == nil) {
      self.publicKey = PublicKey(point: self.generator * self.secret, generator: self.generator)
    }
    return self.publicKey! // This is safe
  }

  public mutating func sign(message: String) throws -> (k: BigInt, Q: ECCPoint, message: String) {
    guard let messageData = message.data(using: .utf8) else {
        throw ECDSAError.invalidMessage("Message cannot be converted to data.")
    }
    let hash = SHA256.hash(data: messageData)

    let hashedMessage = BigInt(hash.compactMap { String(format: "%02x", $0) }.joined(), radix: 16)!


    guard let j = Self.randomBigInt(between: 1,and: self.order) else {
      throw ECDSAError.invalidOperation("An internal error occured while trying to sign your message.")
    }
    
    let Q = j * self.getPublicKey().eccPoint

    let k = (hashedMessage + self.secret)/j

    return (k: k, Q: Q, message: message)
  
  }

  private static func randomBigInt(between lower: BigInt, and upper: BigInt) -> BigInt? {
    guard lower < upper else { return nil }

    let range = upper - lower

    let randomValue = BigUInt.randomInteger(lessThan: BigUInt(range))

    return BigInt(randomValue) + lower
  }

}
