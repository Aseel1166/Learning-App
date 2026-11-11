import Foundation
import SwiftData

/// Where a learning goal stands.
enum GoalStatus {
    case active
    case completed
    case failed
}

/// What the user wants to learn and for how long, together with the days logged for it.
@Model
final class LearningGoal {
    var subject: String
    var duration: GoalDuration
    var startDate: Date

    @Relationship(deleteRule: .cascade, inverse: \DayLog.goal)
    var logs: [DayLog] = []

    init(subject: String, duration: GoalDuration, startDate: Date = .now) {
        self.subject = subject
        self.duration = duration
        self.startDate = startDate
    }
}

extension LearningGoal {
    /// Time allowed without logging a day (learned or freezed) before the streak resets.
    static let streakTimeout: TimeInterval = 32 * 60 * 60

    var learnedCount: Int {
        logs.filter { $0.kind == .learned }.count
    }

    var freezedCount: Int {
        logs.filter { $0.kind == .freezed }.count
    }

    /// When the user last logged a day, or when the goal started if nothing is logged yet.
    var lastActivity: Date {
        logs.map(\.loggedAt).max() ?? startDate
    }

    /// The moment the streak breaks if nothing else is logged.
    var streakDeadline: Date {
        lastActivity.addingTimeInterval(Self.streakTimeout)
    }

    /// Freezes do not count towards completion; they only keep the streak alive.
    func status(at date: Date) -> GoalStatus {
        if learnedCount >= duration.requiredDays { return .completed }
        if date > streakDeadline { return .failed }
        return .active
    }
}
