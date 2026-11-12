import Foundation
import Observation

/// A day in the calendar grid.
struct CalendarDay: Identifiable {
    let date: Date
    let number: Int
    let state: DayState
    let isToday: Bool

    var id: Date { date }
}

/// One month of the calendar.
struct CalendarMonth: Identifiable {
    /// First day of the month.
    let id: Date
    let title: String
    /// Empty cells before the first day so it lands under the right weekday.
    let leadingBlanks: Int
    let days: [CalendarDay]
}

@MainActor
@Observable
final class ActivityCalendarViewModel {
    private let calendar: Calendar
    private let now: () -> Date

    init(calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.calendar = calendar
        self.now = now
    }

    /// SUN, MON, ... starting from the calendar's first weekday.
    var weekdayHeaders: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return (0..<7).map { symbols[(start + $0) % 7].uppercased() }
    }

    /// How many months before and after the current one the calendar always shows.
    private static let monthsAround = 12

    /// First day of the current month, the month the calendar opens on.
    var currentMonthID: Date? {
        calendar.dateInterval(of: .month, for: now())?.start
    }

    /// A year back (or further, back to the first logged day) and a year ahead, across all goals.
    func months(from logs: [DayLog]) -> [CalendarMonth] {
        let today = calendar.startOfDay(for: now())
        guard let currentMonth = calendar.dateInterval(of: .month, for: today)?.start,
              let earliestMonth = calendar.date(byAdding: .month, value: -Self.monthsAround, to: currentMonth),
              let lastMonth = calendar.date(byAdding: .month, value: Self.monthsAround, to: currentMonth)
        else { return [] }

        // If a day was logged in more than one goal, the latest log wins.
        let kinds = Dictionary(
            logs.sorted { $0.loggedAt < $1.loggedAt }
                .map { (calendar.startOfDay(for: $0.date), $0.kind) },
            uniquingKeysWith: { _, latest in latest }
        )

        let firstLoggedMonth = logs.map(\.date).min()
            .flatMap { calendar.dateInterval(of: .month, for: $0)?.start }

        var months: [CalendarMonth] = []
        var cursor = min(firstLoggedMonth ?? earliestMonth, earliestMonth)
        while cursor <= lastMonth {
            months.append(makeMonth(starting: cursor, kinds: kinds, today: today))
            guard let next = calendar.date(byAdding: .month, value: 1, to: cursor) else { break }
            cursor = next
        }
        return months
    }

    private func makeMonth(starting start: Date, kinds: [Date: DayKind], today: Date) -> CalendarMonth {
        let dayCount = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let firstWeekday = calendar.component(.weekday, from: start)
        let blanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        let days = (0..<dayCount).compactMap { offset -> CalendarDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return CalendarDay(
                date: date,
                number: offset + 1,
                state: DayState(kind: kinds[date]),
                isToday: date == today
            )
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMMM yyyy"

        return CalendarMonth(
            id: start,
            title: formatter.string(from: start),
            leadingBlanks: blanks,
            days: days
        )
    }
}
