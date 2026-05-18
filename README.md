# Version

Swift package for representing and comparing four-component versions (`major.minor.patch.build`).

Requires Swift 6.1+. `Version` and `DecodingMethod` conform to `Sendable`.

## Usage

```swift
import Version

let v1 = Version(1, 2, 3, 4)
let v2 = Version("1.2.3.4")  // strict: exactly four dot-separated integers
let v3 = Version(tolerant: "1.2")  // -> Version(1, 2, 0, 0); optional leading "v"

v1 < v2  // lexicographic comparison on all four components
v1 == Version(1, 2, 3, 4)

let range = Version(1, 0, 0, 0)..<Version(2, 0, 0, 0)
range.contains(v1)

// Codable (strict by default; tolerant via userInfo)
let decoder = JSONDecoder()
decoder.userInfo[.decodingMethod] = DecodingMethod.tolerant
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/avgx/Version.git", from: "1.0.0"),
]
```
