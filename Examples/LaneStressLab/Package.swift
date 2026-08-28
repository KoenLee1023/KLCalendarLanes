// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LaneStressLab",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "LaneStressLabApp",
            dependencies: [
                .product(name: "KLCalendarLanes", package: "KLCalendarLanes"),
            ]
        ),
    ]
)
