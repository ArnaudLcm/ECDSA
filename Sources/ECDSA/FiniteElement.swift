import Foundation
import BigInt

/**
@def: A field set (K, +, *) is holding 1 set K and 2 closed laws (+, *) respecting the following properties:
    - A neutral element e exists such that for every x in the set, x * e = x
    - * has the multiplicative identity property: 1 exists and for every x in K, x * 1 = x
    - For every x in the set, x' exists such that x * x' = x' * x
    - If an element a exists in the set and 0 is not in the set, a^-1 is also in the set.
**/

infix operator ^^ : MultiplicationPrecedence

public struct FiniteElement: Equatable, Sendable {

  public var value: BigInt
  public var prime: BigInt

  init(value: BigInt, prime: BigInt) {
    self.value = (value % prime + prime) % prime
    self.prime = prime
  }

  private func ensureSamePrime(_ other: FiniteElement) throws {
    guard self.prime == other.prime else {
      throw ECDSAError.invalidFiniteElement(
        "Cannot perform operation on FiniteElements with different primes: \(self.prime) != \(other.prime)"
      )
    }
  }

  static func + (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
    try lhs.ensureSamePrime(rhs)
    return FiniteElement(value: (lhs.value + rhs.value) % lhs.prime, prime: lhs.prime)
  }

  static func - (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
    try lhs.ensureSamePrime(rhs)
    return FiniteElement(value: (lhs.value - rhs.value) % lhs.prime, prime: lhs.prime)
  }

  static func * (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
    try lhs.ensureSamePrime(rhs)
    return FiniteElement(value: (lhs.value * rhs.value) % lhs.prime, prime: lhs.prime)
  }

  static func * (lhs: BigInt, rhs: FiniteElement) throws -> FiniteElement {
    return FiniteElement(value: (lhs * rhs.value) % rhs.prime, prime: rhs.prime)
  }

  static func * (lhs: FiniteElement, rhs: BigInt) throws -> FiniteElement {
    return FiniteElement(value: (rhs * lhs.value) % lhs.prime, prime: lhs.prime)
  }

  static func ^^ (lhs: FiniteElement, exponent: BigInt) throws -> FiniteElement {

    var result: BigInt = 1
    var base: BigInt = lhs.value
    var exp = exponent

    // Handle negative exponents by computing the modular inverse
    if exp < 0 {
      exp = -exp
      base = try (FiniteElement(value: base, prime: lhs.prime) ^^ (lhs.prime - 2)).value
    }

    // Exponentiation by squaring
    while exp > 0 {
      if exp % 2 == 1 {
        result = (result * base) % lhs.prime
      }
      base = (base * base) % lhs.prime
      exp /= 2
    }

    return FiniteElement(value: result, prime: lhs.prime)
  }
  static func / (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
    try lhs.ensureSamePrime(rhs)

    let inverse = try rhs ^^ (BigInt(rhs.prime) - BigInt(2))
    let res = try lhs * inverse
    return FiniteElement(value: res.value % lhs.prime, prime: lhs.prime)
  }

}
