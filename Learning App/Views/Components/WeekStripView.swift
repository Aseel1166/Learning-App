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

                    DayCircleView(number: day.number, state: day.state, isToday: day.isToday)
                }
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityLabel(for: day))
            }
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
