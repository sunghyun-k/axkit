// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "AXKit",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "AXKit", targets: ["AXKit"]),
    ],
    targets: [
        .target(name: "AXKit"),
    ]
)
