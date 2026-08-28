# API

- `KLCalendarLaneEvent`：泛型 ID、起訖時間和穩定 `sortKey`。
- `KLCalendarLaneConfiguration`：日曆、每列欄數、軌道容量和結束邊界。
- `KLEventEndBoundary`：`.exclusive` 排除午夜結束當天；`.inclusive` 包含該日。
- `KLCalendarLaneEngine`：為半開網格區間計算版面。
- `KLCalendarLaneLayout`：提供分段、決定性的 overflow ID 和按日查詢。
- `KLCalendarLaneSegment`：列內事件條、軌道和首尾圓角語意。

## 建立版面

將可見網格區間和事件傳給`KLCalendarLaneEngine.layout`。引擎會依行事曆歸一化事件，將重疊事件分配到不同軌道，並回傳可以直接繪製的分段。

```swift
let layout = KLCalendarLaneEngine().layout(
    events,
    in: startOfMonth..<startOfNextMonth,
    configuration: .init(calendar: calendar, daysPerRow: 7, maximumLaneCount: 3)
)
```

`startColumn`和`endColumn`使用半開區間。結束欄為4的分段會佔用第1、2、3欄。`rowIndex`表示週列，`lane`表示該列中的垂直軌道。

## 當日結束與溢出

事件在午夜結束且結束日不應顯示時使用`KLEventEndBoundary.exclusive`。如果結束日期本身也應顯示，請使用`.inclusive`。超過`maximumLaneCount`的事件會放入`overflowEventIDs`，不會覆蓋現有分段。

使用`coveredLaneCount(on:)`繪製日期層級溢出提示，使用`segments(startingOn:)`填入日期儲存格。兩個查詢都使用已計算的版面，結果穩定。

## 輸入要求

事件必須有有效的時間區間。開始時間和持續時間相同的事件必須提供不同的`sortKey`。引擎不會從顯示文字推斷事件身分。更新資料時保持ID和`sortKey`穩定，SwiftUI便能只更新受影響的分段。
