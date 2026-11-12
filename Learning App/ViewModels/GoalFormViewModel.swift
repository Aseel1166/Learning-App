import Foundation
import Observation

/// State shared by every screen where the user picks what to learn and for how long.
@Observable
final class GoalFormViewModel {
    var subject: String
    /// Nothing is selected until the user taps Week, Month or Year.
    var duration: GoalDuration?

    private let initialSubject: String
    private let initialDuration: GoalDuration?

    /// Starts from the given values, so editing an existing goal can tell what changed.
    init(subject: String = "", duration: GoalDuration? = nil) {
        self.subject = subject
        self.duration = duration
        self.initialSubject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        self.initialDuration = duration
    }

    /// The subject without surrounding whitespace.
    var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A goal can only be saved once the user typed what they want to learn and picked a duration.
    var isValid: Bool {
        !trimmedSubject.isEmpty && duration != nil
    }

    /// The finished goal input, or nil while the form is incomplete.
    var selection: (subject: String, duration: GoalDuration)? {
        guard isValid, let duration else { return nil }
        return (trimmedSubject, duration)
    }

    /// Whether the subject or the duration differs from what the form started with.
    var hasChanges: Bool {
        trimmedSubject != initialSubject || duration != initialDuration
    }

    func select(_ duration: GoalDuration) {
        self.duration = duration
    }
}
