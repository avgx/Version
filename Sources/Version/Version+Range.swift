extension ClosedRange where Bound == Version {
    /**
     - Returns: `true` if the provided Version exists within this range.
     */
    public func contains(_ version: Version) -> Bool {
        return version >= lowerBound && version <= upperBound
    }
}

extension Range where Bound == Version {
    /**
     - Returns: `true` if the provided Version exists within this range.
     */
    public func contains(_ version: Version) -> Bool {
        return version >= lowerBound && version < upperBound
    }
}
