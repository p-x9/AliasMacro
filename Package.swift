// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Alias",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "Alias",
            targets: ["Alias"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git",
                 from: "509.0.0"),
    ],
    targets: [
        .target(
            name: "Alias",
            dependencies: [
                "AliasPlugin",
                "AliasSupport"
            ]
        ),
        .target(
            name: "AliasSupport",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax")
            ]
        ),
        .macro(
            name: "AliasPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                "AliasSupport"
            ]
        ),
        .testTarget(
            name: "AliasTests",
            dependencies: ["Alias"]
        ),
    ]
)
