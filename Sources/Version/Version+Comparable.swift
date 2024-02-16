extension Version: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(major)
        hasher.combine(minor)
        hasher.combine(patch)
        hasher.combine(build)
    }
}

extension Version: Equatable {
    /// Compares the provided versions *without* comparing any build-metadata
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch && lhs.build == rhs.build
    }
}

extension Version: Comparable {
    func isEqualWithoutPrerelease(_ other: Version) -> Bool {
        return major == other.major && minor == other.minor && patch == other.patch && build == other.build
    }

    /**
     `1.0.0` is less than `1.0.1`
     - Returns: `true` if `lhs` is less than `rhs`
     */
    public static func < (lhs: Version, rhs: Version) -> Bool {
        let lhsComparators = [lhs.major, lhs.minor, lhs.patch, lhs.build]
        let rhsComparators = [rhs.major, rhs.minor, rhs.patch, rhs.build]

        return lhsComparators.lexicographicallyPrecedes(rhsComparators)
    }
}

