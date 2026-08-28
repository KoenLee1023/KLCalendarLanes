# 快速开始

将宿主事件转换为 `KLCalendarLaneEvent`，并传入可见网格区间与日历：

```swift
let layout = KLCalendarLaneEngine().layout(
    events: events,
    in: week,
    configuration: .init(calendar: calendar, maximumLaneCount: 2)
)
```

使用 `segments(startingOn:)` 绘制条形。标题、颜色和单日事件行仍由宿主负责；通过 `coveredLaneCount(on:)` 预留垂直空间。
