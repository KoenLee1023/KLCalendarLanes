# KLCalendarLanes

> Languages: [English](README.md) · [简体中文](Documentation/zh-Hans/README.md) · [繁體中文](Documentation/zh-Hant/README.md) · [日本語](Documentation/ja/README.md) · [한국어](Documentation/ko/README.md)

`KLCalendarLanes` assigns deterministic lanes to multi-day all-day events in a calendar grid. It solves the part of a calendar layout that is easy to get wrong when a range overlaps a single-day event or another range. The package only calculates placement. It does not render dates, colors, labels, or event cells.

```swift
let layout = KLCalendarLaneEngine().layout(
    events: [
        KLCalendarLaneEvent(
            id: "holiday",
            startDate: startDate,
            endDate: endDate,
            sortKey: "holiday"
        )
    ],
    in: week,
    configuration: KLCalendarLaneConfiguration(
        calendar: calendar,
        maximumLaneCount: 2,
        endBoundary: .inclusive
    )
)

let reservedRows = layout.coveredLaneCount(on: date)
```

## Public API

`KLCalendarLaneEvent` is the input value. It contains a host event ID, `startDate`, `endDate`, and `sortKey`. The ID is preserved in every output segment, so a host can map a segment back to its model without using array positions.

`KLCalendarLaneConfiguration` defines the `Calendar`, `daysPerRow`, `maximumLaneCount`, and `KLEventEndBoundary`. The boundary determines whether an end date is treated as part of the event coverage or as the first date after it.

`KLCalendarLaneEngine.layout(events:in:configuration:)` returns `KLCalendarLaneLayout`. Its `segments` describe row, column range, lane, and rounded leading or trailing corners. `overflowEventIDs` identifies events that could not be assigned within the configured lane limit.

Use `coveredLaneCount(on:)` to reserve vertical space for a date before rendering another event row. Use `segments(startingOn:)` when a grid cell only needs the bars that begin on that date.

## Installation

```swift
dependencies: [
    .package(
        url: "https://github.com/KoenLee1023/KLCalendarLanes.git",
        from: "0.1.0"
    )
]
```

The package has no UI framework dependency and can be used from a SwiftUI or UIKit calendar implementation.

## Boundaries

The engine does not normalize host event data, detect duplicate IDs, or decide how overflow should look. Validate event ranges in the host and provide a visual treatment for IDs returned in `overflowEventIDs`.

See [English documentation](Documentation/en/README.md) or the localized directories for 简体中文, 繁體中文, 日本語, and 한국어.

## Demos

- [Month lane demo](Examples/MonthLane)
- [Lane stress demo](Examples/LaneStressLab)

## Requirements

- iOS 17 or later
- macOS 14 or later
- Swift 6.0 or later
- MIT License

API Documentation: [DocC](https://labs.wondays.space/documentation/en/klcalendarlanes)
