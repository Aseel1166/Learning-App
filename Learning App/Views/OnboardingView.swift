import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = GoalFormViewModel()
    @FocusState private var isSubjectFocused: Bool

    /// Called when the user taps Start Learning with a valid goal.
    var onStart: (String, GoalDuration) -> Void = { _, _ in }

    private let accent = Color.appAccent

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(accent)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 70)
                    .accessibilityHidden(true)

                header
                    .padding(.top, 60)

                GoalFormFields(viewModel: viewModel, isSubjectFocused: $isSubjectFocused)
                    .padding(.top, 32)

                Spacer()

                startButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onTapGesture { isSubjectFocused = false }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Hello \(Text("Learner").bold())")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("This app will help you learn everyday!")
                .font(.body)
                .foregroundStyle(.gray)
        }
    }

    private var startButton: some View {
        VStack(spacing: 10) {
            Button {
                onStart(viewModel.trimmedSubject, viewModel.duration)
            } label: {
                Text("Start Learning")
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(accent, in: .capsule)
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.isValid)
            .opacity(viewModel.isValid ? 1 : 0.5)

            Text("You can edit your desire later")
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
