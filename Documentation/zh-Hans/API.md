# API

- `KLCalendarLaneEvent`：泛型 ID、起止时间和稳定 `sortKey`。
- `KLCalendarLaneConfiguration`：日历、每行列数、轨道容量和结束边界。
- `KLEventEndBoundary`：`.exclusive` 排除午夜结束当天；`.inclusive` 包含该天。
- `KLCalendarLaneEngine`：为半开网格区间计算布局。
- `KLCalendarLaneLayout`：提供分段、确定性的 overflow ID 和按天查询。
- `KLCalendarLaneSegment`：行内条形、轨道和首尾圆角语义。

## 生成布局

把可见网格区间和事件传给`KLCalendarLaneEngine.layout`。引擎会按日历归一化事件，将重叠事件分配到不同轨道，并返回可以直接渲染的分段。

```swift
let layout = KLCalendarLaneEngine().layout(
    events,
    in: startOfMonth..<startOfNextMonth,
    configuration: .init(calendar: calendar, daysPerRow: 7, maximumLaneCount: 3)
)
```

`startColumn`和`endColumn`使用半开区间。结束列为4的分段会占用第1、2、3列。`rowIndex`表示周行，`lane`表示该行中的垂直轨道。

## 当天结束与溢出

事件在午夜结束且结束日不应显示时使用`KLEventEndBoundary.exclusive`。如果结束日期本身也应显示，则使用`.inclusive`。超过`maximumLaneCount`的事件会放入`overflowEventIDs`，不会覆盖已有分段。

使用`coveredLaneCount(on:)`绘制日期级溢出提示，使用`segments(startingOn:)`填充日期单元格。这两个查询都基于已生成的布局，结果稳定。

## 输入要求

事件必须有有效的时间区间。开始时间和持续时间都相同的事件必须提供不同的`sortKey`。引擎不会从显示文字推断事件身份。刷新数据时保持ID和`sortKey`稳定，SwiftUI就能只更新受影响的分段。
