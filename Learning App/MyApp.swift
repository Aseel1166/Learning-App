import SwiftData
import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [LearningGoal.self, DayLog.self])
    }
}
