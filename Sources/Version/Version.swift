import Foundation

public struct Version {
    /// The major version.
    public let major: Int

    /// The minor version.
    public let minor: Int

    /// The patch version.
    public let patch: Int

    /// The build metadatas (if any).
    public let build: Int

    /**
     Create a version object.
     - Note: Integers are made absolute since negative integers are not allowed, yet it is conventional Swift to take `Int` over `UInt` where possible.
     - Remark: This initializer variant provided for more readable code when initializing with static integers.
     */
    @inlinable
    public init(_ major: Int, _ minor: Int, _ patch: Int, _ build: Int) {
        self.major = abs(major)
        self.minor = abs(minor)
        self.patch = abs(patch)
        self.build = abs(build)
        
        if major < 0 || minor < 0 || patch < 0 || build < 0 {
            print("warning: negative component in version: \(major).\(minor).\(patch).\(build)")
            print("notice: negative components were abs’d")
        }
    }

    /// Represents `0.0.0`
    public static let null = Version(0,0,0,0)
}

extension Version: LosslessStringConvertible {
    /**
     Creates a version object from a string.
     - Note: Returns `nil` if the string is not a valid semantic version.
     - Parameter string: The string to parse.
     */
    public init?(_ string: String) {
        self.init(internal: string)
    }

    public init?<S: StringProtocol>(_ string: S) {
        self.init(internal: string)
    }

    private init?<S: StringProtocol>(internal string: S) {

        let requiredComponents = string
            .split(separator: ".", maxSplits: 3, omittingEmptySubsequences: false)
            .compactMap({ Int($0) })

        guard requiredComponents.count == 4 else { return nil }

        self.major = requiredComponents[0]
        self.minor = requiredComponents[1]
        self.patch = requiredComponents[2]
        self.build = requiredComponents[3]

    }

    /// Returns the lossless string representation of this semantic version.
    public var description: String {
        return "\(major).\(minor).\(patch).\(build)"
    }
}

public extension Version {
    /**
     Creates a version object.
     - Remark: This initializer variant uses a more tolerant parser, eg. `10.1` parses to `Version(10,1,0)`.
     - Remark: This initializer will not recognizer builds-metadata-identifiers.
     - Remark: Tolerates an initial `v` character.
     */
    init?<S: StringProtocol>(tolerant: S) {
        let string = tolerant.dropFirst(tolerant.first == "v" ? 1 : 0)
        
        let maybes = string.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: false).map{ Int($0) }

        guard !maybes.contains(nil), 1...3 ~= maybes.count else {
            return nil
        }

        var requiredComponents = maybes.map{ $0! }
        while requiredComponents.count < 4 {
            requiredComponents.append(0)
        }

        major = requiredComponents[0]
        minor = requiredComponents[1]
        patch = requiredComponents[2]
        build = requiredComponents[3]

    }
}
