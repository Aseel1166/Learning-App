import SwiftData
import SwiftUI

/// View-only calendar of every learned and freezed day, month by month.
struct ActivityCalendarView: View {
    @Query private var logs: [DayLog]
    @State private var viewModel = ActivityCalendarViewModel()
    @State private var scrolledMonth: Date?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        let months = viewModel.months(from: logs)

        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(months) { month in
                        monthSection(month, isFirst: month.id == months.first?.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 12)
            }
            .scrollPosition(id: $scrolledMonth, anchor: .top)
            // Opens on the current month; earlier and later months are a scroll away.
            .onAppear {
                scrolledMonth = viewModel.currentMonthID
            }
        }
        .navigationTitle("Activities")
        .navigationBarTitleDisplayMode(.inline)
        // The design has nothing behind the title: no blur or fade over the scrolling days.
        .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
        .scrollEdgeEffectHidden(true, for: .top)
    }

    private func monthSection(_ month: CalendarMonth, isFirst: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isFirst {
                Divider()
                    .overlay(Color.white.opacity(0.15))
                    .padding(.horizontal, -12)
            }

            Text(month.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.top, isFirst ? 12 : 4)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(viewModel.weekdayHeaders.enumerated()), id: \.offset) { _, header in
                    Text(header)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.gray)
                }

                ForEach(0..<month.leadingBlanks, id: \.self) { _ in
                    Color.clear.frame(height: 36)
                }

                ForEach(month.days) { day in
                    DayCircleView(number: day.number, state: day.state, isToday: day.isToday, size: 36, font: .body)
                        .accessibilityLabel(accessibilityLabel(for: day))
                }
            }
        }
        .padding(.bottom, 16)
    }

    private func accessibilityLabel(for day: CalendarDay) -> String {
        let date = day.date.formatted(date: .complete, time: .omitted)
        switch day.state {
        case .learned: return "\(date), learned"
        case .freezed: return "\(date), freezed"
        case .none: return date
        }
    }
}

#Preview {
    // In-memory store with sample days over the last few months, only used for previews.
    let container = try! ModelContainer(
        for: LearningGoal.self, DayLog.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let goal = LearningGoal(subject: "Swift", duration: .month)
    container.mainContext.insert(goal)

    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: .now)
    for offset in 1...80 where offset % 4 != 0 {
        if let date = calendar.date(byAdding: .day, value: -offset, to: startOfToday) {
            let log = DayLog(date: date, kind: offset % 9 == 0 ? .freezed : .learned)
            container.mainContext.insert(log)
            log.goal = goal
        }
    }

    return NavigationStack {
        ActivityCalendarView()
    }
    .modelContainer(container)
    .preferredColorScheme(.dark)
}
