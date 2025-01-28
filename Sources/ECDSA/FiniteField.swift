import Foundation

/**
@def: A field set (K, +, *) is a group holding 1 set K and 2 closed laws (+, *) respecting the following properties:
    - A neutral element e exists such that for every x in the set, x * e = x
    - * has the multiplicative identity property: 1 exists and for every x in K, x * 1 = x
    - For every x in the set, x' exists such that x * x' = x' * x
    - If an element a exists in the set and 0 is not in the set, a^-1 is also in the set.
**/

infix operator ^^: MultiplicationPrecedence

public struct FiniteElement {

    public var value: Int64
    public var prime: Int64

    init(value: Int64, prime: Int64) {
        // Ensure value is within the range [0, prime-1]
        self.value = (value % prime + prime) % prime
        self.prime = prime
    }

    private func ensureSamePrime(_ other: FiniteElement) throws {
        guard self.prime == other.prime else {
            throw ECDSAError.invalidFiniteElement("Cannot perform operation on FiniteElements with different primes: \(self.prime) != \(other.prime)")
        }
    }

    static func + (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
        try lhs.ensureSamePrime(rhs)
        return FiniteElement(value: (lhs.value + rhs.value) % lhs.prime, prime: lhs.prime)
    }

    static func - (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
        try lhs.ensureSamePrime(rhs)
        return FiniteElement(value: (lhs.value - rhs.value + lhs.prime) % lhs.prime, prime: lhs.prime)
    }

    static func * (lhs: FiniteElement, rhs: FiniteElement) throws -> FiniteElement {
        try lhs.ensureSamePrime(rhs)
        return FiniteElement(value: (lhs.value * rhs.value) % lhs.prime, prime: lhs.prime)
    }

    static func ^^ (lhs: FiniteElement, exponent: Int) throws -> FiniteElement {
        var result: Int64 = 1
        var base = lhs.value
        var exp = exponent

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
        // Compute the modular inverse of rhs.value
        let inverse = try rhs ^^ (Int(rhs.prime) - 2)
        return try lhs * inverse
    }
}