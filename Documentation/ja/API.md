# API

- `KLCalendarLaneEvent`: ジェネリック ID、開始・終了日時、安定した `sortKey`。
- `KLCalendarLaneConfiguration`: カレンダー、行あたりの日数、レーン上限、終了境界。
- `KLEventEndBoundary`: `.exclusive` は午前0時の終了日を除外し、`.inclusive` は含めます。
- `KLCalendarLaneEngine`: 半開区間のレイアウトを計算します。
- `KLCalendarLaneLayout`: セグメント、決定的な overflow ID、日単位クエリを公開します。
- `KLCalendarLaneSegment`: 行内バー、レーン、両端の角丸情報です。

## レイアウトを作る

表示するグリッドの範囲とイベントを`KLCalendarLaneEngine.layout`に渡します。エンジンはカレンダー単位に日付を正規化し、重なるイベントをレーンに割り当て、描画用のセグメントを返します。

```swift
let layout = KLCalendarLaneEngine().layout(
    events,
    in: startOfMonth..<startOfNextMonth,
    configuration: .init(calendar: calendar, daysPerRow: 7, maximumLaneCount: 3)
)
```

`startColumn`と`endColumn`は半開区間です。終了列が4のセグメントは1、2、3列を使用します。`rowIndex`は週の行、`lane`はその行の縦方向のレーンです。

## 終了日とオーバーフロー

終了日を表示しない午前0時終了のイベントには`KLEventEndBoundary.exclusive`を使います。終了日自体も表示する場合は`.inclusive`を使います。`maximumLaneCount`を超えたイベントは`overflowEventIDs`に入り、既存のセグメントには重なりません。

`coveredLaneCount(on:)`は日付セルのオーバーフロー表示に、`segments(startingOn:)`はセル内の描画に使います。どちらも計算済みのレイアウトを参照します。

## 入力の条件

イベントには有効な期間が必要です。開始日と期間が同じイベントには異なる`sortKey`を設定してください。エンジンは表示文字列から識別子を推測しません。更新時もIDと`sortKey`を維持すると、SwiftUIは影響を受けたセグメントだけを更新できます。
