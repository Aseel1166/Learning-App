import Foundation

/// The period the user chooses to reach their learning goal.
enum GoalDuration: String, CaseIterable, Identifiable, Codable {
    case week = "Week"
    case month = "Month"
    case year = "Year"

    var id: String { rawValue }

    /// Number of learned days needed to complete the goal.
    var requiredDays: Int {
        switch self {
        case .week: 7
        case .month: 30
        case .year: 365
        }
    }

    /// Number of freezes available during the goal.
    var allowedFreezes: Int {
        switch self {
        case .week: 2
        case .month: 8
        case .year: 96
        }
    }
}
