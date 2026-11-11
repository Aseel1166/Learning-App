import SwiftUI

/// Shown instead of the log buttons once a goal is completed or failed.
struct GoalResultView: View {
    let systemImage: String
    let title: String
    let message: String
    let onSetGoal: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(Color.appAccent)
                .padding(.bottom, 12)
                .accessibilityHidden(true)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)

            Button(action: onSetGoal) {
                Label("Set a goal", systemImage: "target")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.appAccent, in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.top, 32)
        }
        .frame(maxWidth: .infinity)
    }
}
