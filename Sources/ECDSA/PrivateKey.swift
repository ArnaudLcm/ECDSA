import BigInt
import Foundation

public struct PrivateKey {

  private var secret: BigInt
  private var generator: ECCPoint

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

  }


  public func getPublicKey() -> PublicKey {
    return PublicKey(point: self.generator * self.secret)
  }

  private static func randomBigInt(between lower: BigInt, and upper: BigInt) -> BigInt? {
    guard lower < upper else { return nil }

    let range = upper - lower

    let randomValue = BigUInt.randomInteger(lessThan: BigUInt(range))

    return BigInt(randomValue) + lower
  }

}
