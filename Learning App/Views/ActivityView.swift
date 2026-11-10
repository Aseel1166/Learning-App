import SwiftData
import SwiftUI

struct ActivityView: View {
    @State private var viewModel: ActivityViewModel
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

                Spacer()

                logButton

                Spacer()

                freezeSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { viewModel.refreshToday() }
        }
        // Wakes at midnight so the buttons become available for the new day.
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(viewModel.secondsUntilNextDay))
                viewModel.refreshToday()
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
                // The calendar and learning goal screens are added in later branches.
                headerButton(systemImage: "calendar", label: "Calendar")
                headerButton(systemImage: "target", label: "Learning goal")
            }
        }
    }

    private func headerButton(systemImage: String, label: String) -> some View {
        Button {} label: {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.1), in: .circle)
        }
        .buttonStyle(.plain)
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
                .frame(width: 220, height: 220)
                .background(viewModel.canLogLearned ? Color.appAccent : Color.white.opacity(0.1), in: .circle)
        }
        .buttonStyle(.plain)
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
                    .frame(maxWidth: 240)
                    .frame(height: 44)
                    .background(viewModel.canFreeze ? Color.freezeBlue : Color.white.opacity(0.1), in: .capsule)
            }
            .buttonStyle(.plain)
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

/// Hosts `ActivityView` with an in-memory store filled with sample days before today.
private struct ActivityPreview: View {
    private let container: ModelContainer
    private let goal: LearningGoal

    init(today: DayKind?, learned: Int, freezed: Int) {
        // In-memory store, only used for previews.
        let container = try! ModelContainer(
            for: LearningGoal.self, DayLog.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let goal = LearningGoal(subject: "Swift", duration: .week)
        container.mainContext.insert(goal)

        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let previousKinds = Array(repeating: DayKind.learned, count: learned)
            + Array(repeating: DayKind.freezed, count: freezed)

        for (index, kind) in previousKinds.enumerated() {
            if let date = calendar.date(byAdding: .day, value: -(index + 1), to: startOfToday) {
                let log = DayLog(date: date, kind: kind)
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
        ActivityView(goal: goal, modelContext: container.mainContext)
            .modelContainer(container)
            .preferredColorScheme(.dark)
    }
}
