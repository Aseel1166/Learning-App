import Foundation
import SwiftData

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
