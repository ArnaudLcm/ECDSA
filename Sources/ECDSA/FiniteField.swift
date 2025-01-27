/**
@def: A field set (K, +, *) is a group holding 1 set K and 2 closed laws (+, *) respecting the following properties:
    - A neutral element e exists such that for every x in the set, x * e = x
    - * has the multiplicative identity property: 1 exists and for every x in K, x * 1 = x
    - For every x in the set, x' exists such that x * x' = x' * x
    - If an element a exists in the set and 0 is not in the set, a^-1 is also in the set.
**/

infix operator ^^: MultiplicationPrecedence

public struct FiniteElement {

    private var value: Int
    private var prime: Int

    init(value: Int, prime: Int) {
        self.value = value
        self.prime = prime
    }

    static func + (lhs: FiniteElement, rhs: FiniteElement) -> FiniteElement {
        return FiniteElement(value: (lhs.value + rhs.value)%lhs.prime, prime: lhs.prime)
    }


    static func - (lhs: FiniteElement, rhs: FiniteElement) -> FiniteElement {
        return FiniteElement(value: (lhs.value - rhs.value)%lhs.prime, prime: lhs.prime)
    }


    static func * (lhs: FiniteElement, rhs: FiniteElement) -> FiniteElement {
        return FiniteElement(value: (lhs.value * rhs.value)%lhs.prime, prime: lhs.prime)
    }


}