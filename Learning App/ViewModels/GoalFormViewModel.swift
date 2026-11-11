import Foundation
import Observation

/// State shared by every screen where the user picks what to learn and for how long.
@Observable
final class GoalFormViewModel {
    var subject: String = ""
    var duration: GoalDuration = .week

    /// The subject without surrounding whitespace.
    var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A goal can only be saved once the user typed what they want to learn.
    var isValid: Bool {
        !trimmedSubject.isEmpty
    }

    func select(_ duration: GoalDuration) {
        self.duration = duration
    }
}
