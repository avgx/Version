import Foundation
import Testing
@testable import Version

@Test func equality() {
    let versionsEq: [(Version, Version)] = [
        (Version(1, 2, 3, 4), Version(1, 2, 3, 4)),
        (Version(4, 5, 6, 123), Version(4, 5, 6, 123)),
    ]

    let versionsLess: [(Version, Version)] = [
        (Version(1, 2, 3, 4), Version(1, 2, 3, 123)),
        (Version(1, 2, 3, 4), Version(2, 2, 3, 123)),
        (Version(4, 5, 6, 123), Version(4, 6, 6, 123)),
        (Version(4, 5, 6, 123), Version(4, 5, 7, 123)),
    ]

    let versionsGreater: [(Version, Version)] = [
        (Version(1, 2, 3, 400), Version(1, 2, 3, 123)),
        (Version(3, 2, 3, 4), Version(2, 2, 3, 123)),
        (Version(4, 7, 6, 123), Version(4, 6, 6, 123)),
        (Version(4, 5, 8, 123), Version(4, 5, 7, 123)),
    ]

    for (v1, v2) in versionsEq {
        #expect(v1 == v2)
    }
    for (v1, v2) in versionsLess {
        #expect(v1 <= v2)
    }
    for (v1, v2) in versionsGreater {
        #expect(v1 >= v2)
    }
}

@Test func description() {
    let v = Version("123.234.345.1011")
    #expect(v?.description == "123.234.345.1011")
    #expect(v?.major == 123)
    #expect(v?.minor == 234)
    #expect(v?.patch == 345)
    #expect(v?.build == 1011)
}

@Test func fromString() {
    #expect(Version("") == nil)
    #expect(Version("1") == nil)
    #expect(Version("1.2") == nil)
    #expect(Version("1.2.3") == nil)
    #expect(Version("1.2.3.4") != nil)
}

@Test func range() {
    switch Version(1, 2, 4, 0) {
    case Version(1, 2, 3, 0)..<Version(2, 3, 4, 0):
        break
    default:
        Issue.record("Expected range match")
    }

    switch Version(1, 2, 4, 0) {
    case Version(1, 2, 3, 0)..<Version(2, 3, 4, 0):
        break
    case Version(1, 2, 5, 0)..<Version(1, 2, 6, 0):
        Issue.record("Unexpected range match")
    default:
        Issue.record("Expected range match")
    }

    switch Version(1, 2, 4, 0) {
    case Version(1, 2, 3, 0)..<Version(1, 2, 4, 0):
        Issue.record("Unexpected range match")
    case Version(1, 2, 5, 0)..<Version(1, 2, 6, 0):
        Issue.record("Unexpected range match")
    default:
        break
    }

    switch Version(1, 2, 4, 0) {
    case Version(1, 2, 5, 0)..<Version(2, 0, 0, 0):
        Issue.record("Unexpected range match")
    case Version(2, 0, 0, 0)..<Version(2, 2, 6, 0):
        Issue.record("Unexpected range match")
    case Version(0, 0, 1, 0)..<Version(0, 9, 6, 0):
        Issue.record("Unexpected range match")
    default:
        break
    }
}

@Test func containsOpenRange() {
    let range: Range<Version> = Version(1, 0, 0, 0)..<Version(2, 0, 0, 0)

    #expect(range.contains(Version(1, 0, 0, 0)))
    #expect(range.contains(Version(1, 5, 0, 0)))
    #expect(range.contains(Version(1, 9, 99999, 0)))

    #expect(!range.contains(Version(0, 10, 0, 0)))
    #expect(!range.contains(Version(2, 0, 0, 0)))
}

@Test func containsClosedRange() {
    let range: ClosedRange<Version> = Version(1, 0, 0, 0)...Version(1, 1, 0, 0)
    #expect(range.contains(Version(1, 0, 0, 0)))
    #expect(range.contains(Version(1, 0, 9, 0)))
    #expect(range.contains(Version(1, 1, 0, 0)))

    #expect(!range.contains(Version(1, 2, 0, 0)))
    #expect(!range.contains(Version(1, 5, 0, 0)))
    #expect(!range.contains(Version(2, 0, 0, 0)))
}

@Test func initializers() {
    let v1 = Version(1, 0, 0, 0)
    let v2 = Version("1.0.0.0")
    #expect(v1 == v2)
}

@Test func tolerantInitializer() {
    #expect(Version(tolerant: "1") == Version(1, 0, 0, 0))
    #expect(Version(tolerant: "v1.0") == Version(1, 0, 0, 0))
    #expect(Version(tolerant: "1.0.0") == Version(1, 0, 0, 0))
}

@Test func codable() throws {
    let input = [Version.null]
    let data = try JSONEncoder().encode(input)
    let output = try JSONDecoder().decode([Version].self, from: data)
    #expect(input == output)
    #expect(String(data: data, encoding: .utf8) == "[\"0.0.0.0\"]")

    let corruptData = try JSONEncoder().encode(["1.2.c"])
    #expect(throws: (any Error).self) {
        try JSONDecoder().decode([Version].self, from: corruptData)
    }
}

@Test func sendable() {
    assertSendable(Version(1, 2, 3, 4))
    assertSendable(DecodingMethod.strict)
    let version: Version = Version(1, 2, 3, 4)
    let send: @Sendable () -> Version = { version }
    _ = send()
}

private func assertSendable<T: Sendable>(_ value: T) {
    #expect(value as Any? != nil)
}

@Test func codableWithTolerantInitializer() throws {
    let versionString = "1.2"
    let input = try JSONEncoder().encode([versionString])

    let decoder = JSONDecoder()
    #expect(throws: (any Error).self) {
        try decoder.decode([Version].self, from: input)
    }
    decoder.userInfo[.decodingMethod] = DecodingMethod.tolerant
    _ = try decoder.decode([Version].self, from: input)
}
