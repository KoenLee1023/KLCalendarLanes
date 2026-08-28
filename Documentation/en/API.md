# API

- `KLCalendarLaneEvent`: generic ID, start, end, and deterministic `sortKey`. For events with the same duration, normalized start day, and reflected ID text, `sortKey` must differ; the engine rejects ambiguous collisions before allocation.
- `KLCalendarLaneConfiguration`: calendar, columns per row, lane capacity, and end-boundary semantics.
- `KLEventEndBoundary`: `.exclusive` excludes a midnight ending day; `.inclusive` includes it.
- `KLCalendarLaneEngine`: calculates a `KLCalendarLaneLayout` for a half-open grid interval.
- `KLCalendarLaneLayout`: exposes segments, deterministic overflow IDs, and day queries.
- `KLCalendarLaneSegment`: a row-local bar with lane and leading/trailing corner flags.

## Building a layout

Pass the visible grid interval and events to `KLCalendarLaneEngine.layout`. The engine normalizes events to calendar days, assigns overlaps to lanes, and returns segments ready for rendering.

```swift
let layout = KLCalendarLaneEngine().layout(
    events,
    in: startOfMonth..<startOfNextMonth,
    configuration: .init(calendar: calendar, daysPerRow: 7, maximumLaneCount: 3)
)
```

`startColumn` and `endColumn` are half-open coordinates. A segment ending at column 4 occupies columns 1, 2, and 3. `rowIndex` identifies the week row; `lane` identifies its vertical track.

## Same-day and overflow behavior

Use `KLEventEndBoundary.exclusive` for an event ending at midnight when the ending day should not appear. Use `.inclusive` when the ending date remains visible. Events beyond `maximumLaneCount` are listed in `overflowEventIDs` instead of being drawn over another segment.

Use `coveredLaneCount(on:)` for a day-level overflow indicator and `segments(startingOn:)` for the segments entering a day cell. Both queries use the computed layout and are deterministic.

## Input requirements

Events need valid intervals. Events with equal starts and durations need distinct `sortKey` values. The engine does not infer identity from display text. Keep IDs and `sortKey` stable during refreshes so SwiftUI can update only affected segments.
