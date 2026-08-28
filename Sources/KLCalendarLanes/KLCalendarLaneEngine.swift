import Foundation

/// Calculates deterministic lanes for multi-day all-day event bars.
public struct KLCalendarLaneEngine: Sendable {
    public init() {}

    public func layout<ID: Hashable & Sendable, Events: Collection>(
        events: Events,
        in interval: DateInterval,
        configuration: KLCalendarLaneConfiguration
    ) -> KLCalendarLaneLayout<ID>
    where Events.Element == KLCalendarLaneEvent<ID> {
        let calendar = configuration.calendar
        let intervalStart = calendar.startOfDay(for: interval.start)
        guard let intervalLastDay = lastDay(
            before: interval.end,
            calendar: calendar
        ) else {
            return KLCalendarLaneLayout(
                segments: [],
                overflowEventIDs: [],
                calendar: calendar,
                coveredLaneCountByDay: [:],
                intervalStart: intervalStart,
                daysPerRow: configuration.daysPerRow
            )
        }

        let normalizedEvents = events.compactMap {
            normalizedEvent(
                $0,
                intervalStart: intervalStart,
                intervalLastDay: intervalLastDay,
                configuration: configuration
            )
        }
        precondition(
            orderingKeysAreUnambiguous(normalizedEvents),
            "KLCalendarLaneEvent.sortKey must disambiguate equal duration, start day, and reflected ID text."
        )
        let sortedEvents = normalizedEvents.sorted(by: eventComesFirst)
        var occupiedDaysByLane = [[Date]]()
        var layoutSegments = [KLCalendarLaneSegment<ID>]()
        var overflowEventIDs = [ID]()
        var coveredLaneCountByDay = [Date: Int]()

        for event in sortedEvents {
            let lane = firstAvailableLane(
                for: event.clippedDays,
                occupiedDaysByLane: occupiedDaysByLane
            )
            guard lane < configuration.maximumLaneCount else {
                overflowEventIDs.append(event.id)
                continue
            }

            if lane == occupiedDaysByLane.count {
                occupiedDaysByLane.append(event.clippedDays)
            } else {
                occupiedDaysByLane[lane].append(contentsOf: event.clippedDays)
            }

            for day in event.clippedDays {
                coveredLaneCountByDay[day] = max(
                    coveredLaneCountByDay[day] ?? 0,
                    lane + 1
                )
            }

            layoutSegments.append(contentsOf: segments(
                for: event,
                intervalStart: intervalStart,
                daysPerRow: configuration.daysPerRow,
                lane: lane,
                calendar: calendar
            ))
        }

        return KLCalendarLaneLayout(
            segments: layoutSegments,
            overflowEventIDs: overflowEventIDs,
            calendar: calendar,
            coveredLaneCountByDay: coveredLaneCountByDay,
            intervalStart: intervalStart,
            daysPerRow: configuration.daysPerRow
        )
    }

    func orderingKeysAreUnambiguous<ID: Hashable & Sendable, Events: Collection>(
        events: Events,
        in interval: DateInterval,
        configuration: KLCalendarLaneConfiguration
    ) -> Bool
    where Events.Element == KLCalendarLaneEvent<ID> {
        let calendar = configuration.calendar
        let intervalStart = calendar.startOfDay(for: interval.start)
        guard let intervalLastDay = lastDay(
            before: interval.end,
            calendar: calendar
        ) else {
            return true
        }
        let normalizedEvents = events.compactMap {
            normalizedEvent(
                $0,
                intervalStart: intervalStart,
                intervalLastDay: intervalLastDay,
                configuration: configuration
            )
        }
        return orderingKeysAreUnambiguous(normalizedEvents)
    }
}

private extension KLCalendarLaneEngine {
    struct NormalizedEvent<ID: Hashable & Sendable> {
        let id: ID
        let sortKey: String
        let coverageStart: Date
        let coverageEnd: Date
        let coverageDayCount: Int
        let clippedDays: [Date]
    }

    struct OrderingKey: Equatable {
        let coverageDayCount: Int
        let coverageStart: Date
        let reflectedID: String
        let sortKey: String
    }

    func normalizedEvent<ID: Hashable & Sendable>(
        _ event: KLCalendarLaneEvent<ID>,
        intervalStart: Date,
        intervalLastDay: Date,
        configuration: KLCalendarLaneConfiguration
    ) -> NormalizedEvent<ID>? {
        let calendar = configuration.calendar
        let coverageStart = calendar.startOfDay(for: event.startDate)
        guard let coverageEnd = coverageEndDay(
            for: event,
            calendar: calendar,
            boundary: configuration.endBoundary
        ), coverageEnd > coverageStart else {
            return nil
        }

        let clippedStart = max(coverageStart, intervalStart)
        let clippedEnd = min(coverageEnd, intervalLastDay)
        guard clippedStart <= clippedEnd else { return nil }

        return NormalizedEvent(
            id: event.id,
            sortKey: event.sortKey,
            coverageStart: coverageStart,
            coverageEnd: coverageEnd,
            coverageDayCount: calendar.dateComponents(
                [.day],
                from: coverageStart,
                to: coverageEnd
            ).day.map { $0 + 1 } ?? 0,
            clippedDays: days(
                from: clippedStart,
                through: clippedEnd,
                calendar: calendar
            )
        )
    }

