import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ActivityViewModel {
    enum DayState {
        case none
        case learned
        case freezed
    }

    struct WeekDay: Identifiable {
        let date: Date
        let symbol: String
        let number: Int
        let state: DayState
        let isToday: Bool

        var id: Date { date }
    }

    let goal: LearningGoal

    private let modelContext: ModelContext
    private let calendar: Calendar
    private let now: () -> Date

    /// Start of the current day. Refreshed at midnight so the buttons re-enable.
    private(set) var today: Date

    init(
        goal: LearningGoal,
        modelContext: ModelContext,
        calendar: Calendar = .current,
        now: @escaping () -> Date = { .now }
    ) {
        self.goal = goal
        self.modelContext = modelContext
        self.calendar = calendar
        self.now = now
        self.today = calendar.startOfDay(for: now())
    }

    // MARK: - Header

    var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: today)
    }

    // MARK: - Week strip

    /// The seven days of the current week, each with how it was logged.
    var weekDays: [WeekDay] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: week.start) else { return nil }
            let weekday = calendar.component(.weekday, from: date)

            return WeekDay(
                date: date,
                symbol: calendar.veryShortStandaloneWeekdaySymbols[weekday - 1],
                number: calendar.component(.day, from: date),
                state: state(on: date),
                isToday: date == today
            )
        }
    }

    private func state(on date: Date) -> DayState {
        switch log(on: date)?.kind {
        case .learned: .learned
        case .freezed: .freezed
        case nil: .none
        }
    }

    // MARK: - Counters

    var learnedCount: Int {
        goal.logs.filter { $0.kind == .learned }.count
    }

    var freezedCount: Int {
        goal.logs.filter { $0.kind == .freezed }.count
    }

    var freezesAllowed: Int {
        goal.duration.allowedFreezes
    }

    var learnedCountText: String { Self.dayCountText(learnedCount) }
    var freezedCountText: String { Self.dayCountText(freezedCount) }

    var freezesUsedText: String {
        "\(freezedCount) out of \(freezesAllowed) Freezes used"
    }

    /// "1 day" for one, "N days" otherwise.
    static func dayCountText(_ count: Int) -> String {
        count == 1 ? "1 day" : "\(count) days"
    }

    // MARK: - Buttons

    private var todayLog: DayLog? { log(on: today) }

    private var hasFreezesLeft: Bool { freezedCount < freezesAllowed }

    /// Both buttons are disabled once the day is logged, whichever way it was logged.
    var canLogLearned: Bool {
        todayLog == nil
    }

    var canFreeze: Bool {
        todayLog == nil && hasFreezesLeft
    }

    var logButtonTitle: String {
        todayLog?.kind == .learned ? "Logged as Learned" : "Log as Learned"
    }

    var freezeButtonTitle: String {
        canFreeze ? "Freeze for a day" : "Freezed for a day"
    }

    // MARK: - Actions

    func logAsLearned() {
        guard canLogLearned else { return }
        logToday(as: .learned)
    }

    func freezeToday() {
        guard canFreeze else { return }
        logToday(as: .freezed)
    }

    /// Re-reads the current day; call when the app returns to the foreground or at midnight.
    func refreshToday() {
        today = calendar.startOfDay(for: now())
    }

    /// Seconds until the next midnight, plus a small buffer so the day has really changed.
    var secondsUntilNextDay: TimeInterval {
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else { return 3600 }
        return max(tomorrow.timeIntervalSince(now()), 0) + 1
    }

    // MARK: - Private

    private func log(on date: Date) -> DayLog? {
        goal.logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func logToday(as kind: DayKind) {
        let newLog = DayLog(date: today, kind: kind)
        modelContext.insert(newLog)
        newLog.goal = goal
    }
}
