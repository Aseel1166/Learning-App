import SwiftUI

/// A rounded card with an icon, a count and a caption (e.g. "4 days / Learned").
struct StatCardView: View {
    let systemImage: String
    let tint: Color
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
                .accessibilityHidden(true)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}
