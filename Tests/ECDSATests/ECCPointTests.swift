import XCTest
@testable import ECDSA

final class ECCPointTests: XCTestCase {

    func testInvalidPointInitialization() {
        // Arrange
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        let x = FiniteElement(value: 200, prime: 223)
        let y = FiniteElement(value: 119, prime: 223)
        
        // Act & Assert
        XCTAssertThrowsError(try ECCPoint(a: a, b: b, x: x, y: y)) { error in
            XCTAssertEqual(error as? ECDSAError, .invalidCurveDefinition("Point is not on the curve."))
        }
    }

        func testPointAdditionWithIdentityPoint() throws {
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        let p1 = try ECCPoint(a: a, b: b, x: FiniteElement(value: 192, prime: 223), y: FiniteElement(value: 105, prime: 223))
        let infinity = try ECCPoint(a: a, b: b, x: nil, y: nil)

        XCTAssertEqual(p1 + infinity, p1)
        XCTAssertEqual(infinity + p1, p1)
    }

    func testPointAdditionWithInversePoints() throws {
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        let p1 = try ECCPoint(a: a, b: b, x: FiniteElement(value: 47, prime: 223), y: FiniteElement(value: 71, prime: 223))
        let p2 = try ECCPoint(a: a, b: b, x: FiniteElement(value: 47, prime: 223), y: FiniteElement(value: 152, prime: 223)) // Inverse of p1

        // Adding a point and its inverse should result in the identity point
        let result = p1 + p2
        XCTAssertNil(result.x)
        XCTAssertNil(result.y)
    }

    func testPointAdditionWithDistinctPoints() throws {
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        let p1 = try ECCPoint(a: a, b: b, x: FiniteElement(value: 170, prime: 223), y: FiniteElement(value: 142, prime: 223))
        let p2 = try ECCPoint(a: a, b: b, x: FiniteElement(value: 60, prime: 223), y: FiniteElement(value: 139, prime: 223))

        let expected = try ECCPoint(a: a, b: b, x: FiniteElement(value: 220, prime: 223), y: FiniteElement(value: 181, prime: 223))

        XCTAssertEqual(p1 + p2, expected)
    }

    func testPointDoubling() throws {
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        let p = try ECCPoint(a: a, b: b, x: FiniteElement(value: 192, prime: 223), y: FiniteElement(value: 105, prime: 223))

        let expected = try ECCPoint(a: a, b: b, x: FiniteElement(value: 49, prime: 223), y: FiniteElement(value: 71, prime: 223))

        XCTAssertEqual(p + p, expected)
    }

    func testPointAdditionFailsForInvalidPoints() throws {
        let a = FiniteElement(value: 0, prime: 223)
        let b = FiniteElement(value: 7, prime: 223)
        
        XCTAssertThrowsError(try ECCPoint(a: a, b: b, x: FiniteElement(value: 1, prime: 223), y: FiniteElement(value: 1, prime: 223))) { error in
            XCTAssertEqual(error as? ECDSAError, .invalidCurveDefinition("Point is not on the curve."))
        }
    }
}