import Foundation
import Testing
@testable import KLCalendarLanes

@Test func `cross row event keeps boundary semantics`() {
    let calendar = TestCalendar.gregorianUTC
    let interval = DateInterval(
        start: TestCalendar.date(2026, 8, 2),
        end: TestCalendar.date(2026, 8, 16)
    )
    let event = laneEvent(
        "cross-row",
        start: TestCalendar.date(2026, 8, 7),
        end: TestCalendar.date(2026, 8, 11)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [event],
        in: interval,
        configuration: .init(calendar: calendar)
    )

    #expect(layout.segments.count == 2)
    #expect(layout.segments[0].rowIndex == 0)
    #expect(layout.segments[0].startColumn == 5)
    #expect(layout.segments[0].endColumn == 6)
    #expect(layout.segments[0].roundsLeadingCorners)
    #expect(!layout.segments[0].roundsTrailingCorners)
    #expect(layout.segments[1].rowIndex == 1)
    #expect(layout.segments[1].startColumn == 0)
    #expect(layout.segments[1].endColumn == 1)
    #expect(!layout.segments[1].roundsLeadingCorners)
    #expect(layout.segments[1].roundsTrailingCorners)
    #expect(layout.segments(startingOn: TestCalendar.date(2026, 8, 9)).count == 1)
}

@Test func `overlapping ranges receive separate lanes`() {
    let events = [
        laneEvent("long", start: TestCalendar.date(2026, 8, 2), end: TestCalendar.date(2026, 8, 8)),
        laneEvent("short", start: TestCalendar.date(2026, 8, 4), end: TestCalendar.date(2026, 8, 7)),
    ]

    let layout = KLCalendarLaneEngine().layout(
        events: events,
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(layout.segments.map(\.lane) == [0, 1])
}

@Test func `separated ranges share a lane`() {
    let events = [
        laneEvent("early", start: TestCalendar.date(2026, 8, 2), end: TestCalendar.date(2026, 8, 4)),
        laneEvent("late", start: TestCalendar.date(2026, 8, 5), end: TestCalendar.date(2026, 8, 7)),
    ]

    let layout = KLCalendarLaneEngine().layout(
        events: events,
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(layout.segments.map(\.lane) == [0, 0])
}

@Test func `exclusive midnight end excludes ending day`() {
    let event = laneEvent(
        "exclusive",
        start: TestCalendar.date(2026, 8, 3),
        end: TestCalendar.date(2026, 8, 5)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [event],
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(layout.segments[0].startColumn == 1)
    #expect(layout.segments[0].endColumn == 2)
    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 8, 5)) == 0)
}

@Test func `inclusive end includes ending day`() {
    let event = laneEvent(
        "inclusive",
        start: TestCalendar.date(2026, 8, 3),
        end: TestCalendar.date(2026, 8, 5)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [event],
        in: TestCalendar.week,
        configuration: .init(
            calendar: TestCalendar.gregorianUTC,
            endBoundary: .inclusive
        )
    )

    #expect(layout.segments[0].startColumn == 1)
    #expect(layout.segments[0].endColumn == 3)
    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 8, 5)) == 1)
}

@Test func `all day range spans daylight saving transition`() {
    let calendar = TestCalendar.calendar(timeZoneID: "America/Los_Angeles")
    let event = laneEvent(
        "dst",
        start: TestCalendar.date(2026, 3, 7, calendar: calendar),
        end: TestCalendar.date(2026, 3, 10, calendar: calendar)
    )
    let interval = DateInterval(
        start: TestCalendar.date(2026, 3, 1, calendar: calendar),
        end: TestCalendar.date(2026, 3, 15, calendar: calendar)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [event],
        in: interval,
        configuration: .init(calendar: calendar)
    )

    #expect(layout.segments.count == 2)
    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 3, 8, calendar: calendar)) == 1)
    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 3, 10, calendar: calendar)) == 0)
}

@Test func `first weekday determines event column`() {
    let sundayCalendar = TestCalendar.calendar(firstWeekday: 1)
    let mondayCalendar = TestCalendar.calendar(firstWeekday: 2)
    let event = laneEvent(
        "weekday",
        start: TestCalendar.date(2026, 8, 2),
        end: TestCalendar.date(2026, 8, 4)
    )
    let sundayWeek = sundayCalendar.dateInterval(
        of: .weekOfYear,
        for: TestCalendar.date(2026, 8, 2)
    )
    let mondayWeek = mondayCalendar.dateInterval(
        of: .weekOfYear,
        for: TestCalendar.date(2026, 8, 2)
    )

    let sundayLayout = KLCalendarLaneEngine().layout(
        events: [event],
        in: requireInterval(sundayWeek),
        configuration: .init(calendar: sundayCalendar)
    )
    let mondayLayout = KLCalendarLaneEngine().layout(
        events: [event],
        in: requireInterval(mondayWeek),
        configuration: .init(calendar: mondayCalendar)
    )

    #expect(sundayLayout.segments[0].startColumn == 0)
    #expect(mondayLayout.segments[0].startColumn == 6)
}

