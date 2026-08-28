# Getting Started

Create host-owned events and pass the visible grid interval plus its calendar:

```swift
let layout = KLCalendarLaneEngine().layout(
    events: events,
    in: week,
    configuration: .init(calendar: calendar, maximumLaneCount: 2)
)
```

Render bars from `layout.segments(startingOn:)`. Keep titles, colors, and single-day rows in the host. Reserve bar height with `coveredLaneCount(on:)`.
