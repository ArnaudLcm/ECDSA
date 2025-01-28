import BigInt
import Crypto
import Foundation

public struct PrivateKey {

  private var secret: BigInt
  private var generator: ECCPoint
  private var order: BigInt
  private var publicKey: PublicKey?
  private var prime: BigInt

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
    self.prime = p
  }

  // Returns the public key associated to this private key
  public mutating func getPublicKey() -> PublicKey {
    if(self.publicKey == nil) {
      self.publicKey = PublicKey(point: self.generator * self.secret, generator: self.generator, order: self.order)
    }
    return self.publicKey! // This is safe
  }

public mutating func sign(message: String) throws -> (k: BigInt, Q: ECCPoint, r: BigInt, message: String) {
    guard let messageData = message.data(using: .utf8) else {
        throw ECDSAError.invalidMessage("Message cannot be converted to data.")
    }
    let hash = SHA256.hash(data: messageData)
    
    let hashData = Data(hash)
    
    let hashedMessage = BigInt(hashData)

    guard let j = Self.randomBigInt(between: BigInt(1), and: self.order) else {
        throw ECDSAError.invalidOperation("An internal error occurred while trying to sign your message.")
    }
    
    let Q = j * self.getPublicKey().eccPoint

    let r = Q.x!.value % self.order

    let kNumerator = (hashedMessage + self.secret * r) % self.order
    guard let kInverse = kNumerator.inverse(self.order) else {
        throw ECDSAError.invalidOperation("Failed to compute the modular inverse for k.")
    }
    
    let k = (j * kInverse) % self.order

    return (k: k, Q: Q, r: r, message: message)
}


  private static func randomBigInt(between lower: BigInt, and upper: BigInt) -> BigInt? {
    guard lower < upper else { return nil }

    let range = upper - lower

    let randomValue = BigUInt.randomInteger(lessThan: BigUInt(range))

    return BigInt(randomValue) + lower
  }

}


extension ECCPoint {
    public func toData() -> Data? {
        guard let x = self.x, let y = self.y else { return nil }

        let xData = x.value.serialize()
        let yData = y.value.serialize()
        let aData = self.a.value.serialize()
        let bData = self.b.value.serialize()

        var data = Data()
        data.append(xData)
        data.append(yData)
        data.append(aData)
        data.append(bData)
        
        return data
    }
}