import Foundation
import KLCalendarLanes
import SwiftUI

@main
struct MonthLaneApp: App {
    var body: some Scene {
        WindowGroup("Month Lane") {
            MonthLaneView()
                .frame(minWidth: DemoMetrics.minimumWindowWidth, minHeight: DemoMetrics.minimumWindowHeight)
        }
    }
}

private struct MonthLaneView: View {
    private let calendar = DemoCalendar.calendar
    private let week = DemoCalendar.week
    private let events = DemoCalendar.events

    private var layout: KLCalendarLaneLayout<String> {
        KLCalendarLaneEngine().layout(
            events: events.map(\.event),
            in: week,
            configuration: .init(calendar: calendar, maximumLaneCount: DemoMetrics.maximumLaneCount)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DemoMetrics.sectionSpacing) {
            Text("Month Lane")
                .font(.largeTitle.bold())
            Text("Multi-day bars reserve their lanes while host-owned same-day chips remain below.")
                .foregroundStyle(.secondary)
            HStack(spacing: 0) {
                ForEach(DemoCalendar.days, id: \.self) { day in
                    Text(calendar.shortWeekdaySymbols[calendar.component(.weekday, from: day) - 1])
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
            }
            HStack(spacing: 0) {
                ForEach(DemoCalendar.days, id: \.self) { day in
                    DayCell(
                        day: day,
                        calendar: calendar,
                        layout: layout,
                        events: events
                    )
                }
            }
            if !layout.overflowEventIDs.isEmpty {
                Text("Overflow: \(layout.overflowEventIDs.joined(separator: ", "))")
                    .foregroundStyle(.red)
            }
        }
        .padding(DemoMetrics.outerPadding)
    }
}

private struct DayCell: View {
    let day: Date
    let calendar: Calendar
    let layout: KLCalendarLaneLayout<String>
    let events: [DemoEvent]

    private var sameDayEvents: [DemoEvent] {
        events.filter {
            calendar.isDate($0.event.startDate, inSameDayAs: day)
                && calendar.isDate($0.event.endDate, inSameDayAs: $0.event.startDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DemoMetrics.chipSpacing) {
            Text(calendar.component(.day, from: day).formatted())
                .font(.headline)
            ZStack(alignment: .topLeading) {
                Color.clear
                    .frame(height: CGFloat(layout.coveredLaneCount(on: day)) * DemoMetrics.laneHeight)
                ForEach(layout.segments(startingOn: day), id: \.self) { segment in
                    Text(segment.id)
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)
                        .padding(.horizontal, DemoMetrics.barHorizontalInset)
                        .frame(
                            width: CGFloat(segment.endColumn - segment.startColumn + 1) * DemoMetrics.cellWidth - DemoMetrics.barGap,
                            height: DemoMetrics.barHeight,
                            alignment: .leading
                        )
                        .background(DemoCalendar.color(for: segment.id), in: Capsule())
                        .offset(y: CGFloat(segment.lane) * DemoMetrics.laneHeight)
                        .zIndex(1)
                }
            }
            ForEach(sameDayEvents) { event in
                Text(event.title)
                    .font(.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, DemoMetrics.barHorizontalInset)
                    .frame(maxWidth: .infinity, minHeight: DemoMetrics.barHeight, alignment: .leading)
                    .background(event.color.opacity(DemoMetrics.chipOpacity), in: Capsule())
            }
            Spacer(minLength: 0)
        }
        .padding(DemoMetrics.cellPadding)
        .frame(width: DemoMetrics.cellWidth, height: DemoMetrics.cellHeight, alignment: .topLeading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: DemoMetrics.cellCornerRadius))
    }
}

private struct DemoEvent: Identifiable {
    let event: KLCalendarLaneEvent<String>
    let title: String
    let color: Color

    var id: String { event.id }
}

private enum DemoCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()
    static let week = DateInterval(start: date(2026, 8, 2), end: date(2026, 8, 9))
    static let days = (0..<DemoMetrics.daysPerRow).compactMap {
        calendar.date(byAdding: .day, value: $0, to: week.start)
    }
    static let events = [
        event("Conference", "Conference", 2026, 8, 2, 2026, 8, 7, .indigo),
        event("Release", "Release", 2026, 8, 4, 2026, 8, 9, .orange),
        event("Review", "Review", 2026, 8, 5, 2026, 8, 6, .mint),
        event("Lunch", "Lunch", 2026, 8, 5, 2026, 8, 5, .pink),
    ]

    static func color(for id: String) -> Color {
        events.first(where: { $0.id == id })?.color ?? .gray
    }

    private static func event(
        _ id: String,
        _ title: String,
        _ startYear: Int,
        _ startMonth: Int,
        _ startDay: Int,
        _ endYear: Int,
        _ endMonth: Int,
        _ endDay: Int,
        _ color: Color
    ) -> DemoEvent {
        DemoEvent(
            event: KLCalendarLaneEvent(
                id: id,
                startDate: date(startYear, startMonth, startDay),
                endDate: date(endYear, endMonth, endDay),
                sortKey: title
            ),
            title: title,
            color: color
        )
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day)
        if let date = calendar.date(from: components) {
            return date
        }
        fatalError("Expected a valid demo date.")
    }
}

private enum DemoMetrics {
    static let daysPerRow = 7
    static let maximumLaneCount = 3
    static let minimumWindowWidth: CGFloat = 850
    static let minimumWindowHeight: CGFloat = 330
    static let outerPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 16
    static let cellWidth: CGFloat = 112
    static let cellHeight: CGFloat = 170
    static let cellPadding: CGFloat = 8
    static let cellCornerRadius: CGFloat = 10
    static let laneHeight: CGFloat = 20
    static let barHeight: CGFloat = 16
    static let barGap: CGFloat = 6
    static let barHorizontalInset: CGFloat = 6
    static let chipSpacing: CGFloat = 4
    static let chipOpacity = 0.55
}
