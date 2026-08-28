# 快速開始

將宿主事件轉換為 `KLCalendarLaneEvent`，並傳入可見網格區間與日曆：

```swift
let layout = KLCalendarLaneEngine().layout(
    events: events,
    in: week,
    configuration: .init(calendar: calendar, maximumLaneCount: 2)
)
```

以 `segments(startingOn:)` 繪製事件條。標題、顏色和單日事件列仍由宿主負責；透過 `coveredLaneCount(on:)` 保留垂直空間。
