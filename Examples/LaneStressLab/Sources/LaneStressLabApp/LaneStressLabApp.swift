import Foundation
import KLCalendarLanes
import SwiftUI

@main
struct LaneStressLabApp: App {
    var body: some Scene {
        WindowGroup("Lane Stress Lab") {
            LaneStressLabView()
                .frame(minWidth: StressMetrics.minimumWindowWidth, minHeight: StressMetrics.minimumWindowHeight)
        }
    }
}

private struct LaneStressLabView: View {
    @State private var daysPerRow = StressMetrics.defaultDaysPerRow
    @State private var laneCapacity = StressMetrics.defaultLaneCapacity
    @State private var eventCount = StressMetrics.defaultEventCount
    @State private var firstWeekday = StressMetrics.sundayFirstWeekday

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private var interval: DateInterval {
        let gridStart = calendar.dateInterval(
            of: .weekOfYear,
            for: StressCalendar.anchorDate
        )?.start ?? StressCalendar.anchorDate
        let gridEnd = calendar.date(
            byAdding: .day,
            value: StressMetrics.visibleDayCount,
            to: gridStart
        ) ?? gridStart
        return DateInterval(start: gridStart, end: gridEnd)
    }

    private var layout: KLCalendarLaneLayout<Int> {
        KLCalendarLaneEngine().layout(
            events: StressCalendar.events(count: eventCount),
            in: interval,
            configuration: .init(
                calendar: calendar,
                daysPerRow: daysPerRow,
                maximumLaneCount: laneCapacity
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: StressMetrics.sectionSpacing) {
            Text("Lane Stress Lab")
                .font(.largeTitle.bold())
            controls
            LabeledContent("Grid start", value: interval.start, format: .dateTime.year().month().day())
            LabeledContent("Placed segments", value: layout.segments.count.formatted())
            LabeledContent("Overflow events", value: layout.overflowEventIDs.count.formatted())
            ScrollView {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: StressMetrics.gridSpacing),
                        count: daysPerRow
                    ),
                    spacing: StressMetrics.gridSpacing
                ) {
                    ForEach(dayOffsets, id: \.self) { offset in
                        daySummary(offset: offset)
                    }
                }
            }
            if !layout.overflowEventIDs.isEmpty {
                Text("Overflow IDs: \(layout.overflowEventIDs.map { $0.formatted() }.joined(separator: ", "))")
                    .font(.caption.monospaced())
                    .foregroundStyle(.red)
            }
        }
        .padding(StressMetrics.outerPadding)
    }

    private var controls: some View {
        HStack(spacing: StressMetrics.controlSpacing) {
            Stepper("Days per row: \(daysPerRow)", value: $daysPerRow, in: StressMetrics.minimumDaysPerRow...StressMetrics.maximumDaysPerRow)
            Stepper("Lane capacity: \(laneCapacity)", value: $laneCapacity, in: StressMetrics.minimumLaneCapacity...StressMetrics.maximumLaneCapacity)
            Stepper("Generated events: \(eventCount)", value: $eventCount, in: StressMetrics.minimumEventCount...StressMetrics.maximumEventCount)
            Picker("First weekday", selection: $firstWeekday) {
                Text("Sunday").tag(StressMetrics.sundayFirstWeekday)
                Text("Monday").tag(StressMetrics.mondayFirstWeekday)
            }
            .frame(maxWidth: StressMetrics.weekdayPickerWidth)
        }
        .controlSize(.small)
    }

    private var dayOffsets: [Int] {
        Array(0..<StressMetrics.visibleDayCount)
    }

    @ViewBuilder
    private func daySummary(offset: Int) -> some View {
        let day = calendar.date(byAdding: .day, value: offset, to: interval.start) ?? interval.start
        let laneCount = layout.coveredLaneCount(on: day)
        VStack(alignment: .leading, spacing: StressMetrics.summarySpacing) {
            Text(day, format: .dateTime.month().day())
                .font(.caption.weight(.semibold))
            Text("lanes \(laneCount)")
                .font(.caption2.monospacedDigit())
            Text("starts \(layout.segments(startingOn: day).count)")
                .font(.caption2.monospacedDigit())
        }
        .frame(maxWidth: .infinity, minHeight: StressMetrics.daySummaryHeight, alignment: .topLeading)
        .padding(StressMetrics.daySummaryPadding)
        .background(
            laneCount == 0
                ? Color.gray.opacity(StressMetrics.emptyDayOpacity)
                : Color.blue.opacity(StressMetrics.laneOpacity),
            in: RoundedRectangle(cornerRadius: StressMetrics.cornerRadius)
        )
    }
}

private enum StressCalendar {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }()
    static let anchorDate: Date = {
        let components = DateComponents(year: 2026, month: 8, day: 2)
        if let date = calendar.date(from: components) {
            return date
        }
        fatalError("Expected a valid stress-lab start date.")
    }()

    static func events(count: Int) -> [KLCalendarLaneEvent<Int>] {
        (0..<count).compactMap { index in
            let startOffset = index % StressMetrics.eventStartCycle
            let duration = index % StressMetrics.eventDurationCycle + StressMetrics.minimumEventDuration
            guard let eventStartDate = calendar.date(byAdding: .day, value: startOffset, to: anchorDate),
                  let endDate = calendar.date(byAdding: .day, value: duration, to: eventStartDate)
            else {
                return nil
            }
            return KLCalendarLaneEvent(
                id: index,
                startDate: eventStartDate,
                endDate: endDate,
                sortKey: index.formatted()
            )
        }
    }
}

private enum StressMetrics {
    static let minimumWindowWidth: CGFloat = 780
    static let minimumWindowHeight: CGFloat = 520
    static let outerPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 16
    static let controlSpacing: CGFloat = 12
    static let gridSpacing: CGFloat = 8
    static let summarySpacing: CGFloat = 4
    static let daySummaryHeight: CGFloat = 58
    static let daySummaryPadding: CGFloat = 8
    static let cornerRadius: CGFloat = 8
    static let laneOpacity = 0.18
    static let emptyDayOpacity = 0.12
    static let weekdayPickerWidth: CGFloat = 110
    static let defaultDaysPerRow = 7
    static let minimumDaysPerRow = 3
    static let maximumDaysPerRow = 14
    static let defaultLaneCapacity = 2
    static let minimumLaneCapacity = 1
    static let maximumLaneCapacity = 6
    static let defaultEventCount = 18
    static let minimumEventCount = 3
    static let maximumEventCount = 60
    static let visibleDayCount = 28
    static let sundayFirstWeekday = 1
    static let mondayFirstWeekday = 2
    static let eventStartCycle = 21
    static let eventDurationCycle = 6
    static let minimumEventDuration = 2
}
