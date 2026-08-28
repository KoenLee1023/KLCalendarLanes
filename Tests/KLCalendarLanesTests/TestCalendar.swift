import Foundation
@testable import KLCalendarLanes

enum TestCalendar {
    static let gregorianUTC: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    static let week: DateInterval = {
        if let interval = gregorianUTC.dateInterval(
            of: .weekOfYear,
            for: date(2026, 8, 5)
        ) {
            return interval
        }
        fatalError("Expected a Gregorian week interval.")
    }()

    static let overlappingEvents = [
        KLCalendarLaneEvent(
            id: "long",
            startDate: date(2026, 8, 2),
            endDate: date(2026, 8, 8),
            sortKey: "long"
        ),
        KLCalendarLaneEvent(
            id: "short",
            startDate: date(2026, 8, 4),
            endDate: date(2026, 8, 6),
            sortKey: "short"
        ),
    ]

    static func calendar(
        timeZoneID: String = "UTC",
        firstWeekday: Int = 1
    ) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: timeZoneID) ?? .gmt
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    static func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 0,
        minute: Int = 0,
        calendar: Calendar = gregorianUTC
    ) -> Date {
        let components = DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        if let date = calendar.date(from: components) {
            return date
        }
        fatalError("Expected a valid fixture date.")
    }
}
