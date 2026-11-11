import SwiftUI

/// Where the user sets a brand new goal after finishing or missing the previous one.
struct NewGoalView: View {
    @State private var viewModel = GoalFormViewModel()
    @FocusState private var isSubjectFocused: Bool

    /// Called with the chosen subject and duration when the user confirms.
    var onSave: (String, GoalDuration) -> Void

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
        .navigationTitle("New Learning Goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save goal", systemImage: "checkmark") {
                    onSave(viewModel.trimmedSubject, viewModel.duration)
                }
                .buttonStyle(.borderedProminent)
                .tint(.appAccent)
                .disabled(!viewModel.isValid)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewGoalView { _, _ in }
    }
    .preferredColorScheme(.dark)
}
