// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "ScreenTimeApp",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ScreenTimeApp",
            targets: ["ScreenTimeApp"]),
        .executable(
            name: "ScreenTimeAppApp",
            targets: ["ScreenTimeAppApp"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ScreenTimeApp",
            dependencies: [],
            path: "ScreenTimeApp/Sources"),
        .executableTarget(
            name: "ScreenTimeAppApp",
            dependencies: ["ScreenTimeApp"],
            path: "ScreenTimeApp/App"),

    ]
)
