import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
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

                subjectField
                    .padding(.top, 32)

                durationPicker
                    .padding(.top, 28)

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

    private var subjectField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("I want to learn")
                .font(.body)
                .foregroundStyle(.white)

            TextField(
                "",
                text: $viewModel.subject,
                prompt: Text("Swift").foregroundStyle(.gray.opacity(0.6))
            )
            .textFieldStyle(.plain)
            .focused($isSubjectFocused)
            .submitLabel(.done)
            .foregroundStyle(.white)

            Divider()
                .overlay(Color.white.opacity(0.2))
        }
    }

    private var durationPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("I want to learn it in a")
                .font(.body)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                ForEach(GoalDuration.allCases) { duration in
                    durationButton(duration)
                }
            }
        }
    }

    private func durationButton(_ duration: GoalDuration) -> some View {
        let isSelected = viewModel.duration == duration
        return Button {
            viewModel.select(duration)
        } label: {
            Text(duration.rawValue)
                .font(.body)
                .foregroundStyle(isSelected ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? accent : Color.white.opacity(0.1), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
            .disabled(!viewModel.canStart)
            .opacity(viewModel.canStart ? 1 : 0.5)

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
