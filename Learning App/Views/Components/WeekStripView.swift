import SwiftUI

/// The seven days of the current week with their learned/freezed state.
struct WeekStripView: View {
    let days: [ActivityViewModel.WeekDay]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                VStack(spacing: 8) {
                    Text(day.symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("\(day.number)")
                        .font(.title3)
                        .fontWeight(day.isToday && day.state == .none ? .bold : .regular)
                        .foregroundStyle(foreground(for: day))
                        .frame(width: 40, height: 40)
                        .background(background(for: day), in: .circle)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabel(for: day))
            }
        }
    }

    private func foreground(for day: ActivityViewModel.WeekDay) -> Color {
        switch day.state {
        case .learned: .appAccent
        case .freezed: .freezeBlue
        case .none: .white
        }
    }

    private func background(for day: ActivityViewModel.WeekDay) -> Color {
        switch day.state {
        case .learned: Color.appAccent.opacity(0.2)
        case .freezed: Color.freezeBlue.opacity(0.2)
        // Today stays highlighted until it is logged.
        case .none: day.isToday ? .appAccent : .clear
        }
    }

    private func accessibilityLabel(for day: ActivityViewModel.WeekDay) -> String {
        switch day.state {
        case .learned: "\(day.number), learned"
        case .freezed: "\(day.number), freezed"
        case .none: "\(day.number)"
        }
    }
}