    func coverageEndDay<ID: Hashable & Sendable>(
        for event: KLCalendarLaneEvent<ID>,
        calendar: Calendar,
        boundary: KLEventEndBoundary
    ) -> Date? {
        let endDay = calendar.startOfDay(for: event.endDate)
        switch boundary {
        case .inclusive:
            return endDay
        case .exclusive:
            if event.endDate == endDay {
                return calendar.date(byAdding: .day, value: -1, to: endDay)
            }
            return endDay
        }
    }

    func lastDay(before endDate: Date, calendar: Calendar) -> Date? {
        let endDay = calendar.startOfDay(for: endDate)
        if endDate == endDay {
            return calendar.date(byAdding: .day, value: -1, to: endDay)
        }
        return endDay
    }

    func eventComesFirst<ID: Hashable & Sendable>(
        _ lhs: NormalizedEvent<ID>,
        _ rhs: NormalizedEvent<ID>
    ) -> Bool {
        orderingKeyComesFirst(orderingKey(for: lhs), orderingKey(for: rhs))
    }

    func orderingKeysAreUnambiguous<ID: Hashable & Sendable>(
        _ events: [NormalizedEvent<ID>]
    ) -> Bool {
        let sortedKeys = events
            .map(orderingKey)
            .sorted(by: orderingKeyComesFirst)
        for (current, next) in zip(sortedKeys, sortedKeys.dropFirst())
        where current == next {
            return false
        }
        return true
    }

    func orderingKey<ID: Hashable & Sendable>(
        for event: NormalizedEvent<ID>
    ) -> OrderingKey {
        OrderingKey(
            coverageDayCount: event.coverageDayCount,
            coverageStart: event.coverageStart,
            reflectedID: String(reflecting: event.id),
            sortKey: event.sortKey
        )
    }

    func orderingKeyComesFirst(_ lhs: OrderingKey, _ rhs: OrderingKey) -> Bool {
        if lhs.coverageDayCount != rhs.coverageDayCount {
            return lhs.coverageDayCount > rhs.coverageDayCount
        }
        if lhs.coverageStart != rhs.coverageStart {
            return lhs.coverageStart < rhs.coverageStart
        }
        if lhs.reflectedID != rhs.reflectedID {
            return lhs.reflectedID < rhs.reflectedID
        }
        return lhs.sortKey < rhs.sortKey
    }

    func firstAvailableLane(
        for days: [Date],
        occupiedDaysByLane: [[Date]]
    ) -> Int {
        let candidateDays = Set(days)
        for (lane, occupiedDays) in occupiedDaysByLane.enumerated()
        where candidateDays.isDisjoint(with: occupiedDays) {
            return lane
        }
        return occupiedDaysByLane.count
    }

    func segments<ID: Hashable & Sendable>(
        for event: NormalizedEvent<ID>,
        intervalStart: Date,
        daysPerRow: Int,
        lane: Int,
        calendar: Calendar
    ) -> [KLCalendarLaneSegment<ID>] {
        let offsets = event.clippedDays.compactMap { day in
            calendar.dateComponents([.day], from: intervalStart, to: day).day
        }
        guard let firstOffset = offsets.first else { return [] }

        var result = [KLCalendarLaneSegment<ID>]()
        var segmentStartOffset = firstOffset
        var previousOffset = firstOffset
        for offset in offsets.dropFirst() {
            let startsNewRow = offset / daysPerRow != previousOffset / daysPerRow
            if startsNewRow {
                result.append(segment(
                    event: event,
                    startOffset: segmentStartOffset,
                    endOffset: previousOffset,
                    intervalStart: intervalStart,
                    daysPerRow: daysPerRow,
                    lane: lane,
                    calendar: calendar
                ))
                segmentStartOffset = offset
            }
            previousOffset = offset
        }
        result.append(segment(
            event: event,
            startOffset: segmentStartOffset,
            endOffset: previousOffset,
            intervalStart: intervalStart,
            daysPerRow: daysPerRow,
            lane: lane,
            calendar: calendar
        ))
        return result
    }

    func segment<ID: Hashable & Sendable>(
        event: NormalizedEvent<ID>,
        startOffset: Int,
        endOffset: Int,
        intervalStart: Date,
        daysPerRow: Int,
        lane: Int,
        calendar: Calendar
    ) -> KLCalendarLaneSegment<ID> {
        let segmentStart = calendar.date(
            byAdding: .day,
            value: startOffset,
            to: intervalStart
        ) ?? intervalStart
        let segmentEnd = calendar.date(
            byAdding: .day,
            value: endOffset,
            to: intervalStart
        ) ?? intervalStart
        return KLCalendarLaneSegment(
            id: event.id,
            rowIndex: startOffset / daysPerRow,
            startColumn: startOffset % daysPerRow,
            endColumn: endOffset % daysPerRow,
            lane: lane,
            roundsLeadingCorners: segmentStart == event.coverageStart,
            roundsTrailingCorners: segmentEnd == event.coverageEnd,
            eventCoverageStartDate: event.coverageStart,
            eventCoverageEndDate: event.coverageEnd
        )
    }

    func days(
        from startDate: Date,
        through endDate: Date,
        calendar: Calendar
    ) -> [Date] {
        var result = [Date]()
        var date = startDate
        while date <= endDate {
            result.append(date)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: date) else {
                break
            }
            date = nextDate
        }
        return result
    }
}
