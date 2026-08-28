# 시작하기

호스트 이벤트를 `KLCalendarLaneEvent`로 변환하고 보이는 구간 및 달력을 전달합니다.

```swift
let layout = KLCalendarLaneEngine().layout(
    events: events,
    in: week,
    configuration: .init(calendar: calendar, maximumLaneCount: 2)
)
```

막대는 `segments(startingOn:)`으로 그립니다. 제목, 색상, 단일 날짜 이벤트 행은 호스트가 보유하며 `coveredLaneCount(on:)`으로 높이를 예약합니다.
