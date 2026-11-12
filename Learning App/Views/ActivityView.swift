import SwiftData
import SwiftUI

struct ActivityView: View {
    @State private var viewModel: ActivityViewModel
    @State private var isShowingNewGoal = false
    @State private var isShowingUpdateGoal = false
    @State private var isShowingCalendar = false
    @Environment(\.scenePhase) private var scenePhase

    init(goal: LearningGoal, modelContext: ModelContext) {
        _viewModel = State(initialValue: ActivityViewModel(goal: goal, modelContext: modelContext))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                WeekStripView(days: viewModel.weekDays)
                    .padding(.top, 16)

                statCards
                    .padding(.top, 16)

                if let result = viewModel.result {
                    Spacer()

                    GoalResultView(
                        systemImage: result.systemImage,
                        title: result.title,
                        message: result.message
                    ) {
                        isShowingNewGoal = true
                    }

                    Spacer()
                } else {
                    Spacer()

                    logButton

                    Spacer()

                    freezeSection
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $isShowingNewGoal) {
            NewGoalView { subject, duration in
                viewModel.startNewGoal(subject: subject, duration: duration)
            }
        }
        .navigationDestination(isPresented: $isShowingCalendar) {
            ActivityCalendarView()
        }
        .navigationDestination(isPresented: $isShowingUpdateGoal) {
            UpdateGoalView(goal: viewModel.goal) { subject, duration in
                viewModel.startNewGoal(subject: subject, duration: duration)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { viewModel.refresh() }
        }
        // Wakes at midnight and when the streak runs out, so the page never shows a stale state.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(viewModel.secondsUntilNextCheck))
                viewModel.refresh()
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Activity")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text(viewModel.dateText)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            Spacer()

            HStack(spacing: 12) {
                headerButton(systemImage: "calendar", label: "Calendar") {
                    isShowingCalendar = true
                }
                headerButton(systemImage: "pencil.and.outline", label: "Learning goal") {
                    isShowingUpdateGoal = true
                }
            }
        }
    }

    private func headerButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel(label)
    }

    private var statCards: some View {
        HStack(spacing: 12) {
            StatCardView(
                systemImage: "flame.fill",
                tint: .appAccent,
                value: viewModel.learnedCountText,
                title: "Learned"
            )
            StatCardView(
                systemImage: "snowflake",
                tint: .freezeBlue,
                value: viewModel.freezedCountText,
                title: "Freezed"
            )
        }
    }

    private var logButton: some View {
        Button {
            viewModel.logAsLearned()
        } label: {
            Text(viewModel.logButtonTitle)
                .font(.headline)
                .foregroundStyle(viewModel.canLogLearned ? .white : .gray)
                .frame(width: 200, height: 200)
        }
        .glassActionButton(isLit: viewModel.canLogLearned, tint: .appAccent)
        .buttonBorderShape(.circle)
        .disabled(!viewModel.canLogLearned)
    }

    private var freezeSection: some View {
        VStack(spacing: 14) {
            Button {
                viewModel.freezeToday()
            } label: {
                Text(viewModel.freezeButtonTitle)
                    .font(.body)
                    .foregroundStyle(viewModel.canFreeze ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .glassActionButton(isLit: viewModel.canFreeze, tint: .freezeBlue)
            .frame(maxWidth: 240)
            .disabled(!viewModel.canFreeze)

            Text(viewModel.freezesUsedText)
                .font(.caption)
                .foregroundStyle(.gray)
        }
    }
}

// MARK: - Previews

#Preview("Default") {
    ActivityPreview(today: nil, learned: 4, freezed: 0)
}

#Preview("Learned today") {
    ActivityPreview(today: .learned, learned: 4, freezed: 0)
}

#Preview("Freezed today") {
    ActivityPreview(today: .freezed, learned: 4, freezed: 0)
}

#Preview("No freezes available") {
    ActivityPreview(today: nil, learned: 3, freezed: 2)
}

#Preview("Goal completed") {
    ActivityPreview(today: nil, learned: 7, freezed: 2)
}

#Preview("Goal not met") {
    ActivityPreview(today: nil, learned: 2, freezed: 2, hoursSinceLastLog: 40)
}

/// Hosts `ActivityView` with an in-memory store filled with sample days before today.
private struct ActivityPreview: View {
    private let container: ModelContainer
    private let goal: LearningGoal

    init(today: DayKind?, learned: Int, freezed: Int, hoursSinceLastLog: Double = 1) {
        // In-memory store, only used for previews.
        let container = try! ModelContainer(
            for: LearningGoal.self, DayLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let goal = LearningGoal(subject: "Swift", duration: .week)
        container.mainContext.insert(goal)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let lastLoggedAt = Date.now.addingTimeInterval(-hoursSinceLastLog * 3600)
        let previousKinds = Array(repeating: DayKind.learned, count: learned)
            + Array(repeating: DayKind.freezed, count: freezed)

        for (index, kind) in previousKinds.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -(index + 1), to: startOfToday) {
                let log = DayLog(date: date, kind: kind, loggedAt: lastLoggedAt)
                container.mainContext.insert(log)
                log.goal = goal
            }
        }

        if let today {
            let log = DayLog(date: startOfToday, kind: today)
            container.mainContext.insert(log)
            log.goal = goal
        }

        self.container = container
        self.goal = goal
    }

    var body: some View {
        NavigationStack {
            ActivityView(goal: goal, modelContext: container.mainContext)
        }
        .modelContainer(container)
        .preferredColorScheme(.dark)
    }
}
