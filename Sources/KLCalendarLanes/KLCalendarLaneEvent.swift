import Foundation

/// An event whose date range may reserve a lane in a calendar grid.
public struct KLCalendarLaneEvent<ID: Hashable & Sendable>: Sendable {
    public let id: ID
    public let startDate: Date
    public let endDate: Date
    /// A stable key that disambiguates events with matching earlier layout keys.
    ///
    /// The engine preconditions that two multi-day events cannot have matching
    /// coverage duration, normalized start day, reflected ID text, and sort key.
    public let sortKey: String

    public init(
        id: ID,
        startDate: Date,
        endDate: Date,
        sortKey: String
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.sortKey = sortKey
    }
}
