import Foundation
import Observation

/// State shared by every screen where the user picks what to learn and for how long.
@Observable
final class GoalFormViewModel {
    var subject: String
    var duration: GoalDuration

    private let initialSubject: String
    private let initialDuration: GoalDuration

    /// Starts from the given values, so editing an existing goal can tell what changed.
    init(subject: String = "", duration: GoalDuration = .week) {
        self.subject = subject
        self.duration = duration
        self.initialSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        self.initialDuration = duration
    }

    /// The subject without surrounding whitespace.
    var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A goal can only be saved once the user typed what they want to learn.
    var isValid: Bool {
        !trimmedSubject.isEmpty
    }

    /// Whether the subject or the duration differs from what the form started with.
    var hasChanges: Bool {
        trimmedSubject != initialSubject || duration != initialDuration
    }

    func select(_ duration: GoalDuration) {
        self.duration = duration
    }
}
