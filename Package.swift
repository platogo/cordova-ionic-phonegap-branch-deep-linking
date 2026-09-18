// swift-tools-version:5.9

import PackageDescription

let branchSDKVersion: Version = "3.14.0"

let package = Package(
    name: "branch-cordova-sdk",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "branch-cordova-sdk",
            targets: ["branch-cordova-sdk"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apache/cordova-ios.git", branch: "master"),
        .package(url: "https://github.com/BranchMetrics/ios-branch-sdk-spm.git", exact: branchSDKVersion)
    ],
    targets: [
        .target(
            name: "branch-cordova-sdk",
            dependencies: [
                .product(name: "Cordova", package: "cordova-ios"),
                .product(name: "BranchSDK", package: "ios-branch-sdk-spm"),
            ],
            path: "src/ios",
            publicHeadersPath: "."
        )
    ]
)