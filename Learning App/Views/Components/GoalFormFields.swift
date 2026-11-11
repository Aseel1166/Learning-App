import SwiftUI

/// The "I want to learn" field and the Week / Month / Year picker.
struct GoalFormFields: View {
    @Bindable var viewModel: GoalFormViewModel
    var isSubjectFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            subjectField
            durationPicker
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
            .focused(isSubjectFocused)
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
                .background(isSelected ? Color.appAccent : Color.white.opacity(0.1), in: .capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
