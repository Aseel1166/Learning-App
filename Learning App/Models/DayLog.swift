import Foundation
import SwiftData

/// How the user spent a day: learning, or protecting the streak with a freeze.
enum DayKind: String, Codable {
    case learned
    case freezed
}

/// How a day is shown: nothing logged, learned, or freezed.
enum DayState {
    case none
    case learned
    case freezed

    init(kind: DayKind?) {
        switch kind {
        case .learned: self = .learned
        case .freezed: self = .freezed
        case nil: self = .none
        }
    }
}

/// One logged day inside a learning goal.
@Model
final class DayLog {
    /// Start of the logged day.
    var date: Date
    var kind: DayKind
    /// The exact moment the user logged it; the 32-hour streak rule counts from here.
    var loggedAt: Date = Date.now
    var goal: LearningGoal?

    init(date: Date, kind: DayKind, loggedAt: Date = .now) {
        self.date = date
        self.kind = kind
        self.loggedAt = loggedAt
    }
}
