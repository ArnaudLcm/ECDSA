import BigInt
import Foundation

public struct ECCPoint: Equatable, Sendable {
  public var x: FiniteElement?
  public var y: FiniteElement?

  public var a: FiniteElement
  public var b: FiniteElement

  private static func createFiniteElement(from value: BigInt?, prime: BigInt) throws
    -> FiniteElement?
  {
    guard let value = value else { return nil }
    return FiniteElement(value: value, prime: prime)
  }

  public init(a: BigInt, b: BigInt, p: BigInt, x: BigInt?, y: BigInt?) throws {
    // Use the helper function to create FiniteElements from BigInt
    let finiteA = FiniteElement(value: a, prime: p)
    let finiteB = FiniteElement(value: b, prime: p)

    // Handle the optional x and y values
    let finiteX = try ECCPoint.createFiniteElement(from: x, prime: p)
    let finiteY = try ECCPoint.createFiniteElement(from: y, prime: p)

    // Initialize the point with the created FiniteElements
    try self.init(a: finiteA, b: finiteB, x: finiteX, y: finiteY)
  }

  public init(a: FiniteElement, b: FiniteElement, x: FiniteElement?, y: FiniteElement?) throws {
    if let x = x, let y = y {
      // Check that the point is on the elliptic curve y² = x³ + ax + b
      if try y ^^ 2 != x ^^ 3 + a * x + b {
        throw ECDSAError.invalidCurveDefinition("Point is not on the curve.")
      }
    }
    self.x = x
    self.y = y
    self.a = a
    self.b = b
  }

  public static func + (lhs: ECCPoint, rhs: ECCPoint) -> ECCPoint {
    if lhs.x == nil { return rhs }  // Handle identity point (point at infinity)
    if rhs.x == nil { return lhs }  // Handle identity point (point at infinity)

    if lhs.x == rhs.x && lhs.y != rhs.y {  // First case: Both point have the same x -> Point at infinity
      return try! ECCPoint(a: lhs.a, b: lhs.b, x: nil, y: nil)
    }

    if lhs.x != rhs.x {  // Second case: Points are distinct
      let slope = try! (rhs.y! - lhs.y!) / (rhs.x! - lhs.x!)
      let x3 = try! slope ^^ 2 - lhs.x! - rhs.x!
      let y3 = try! slope * (lhs.x! - x3) - lhs.y!
      return try! ECCPoint(a: lhs.a, b: lhs.b, x: x3, y: y3)
    }
    if lhs == rhs {  // Third case: We need to compute the tangent
      let slope = try! (3 * (lhs.x! ^^ 2) + lhs.a) / (2 * lhs.y!)
      let x3 = try! (slope ^^ 2) - 2 * lhs.x!
      let y3 = try! slope * (lhs.x! - x3) - lhs.y!
      return try! ECCPoint(a: lhs.a, b: lhs.b, x: x3, y: y3)
    }

    return lhs
  }

  public static func * (lhs: BigInt, rhs: ECCPoint) -> ECCPoint {
    if rhs.x == nil { return rhs }  // Identity point, return immediately
    var result = try! ECCPoint(a: rhs.a, b: rhs.b, x: rhs.x, y: rhs.y)

    for _ in 0..<lhs - 1 {
      result = result + rhs
    }

    return result
  }
  public static func * (lhs: ECCPoint, rhs: BigInt) -> ECCPoint {
    if lhs.x == nil { return lhs }
    var result = try! ECCPoint(a: lhs.a, b: lhs.b, x: lhs.x, y: lhs.y)
    for _ in 0..<rhs - 1 {

      result = result + lhs
    }

    return result
  }
}