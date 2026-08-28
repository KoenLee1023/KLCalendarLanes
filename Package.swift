// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "KLCalendarLanes",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "KLCalendarLanes", targets: ["KLCalendarLanes"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.4.0"
        ),
    ],
    targets: [
        .target(name: "KLCalendarLanes"),
        .testTarget(
            name: "KLCalendarLanesTests",
            dependencies: ["KLCalendarLanes"]
        ),
    ]
)
