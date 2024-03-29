// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "bearer-auth",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/twof/VaporMailgunService.git", from: "1.5.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "Leaf", "FluentSQLite", "Authentication", "Mailgun"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
