public struct ECCPoint: Equatable {
  public var x: FiniteElement?
  public var y: FiniteElement?

  public var a: FiniteElement
  public var b: FiniteElement

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
    if lhs == rhs{  // Third case: We need to compute the tangent
      let slope = try! (3 * (lhs.x! ^^ 2) + lhs.a) / (2 * lhs.y!)
      let x3 = try! (slope ^^ 2) - 2 * lhs.x!
      let y3 = try! slope * (lhs.x! - x3) - lhs.y!
      return try! ECCPoint(a: lhs.a, b: lhs.b, x: x3, y: y3)
    }

    return lhs
  }

  public static func * (lhs: Int64, rhs: ECCPoint) -> ECCPoint {
    if rhs.x == nil { return rhs }  // Identity point, return immediately
    var result = try! ECCPoint(a: rhs.a, b: rhs.b, x: rhs.x, y: rhs.y)

    for _ in 0..<lhs-1 {
      result = result + rhs
    }

    return result
  }
  public static func * (lhs: ECCPoint, rhs: Int64) -> ECCPoint {
    if lhs.x == nil { return lhs }
    var result = try! ECCPoint(a: lhs.a, b: lhs.b, x: lhs.x, y: lhs.y)
    for _ in 0..<rhs-1 {

      result = result + lhs
    }

    return result
  }
}
