import XCTest
import CoreGraphics
@testable import CornerMagnet

final class AttractionMathTests: XCTestCase {
    func testPullsPartwayTowardTargetWhenMovingTowardIt() {
        let next = AttractionMath.nextPoint(
            current: CGPoint(x: 10, y: 10),
            previous: CGPoint(x: 0, y: 10),
            target: CGPoint(x: 30, y: 10),
            radius: 30,
            strength: 0.2
        )
        XCTAssertEqual(next?.x ?? -1, 14, accuracy: 0.001)
        XCTAssertEqual(next?.y ?? -1, 10, accuracy: 0.001)
    }

    func testDoesNotPullWhenMovingAwayFromTarget() {
        let next = AttractionMath.nextPoint(
            current: CGPoint(x: 10, y: 10),
            previous: CGPoint(x: 20, y: 10),
            target: CGPoint(x: 30, y: 10),
            radius: 30,
            strength: 0.2
        )
        XCTAssertNil(next)
    }

    func testDoesNotPullOutsideRadius() {
        let next = AttractionMath.nextPoint(
            current: CGPoint(x: 0, y: 0),
            previous: CGPoint(x: -1, y: 0),
            target: CGPoint(x: 40, y: 0),
            radius: 30,
            strength: 0.2
        )
        XCTAssertNil(next)
    }

    func testStrengthIsBounded() {
        let next = AttractionMath.nextPoint(
            current: CGPoint(x: 10, y: 10),
            previous: CGPoint(x: 0, y: 10),
            target: CGPoint(x: 30, y: 10),
            radius: 30,
            strength: 1
        )
        XCTAssertEqual(next?.x ?? -1, 17, accuracy: 0.001)
    }
}
