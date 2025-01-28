import XCTest
@testable import ECDSA

final class FiniteElementTests: XCTestCase {

    // Test addition of two FiniteElement instances
    func testAddition() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let b = FiniteElement(value: 3, prime: 11)
        let sum = try a + b
        XCTAssertEqual(sum.value, 8) // 5 + 3 = 8 mod 11
    }

    // Test subtraction of two FiniteElement instances
    func testSubtraction() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let b = FiniteElement(value: 3, prime: 11)
        let difference = try a - b
        XCTAssertEqual(difference.value, 2) // 5 - 3 = 2 mod 11
    }

    // Test multiplication of two FiniteElement instances
    func testMultiplication() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let b = FiniteElement(value: 3, prime: 11)
        let product = try a * b
        XCTAssertEqual(product.value, 4) // 5 * 3 = 15 mod 11 = 4
    }

    // Test power operation on a FiniteElement instance
    func testPower() throws {
        let a = FiniteElement(value: 2, prime: 11)
        let power = try a ^^ 3
        XCTAssertEqual(power.value, 8) // 2^3 = 8 mod 11
    }

    // Test division of two FiniteElement instances
    func testDivision() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let b = FiniteElement(value: 3, prime: 11)
        let quotient = try a / b
        XCTAssertEqual(quotient.value, 9) // 5 / 3 = 5 * 3^(11-2) mod 11 = 5 * 4 mod 11 = 9
    }

    // Test the neutral element property
    func testNeutralElement() throws{
        let a = FiniteElement(value: 5, prime: 11)
        let neutral = FiniteElement(value: 0, prime: 11)
        let sum = try a + neutral
        XCTAssertEqual(sum.value, a.value) // a + 0 = a
    }

    // Test the multiplicative identity property
    func testMultiplicativeIdentity() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let identity = FiniteElement(value: 1, prime: 11)
        let product = try a * identity
        XCTAssertEqual(product.value, a.value) // a * 1 = a
    }

    // Test the inverse property
    func testInverse() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let inverse = try a ^^ (Int(a.prime) - 2)
        let product = try a * inverse
        XCTAssertEqual(product.value, 1) // a * a^(-1) = 1
    }

    // Test handling of negative values in initialization
    func testNegativeValueInitialization() {
        let a = FiniteElement(value: -5, prime: 11)
        XCTAssertEqual(a.value, 6) // -5 mod 11 = 6
    }

    // Test handling of large values in initialization
    func testLargeValueInitialization() {
        let a = FiniteElement(value: 15, prime: 11)
        XCTAssertEqual(a.value, 4) // 15 mod 11 = 4
    }

    // Test handling of zero in initialization
    func testZeroInitialization() {
        let a = FiniteElement(value: 0, prime: 11)
        XCTAssertEqual(a.value, 0) // 0 mod 11 = 0
    }

    // Test handling of prime value in initialization
    func testPrimeValueInitialization() {
        let a = FiniteElement(value: 11, prime: 11)
        XCTAssertEqual(a.value, 0) // 11 mod 11 = 0
    }

    func testDifferentPrimes() throws {
        let a = FiniteElement(value: 5, prime: 11)
        let b = FiniteElement(value: 3, prime: 13)


        XCTAssertThrowsError(try a - b) { error in
            XCTAssertEqual(error as? ECDSAError, ECDSAError.invalidFiniteElement("Cannot perform operation on FiniteElements with different primes: 11 != 13"))
        }

        XCTAssertThrowsError(try a * b) { error in
            XCTAssertEqual(error as? ECDSAError, ECDSAError.invalidFiniteElement("Cannot perform operation on FiniteElements with different primes: 11 != 13"))
        }

        XCTAssertThrowsError(try a / b) { error in
            XCTAssertEqual(error as? ECDSAError, ECDSAError.invalidFiniteElement("Cannot perform operation on FiniteElements with different primes: 11 != 13"))
        }
    }
}