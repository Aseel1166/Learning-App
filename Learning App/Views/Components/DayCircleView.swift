import SwiftUI

/// A day number in a circle: dim orange when learned, dim blue when freezed,
/// and solid orange for today until it is logged.
struct DayCircleView: View {
    let number: Int
    let state: DayState
    let isToday: Bool
    var size: CGFloat = 40
    var font: Font = .title3

    private var isHighlighted: Bool {
        isToday && state == .none
    }

    var body: some View {
        Text("\(number)")
            .font(font)
            .fontWeight(isHighlighted ? .bold : .regular)
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(background, in: .circle)
    }

    private var foreground: Color {
        switch state {
        case .learned: .appAccent
        case .freezed: .freezeBlue
        case .none: .white
        }
    }

    private var background: Color {
        switch state {
        case .learned: Color.appAccent.opacity(0.2)
        case .freezed: Color.freezeBlue.opacity(0.2)
        case .none: isHighlighted ? .appAccent : .clear
        }
    }
}
