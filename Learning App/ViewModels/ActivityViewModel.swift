import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ActivityViewModel {
    struct WeekDay: Identifiable {
        let date: Date
        let symbol: String
        let number: Int
        let state: DayState
        let isToday: Bool

        var id: Date { date }
    }

    /// What the page shows instead of the log buttons once the goal is over.
    struct GoalResult {
        let systemImage: String
        let title: String
        let message: String
    }

    let goal: LearningGoal

    private let modelContext: ModelContext
    private let calendar: Calendar
    private let now: () -> Date

    /// Start of the current day. Refreshed at midnight so the buttons re-enable.
    private(set) var today: Date

    /// The time the page last evaluated; the goal status is judged against it.
    private(set) var currentTime: Date

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
        self.currentTime = now()
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
        DayState(kind: log(on: date)?.kind)
    }

    // MARK: - Counters

    var learnedCount: Int { goal.learnedCount }
    var freezedCount: Int { goal.freezedCount }

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

    // MARK: - Goal status

    var status: GoalStatus {
        goal.status(at: currentTime)
    }

    /// Set once the goal is completed or failed.
    var result: GoalResult? {
        switch status {
        case .active:
            nil
        case .completed:
            GoalResult(
                systemImage: "hands.clap.fill",
                title: "Well done!",
                message: "Ready for your next goal?"
            )
        case .failed:
            GoalResult(
                systemImage: "xmark.seal",
                title: "You didn't reach your goal this time.",
                message: "Want to set another goal?"
            )
        }
    }

    // MARK: - Buttons

    private var todayLog: DayLog? { log(on: today) }

    private var hasFreezesLeft: Bool { freezedCount < freezesAllowed }

    /// Both buttons are disabled once the day is logged, whichever way it was logged.
    var canLogLearned: Bool {
        status == .active && todayLog == nil
    }

    var canFreeze: Bool {
        status == .active && todayLog == nil && hasFreezesLeft
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

    /// Starts a new goal; the root view then switches to it.
    func startNewGoal(subject: String, duration: GoalDuration) {
        modelContext.insert(LearningGoal(subject: subject, duration: duration, startDate: now()))
    }

    /// Re-reads the clock; call when the app returns to the foreground, at midnight and at the streak deadline.
    func refresh() {
        currentTime = now()
        today = calendar.startOfDay(for: currentTime)
    }

    /// Seconds until the day changes or the streak runs out, whichever comes first, plus a small buffer.
    var secondsUntilNextCheck: TimeInterval {
        var next = calendar.date(byAdding: .day, value: 1, to: today) ?? currentTime.addingTimeInterval(3600)
        if status == .active {
            next = min(next, goal.streakDeadline)
        }
        return max(next.timeIntervalSince(now()), 0) + 1
    }

    // MARK: - Private

    private func log(on date: Date) -> DayLog? {
        goal.logs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func logToday(as kind: DayKind) {
        let newLog = DayLog(date: today, kind: kind, loggedAt: now())
        modelContext.insert(newLog)
        newLog.goal = goal
    }
}
