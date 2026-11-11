import SwiftData
import SwiftUI

/// Shows onboarding until a learning goal exists, then the activity page.
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningGoal.startDate) private var goals: [LearningGoal]

    var body: some View {
        if let goal = goals.last {
            NavigationStack {
                ActivityView(goal: goal, modelContext: modelContext)
            }
            // A new goal must get a fresh view model and close any open screen.
            .id(goal.persistentModelID)
        } else {
            OnboardingView { subject, duration in
                modelContext.insert(LearningGoal(subject: subject, duration: duration))
            }
        }
    }
}
