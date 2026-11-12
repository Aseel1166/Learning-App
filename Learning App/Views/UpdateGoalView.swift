import SwiftUI

/// Edits the current learning goal. Saving a change starts a new goal, so the streak starts over.
struct UpdateGoalView: View {
    @State private var viewModel: GoalFormViewModel
    @State private var isShowingAlert = false
    @FocusState private var isSubjectFocused: Bool
    @Environment(\.dismiss) private var dismiss

    /// Called with the new subject and duration once the user confirms the alert.
    private let onUpdate: (String, GoalDuration) -> Void

    init(goal: LearningGoal, onUpdate: @escaping (String, GoalDuration) -> Void) {
        _viewModel = State(initialValue: GoalFormViewModel(subject: goal.subject, duration: goal.duration))
        self.onUpdate = onUpdate
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                GoalFormFields(viewModel: viewModel, isSubjectFocused: $isSubjectFocused)
                    .padding(.top, 24)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .onTapGesture { isSubjectFocused = false }
        .navigationTitle("Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Update goal", systemImage: "checkmark", action: confirm)
                    .buttonStyle(.borderedProminent)
                    .tint(.appAccent)
                    .disabled(!viewModel.isValid)
            }
        }
        .alert("Update goal", isPresented: $isShowingAlert) {
            Button("Dismiss", role: .cancel) {}
            Button("Update") {
                onUpdate(viewModel.trimmedSubject, viewModel.duration)
            }
        } message: {
            Text("If you update now, your streak will start over.")
        }
    }

    /// Nothing changed, so there is nothing to warn about; just go back.
    private func confirm() {
        isSubjectFocused = false
        if viewModel.hasChanges {
            isShowingAlert = true
        } else {
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        UpdateGoalView(goal: LearningGoal(subject: "Swift", duration: .week)) { _, _ in }
    }
    .preferredColorScheme(.dark)
}
