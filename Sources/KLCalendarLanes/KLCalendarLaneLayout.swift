import Foundation

/// The deterministic lane placement for an interval of calendar days.
public struct KLCalendarLaneLayout<ID: Hashable & Sendable>: Sendable {
    public let segments: [KLCalendarLaneSegment<ID>]
    public let overflowEventIDs: [ID]

    private let calendar: Calendar
    private let coveredLaneCountByDay: [Date: Int]
    private let intervalStart: Date
    private let daysPerRow: Int

    init(
        segments: [KLCalendarLaneSegment<ID>],
        overflowEventIDs: [ID],
        calendar: Calendar,
        coveredLaneCountByDay: [Date: Int],
        intervalStart: Date,
        daysPerRow: Int
    ) {
        self.segments = segments
        self.overflowEventIDs = overflowEventIDs
        self.calendar = calendar
        self.coveredLaneCountByDay = coveredLaneCountByDay
        self.intervalStart = intervalStart
        self.daysPerRow = daysPerRow
    }

    /// Returns the count of lanes occupied by multi-day event bars on a day.
    public func coveredLaneCount(on date: Date) -> Int {
        coveredLaneCountByDay[calendar.startOfDay(for: date)] ?? 0
    }

    /// Returns segments whose bar begins on the supplied calendar day.
    public func segments(startingOn date: Date) -> [KLCalendarLaneSegment<ID>] {
        let requestedDay = calendar.startOfDay(for: date)
        return segments.filter { segment in
            segmentStartDate(segment) == requestedDay
        }
    }

    private func segmentStartDate(_ segment: KLCalendarLaneSegment<ID>) -> Date {
        calendar.date(
            byAdding: .day,
            value: segment.rowIndex * daysPerRow + segment.startColumn,
            to: intervalStartDate
        ) ?? intervalStartDate
    }

    private var intervalStartDate: Date {
        intervalStart
    }
}