@Test func `capacity overflow follows deterministic event order`() {
    let events = [
        laneEvent("third", start: TestCalendar.date(2026, 8, 3), end: TestCalendar.date(2026, 8, 7)),
        laneEvent("first", start: TestCalendar.date(2026, 8, 2), end: TestCalendar.date(2026, 8, 8)),
        laneEvent("second", start: TestCalendar.date(2026, 8, 3), end: TestCalendar.date(2026, 8, 7)),
    ]

    let layout = KLCalendarLaneEngine().layout(
        events: events,
        in: TestCalendar.week,
        configuration: .init(
            calendar: TestCalendar.gregorianUTC,
            maximumLaneCount: 1
        )
    )

    #expect(layout.segments.map(\.id) == ["first"])
    #expect(layout.overflowEventIDs == ["second", "third"])
}

@Test func `total coverage duration determines placement before clipping`() {
    let longEvent = laneEvent(
        "long",
        start: TestCalendar.date(2026, 7, 1),
        end: TestCalendar.date(2026, 8, 4)
    )
    let visibleEvent = laneEvent(
        "visible",
        start: TestCalendar.date(2026, 8, 2),
        end: TestCalendar.date(2026, 8, 9)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [visibleEvent, longEvent],
        in: TestCalendar.week,
        configuration: .init(
            calendar: TestCalendar.gregorianUTC,
            maximumLaneCount: 1
        )
    )

    #expect(layout.segments.map(\.id) == ["long"])
    #expect(layout.overflowEventIDs == ["visible"])
}

@Test func `sort key resolves equal stable IDs`() {
    let first = stableEvent(
        id: StableID(value: 1),
        sortKey: "omega"
    )
    let second = stableEvent(
        id: StableID(value: 2),
        sortKey: "alpha"
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [first, second],
        in: TestCalendar.week,
        configuration: .init(
            calendar: TestCalendar.gregorianUTC,
            maximumLaneCount: 1
        )
    )

    #expect(layout.overflowEventIDs == [StableID(value: 1)])
}

@Test func `duplicate ordering keys are rejected in either input order`() {
    let first = stableEvent(
        id: StableID(value: 1),
        sortKey: "duplicate"
    )
    let second = stableEvent(
        id: StableID(value: 2),
        sortKey: "duplicate"
    )
    let configuration = KLCalendarLaneConfiguration(
        calendar: TestCalendar.gregorianUTC,
        maximumLaneCount: 1
    )
    let engine = KLCalendarLaneEngine()

    #expect(!engine.orderingKeysAreUnambiguous(
        events: [first, second],
        in: TestCalendar.week,
        configuration: configuration
    ))
    #expect(!engine.orderingKeysAreUnambiguous(
        events: [second, first],
        in: TestCalendar.week,
        configuration: configuration
    ))
}

@Test func `distinct sort keys keep reflected ID collisions input independent`() {
    let first = stableEvent(
        id: StableID(value: 1),
        sortKey: "omega"
    )
    let second = stableEvent(
        id: StableID(value: 2),
        sortKey: "alpha"
    )
    let configuration = KLCalendarLaneConfiguration(
        calendar: TestCalendar.gregorianUTC,
        maximumLaneCount: 1
    )
    let engine = KLCalendarLaneEngine()

    let forward = engine.layout(
        events: [first, second],
        in: TestCalendar.week,
        configuration: configuration
    )
    let reverse = engine.layout(
        events: [second, first],
        in: TestCalendar.week,
        configuration: configuration
    )

    #expect(forward.segments == reverse.segments)
    #expect(forward.overflowEventIDs == reverse.overflowEventIDs)
}

@Test func `empty input produces an empty layout`() {
    let layout: KLCalendarLaneLayout<String> = KLCalendarLaneEngine().layout(
        events: [KLCalendarLaneEvent<String>](),
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(layout.segments.isEmpty)
    #expect(layout.overflowEventIDs.isEmpty)
    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 8, 5)) == 0)
}

@Test func `events outside the requested interval do not enter layout`() {
    let event = laneEvent(
        "outside",
        start: TestCalendar.date(2026, 8, 16),
        end: TestCalendar.date(2026, 8, 19)
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [event],
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(layout.segments.isEmpty)
    #expect(layout.overflowEventIDs.isEmpty)
}

private func laneEvent(
    _ id: String,
    start: Date,
    end: Date,
    sortKey: String? = nil
) -> KLCalendarLaneEvent<String> {
    KLCalendarLaneEvent(
        id: id,
        startDate: start,
        endDate: end,
        sortKey: sortKey ?? id
    )
}

private func requireInterval(_ interval: DateInterval?) -> DateInterval {
    if let interval {
        return interval
    }
    fatalError("Expected a Gregorian week interval.")
}

private struct StableID: Hashable, Sendable, CustomDebugStringConvertible, CustomStringConvertible {
    let value: Int

    var debugDescription: String { "stable" }
    var description: String { "stable" }
}

private func stableEvent(
    id: StableID,
    sortKey: String
) -> KLCalendarLaneEvent<StableID> {
    KLCalendarLaneEvent(
        id: id,
        startDate: TestCalendar.date(2026, 8, 3),
        endDate: TestCalendar.date(2026, 8, 6),
        sortKey: sortKey
    )
}
