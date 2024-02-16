import XCTest
import Foundation
@testable import Version

final class VersionTests: XCTestCase {
    
    func testEquality() {
        let versionsEq: [(Version, Version)] = [
            (Version(1,2,3,4), Version(1,2,3,4)),
            (Version(4,5,6,123), Version(4,5,6,123)),
        ]
        
        let versionsLess: [(Version, Version)] = [
            (Version(1,2,3,4), Version(1,2,3,123)),
            (Version(1,2,3,4), Version(2,2,3,123)),
            (Version(4,5,6,123), Version(4,6,6,123)),
            (Version(4,5,6,123), Version(4,5,7,123)),
        ]
        
        let versionsGreater: [(Version, Version)] = [
            (Version(1,2,3,400), Version(1,2,3,123)),
            (Version(3,2,3,4), Version(2,2,3,123)),
            (Version(4,7,6,123), Version(4,6,6,123)),
            (Version(4,5,8,123), Version(4,5,7,123)),
        ]

        for (v1, v2) in versionsEq {
            XCTAssertEqual(v1, v2)
        }
        for (v1, v2) in versionsLess {
            XCTAssertLessThanOrEqual(v1, v2)
        }
        for (v1, v2) in versionsGreater {
            XCTAssertGreaterThanOrEqual(v1, v2)
        }
    }

    func testDescription() {
        let v = Version("123.234.345.1011")
        XCTAssertEqual(v?.description, "123.234.345.1011")
        XCTAssertEqual(v?.major, 123)
        XCTAssertEqual(v?.minor, 234)
        XCTAssertEqual(v?.patch, 345)
        XCTAssertEqual(v?.build, 1011)
    }
    
    func testFromString() {
        XCTAssertNil(Version(""))
        XCTAssertNil(Version("1"))
        XCTAssertNil(Version("1.2"))
        XCTAssertNil(Version("1.2.3"))
        
        XCTAssertNotNil(Version("1.2.3.4"))
    }
    
    func testRange() {
        switch Version(1,2,4,0) {
        case Version(1,2,3,0)..<Version(2,3,4,0):
            break
        default:
            XCTFail()
        }

        switch Version(1,2,4,0) {
        case Version(1,2,3,0)..<Version(2,3,4,0):
            break
        case Version(1,2,5,0)..<Version(1,2,6,0):
            XCTFail()
        default:
            XCTFail()
        }

        switch Version(1,2,4,0) {
        case Version(1,2,3,0)..<Version(1,2,4,0):
            XCTFail()
        case Version(1,2,5,0)..<Version(1,2,6,0):
            XCTFail()
        default:
            break
        }

        switch Version(1,2,4,0) {
        case Version(1,2,5,0)..<Version(2,0,0,0):
            XCTFail()
        case Version(2,0,0,0)..<Version(2,2,6,0):
            XCTFail()
        case Version(0,0,1,0)..<Version(0,9,6,0):
            XCTFail()
        default:
            break
        }
    }
    
    func testContains() {
            let range: Range<Version> = Version(1,0,0,0)..<Version(2,0,0,0)

            XCTAssertTrue(range.contains(Version(1,0,0,0)))
            XCTAssertTrue(range.contains(Version(1,5,0,0)))
            XCTAssertTrue(range.contains(Version(1,9,99999,0)))
            XCTAssertTrue(range.contains(Version(1,9,99999,0)))

            XCTAssertFalse(range.contains(Version(0,10,0,0)))
            XCTAssertFalse(range.contains(Version(2,0,0,0)))
    }
    func testContains2() {
        //MARK: closed ranges
        
            let range: ClosedRange<Version> = Version(1,0,0,0)...Version(1,1,0,0)
            XCTAssertTrue(range.contains(Version(1,0,0,0)))
            XCTAssertTrue(range.contains(Version(1,0,9,0)))
            XCTAssertTrue(range.contains(Version(1,1,0,0)))

            XCTAssertFalse(range.contains(Version(1,2,0,0)))
            XCTAssertFalse(range.contains(Version(1,5,0,0)))
            XCTAssertFalse(range.contains(Version(2,0,0,0)))
    }
    
    func testInitializers() {
        let v1 = Version(1,0,0,0)
        let v2 = Version("1.0.0.0")
        XCTAssertEqual(v1, v2)
    }
    
    func testTolerantIntiliazer() {
        XCTAssertEqual(Version(tolerant: "1"), Version(1,0,0,0))
        XCTAssertEqual(Version(tolerant: "v1.0"), Version(1,0,0,0))
        XCTAssertEqual(Version(tolerant: "1.0.0"), Version(1,0,0,0))
    }
    
    func testCodable() throws {
        let input = [Version.null]
        let data = try JSONEncoder().encode(input)
        let output = try JSONDecoder().decode([Version].self, from: data)
        XCTAssertEqual(input, output)

        XCTAssertEqual(String(data: data, encoding: .utf8), "[\"0.0.0.0\"]")

        let corruptData = try JSONEncoder().encode(["1.2.c"])
        XCTAssertThrowsError(try JSONDecoder().decode([Version].self, from: corruptData))
    }
    
    func testCodableWithTolerantInitializer() throws {
        let versionString = "1.2"
        let input = try JSONEncoder().encode([versionString])

        let encoder = JSONDecoder()
        XCTAssertThrowsError(try encoder.decode([Version].self, from: input))
        encoder.userInfo[.decodingMethod] = DecodingMethod.tolerant
        XCTAssertNoThrow(try encoder.decode([Version].self, from: input))
    }
}
