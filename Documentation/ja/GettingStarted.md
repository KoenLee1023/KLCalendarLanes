# はじめに

ホストイベントを `KLCalendarLaneEvent` に変換し、表示区間とカレンダーを渡します。

```swift
let layout = KLCalendarLaneEngine().layout(
    events: events,
    in: week,
    configuration: .init(calendar: calendar, maximumLaneCount: 2)
)
```

バーは `segments(startingOn:)` から描画します。タイトル、色、単日イベント行はホストが保持し、`coveredLaneCount(on:)` で必要な高さを確保します。
