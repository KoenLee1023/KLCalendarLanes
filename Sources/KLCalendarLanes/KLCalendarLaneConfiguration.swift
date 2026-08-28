import Foundation

/// Defines how an event end date contributes calendar-day coverage.
public enum KLEventEndBoundary: Sendable {
    /// The end instant is outside the event range.
    case exclusive

    /// The calendar day containing the end instant remains covered.
    case inclusive
}

/// The grid and date semantics used to calculate calendar lanes.
public struct KLCalendarLaneConfiguration: Sendable {
    public let calendar: Calendar
    public let daysPerRow: Int
    public let maximumLaneCount: Int
    public let endBoundary: KLEventEndBoundary

    public init(
        calendar: Calendar,
        daysPerRow: Int = 7,
        maximumLaneCount: Int = .max,
        endBoundary: KLEventEndBoundary = .exclusive
    ) {
        self.calendar = calendar
        self.daysPerRow = max(1, daysPerRow)
        self.maximumLaneCount = max(0, maximumLaneCount)
        self.endBoundary = endBoundary
    }
}
