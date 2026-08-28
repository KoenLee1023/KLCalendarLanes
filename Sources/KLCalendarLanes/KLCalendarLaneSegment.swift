import Foundation

/// A continuous part of a multi-day event rendered within one grid row.
public struct KLCalendarLaneSegment<ID: Hashable & Sendable>: Identifiable, Hashable, Sendable {
    /// The host-owned event identifier.
    public let id: ID
    public let rowIndex: Int
    public let startColumn: Int
    public let endColumn: Int
    public let lane: Int
    public let roundsLeadingCorners: Bool
    public let roundsTrailingCorners: Bool
    public let eventCoverageStartDate: Date
    public let eventCoverageEndDate: Date

    public init(
        id: ID,
        rowIndex: Int,
        startColumn: Int,
        endColumn: Int,
        lane: Int,
        roundsLeadingCorners: Bool,
        roundsTrailingCorners: Bool,
        eventCoverageStartDate: Date,
        eventCoverageEndDate: Date
    ) {
        self.id = id
        self.rowIndex = rowIndex
        self.startColumn = startColumn
        self.endColumn = endColumn
        self.lane = lane
        self.roundsLeadingCorners = roundsLeadingCorners
        self.roundsTrailingCorners = roundsTrailingCorners
        self.eventCoverageStartDate = eventCoverageStartDate
        self.eventCoverageEndDate = eventCoverageEndDate
    }
}
