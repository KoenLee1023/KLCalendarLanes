# API

- `KLCalendarLaneEvent`: 제네릭 ID, 시작·종료 날짜, 안정적인 `sortKey`.
- `KLCalendarLaneConfiguration`: 달력, 행당 일수, 레인 용량, 종료 경계.
- `KLEventEndBoundary`: `.exclusive`는 자정 종료일을 제외하고 `.inclusive`는 포함합니다.
- `KLCalendarLaneEngine`: 반열린 격자 구간의 레이아웃을 계산합니다.
- `KLCalendarLaneLayout`: 세그먼트, 결정적인 overflow ID, 일 단위 질의를 제공합니다.
- `KLCalendarLaneSegment`: 행 내부 막대, 레인, 양 끝 모서리 의미를 제공합니다.

## 레이아웃 만들기

표시할 그리드 범위와 이벤트를`KLCalendarLaneEngine.layout`에 전달합니다. 엔진은 캘린더 기준으로 날짜를 정규화하고 겹치는 이벤트를 레인에 배치한 뒤 렌더링할 세그먼트를 반환합니다.

```swift
let layout = KLCalendarLaneEngine().layout(
    events,
    in: startOfMonth..<startOfNextMonth,
    configuration: .init(calendar: calendar, daysPerRow: 7, maximumLaneCount: 3)
)
```

`startColumn`과`endColumn`은 반개 구간입니다. 끝 열이 4인 세그먼트는 1, 2, 3열을 차지합니다. `rowIndex`는 주 행이고`lane`은 해당 행의 세로 트랙입니다.

## 종료일과 오버플로

자정에 끝나며 종료일을 표시하지 않을 이벤트에는`KLEventEndBoundary.exclusive`를 사용합니다. 종료일도 표시하려면`.inclusive`를 사용합니다.`maximumLaneCount`를 넘은 이벤트는`overflowEventIDs`에 기록되며 기존 세그먼트 위에 그리지 않습니다.

`coveredLaneCount(on:)`는 날짜 셀의 오버플로 표시에,`segments(startingOn:)`는 셀 내부 렌더링에 사용합니다. 두 쿼리 모두 계산된 레이아웃을 사용합니다.

## 입력 조건

이벤트에는 유효한 기간이 필요합니다. 시작 시각과 지속 시간이 같은 이벤트에는 서로 다른`sortKey`를 지정해야 합니다. 엔진은 표시 문자열로 ID를 추측하지 않습니다. 갱신할 때도 ID와`sortKey`를 유지하면 SwiftUI가 영향을 받은 세그먼트만 갱신할 수 있습니다.
