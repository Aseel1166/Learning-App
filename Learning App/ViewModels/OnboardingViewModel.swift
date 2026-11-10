import Foundation
import Observation

@Observable
final class OnboardingViewModel {
    var subject: String = ""
    var duration: GoalDuration = .week

    /// The subject without surrounding whitespace.
    var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Start Learning is only allowed once the user typed what they want to learn.
    var canStart: Bool {
        !trimmedSubject.isEmpty
    }

    func select(_ duration: GoalDuration) {
        self.duration = duration
    }
}
