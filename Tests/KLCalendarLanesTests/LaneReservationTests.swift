import Foundation
import Testing
@testable import KLCalendarLanes

@Test func `multi day event reserves its lane beside a same day event`() throws {
    let calendar = TestCalendar.gregorianUTC
    let week = try #require(
        calendar.dateInterval(
            of: .weekOfYear,
            for: TestCalendar.date(2026, 8, 5)
        )
    )
    let range = KLCalendarLaneEvent(
        id: "range",
        startDate: TestCalendar.date(2026, 8, 3),
        endDate: TestCalendar.date(2026, 8, 8),
        sortKey: "range"
    )
    let single = KLCalendarLaneEvent(
        id: "single",
        startDate: TestCalendar.date(2026, 8, 5),
        endDate: TestCalendar.date(2026, 8, 6),
        sortKey: "single"
    )

    let layout = KLCalendarLaneEngine().layout(
        events: [single, range],
        in: week,
        configuration: .init(calendar: calendar)
    )

    #expect(layout.coveredLaneCount(on: TestCalendar.date(2026, 8, 5)) == 1)
    #expect(layout.segments.map(\.id).contains("range"))
}

@Test func `input order does not change lanes`() {
    let fixture = TestCalendar.overlappingEvents
    let forward = KLCalendarLaneEngine().layout(
        events: fixture,
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )
    let reverse = KLCalendarLaneEngine().layout(
        events: fixture.reversed(),
        in: TestCalendar.week,
        configuration: .init(calendar: TestCalendar.gregorianUTC)
    )

    #expect(forward.segments == reverse.segments)
}
