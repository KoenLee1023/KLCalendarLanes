// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MonthLane",
    platforms: [.macOS(.v14)],
    dependencies: [.package(path: "../..")],
    targets: [
        .executableTarget(
            name: "MonthLaneApp",
            dependencies: [
                .product(name: "KLCalendarLanes", package: "KLCalendarLanes"),
            ]
        ),
    ]
)
