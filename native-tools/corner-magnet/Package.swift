// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CornerMagnet",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "CornerMagnet", targets: ["CornerMagnet"])
    ],
    targets: [
        .executableTarget(name: "CornerMagnet", path: "Sources/CornerMagnet"),
        .testTarget(name: "CornerMagnetTests", dependencies: ["CornerMagnet"], path: "Tests/CornerMagnetTests")
    ]
)
