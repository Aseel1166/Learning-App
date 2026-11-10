import Foundation
import SwiftData

/// How the user spent a day: learning, or protecting the streak with a freeze.
enum DayKind: String, Codable {
    case learned
    case freezed
}

/// One logged day inside a learning goal.
@Model
final class DayLog {
    /// Start of the logged day.
    var date: Date
    var kind: DayKind
    var goal: LearningGoal?

    init(date: Date, kind: DayKind) {
        self.date = date
        self.kind = kind
    }
}
