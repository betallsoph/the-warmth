//
//  UserProfile.swift
//  Our Warmth
//
//  User profile and activity tracking model
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var name: String
    var email: String?
    var createdAt: Date
    
    // Stats
    var casesHelped: Int
    var casesReported: Int
    var ongoingCases: Int
    
    // Activity history
    @Relationship(deleteRule: .cascade)
    var activities: [UserActivity]
    
    init(
        id: UUID = UUID(),
        name: String = "Anonymous Helper",
        email: String? = nil,
        createdAt: Date = Date(),
        casesHelped: Int = 0,
        casesReported: Int = 0,
        ongoingCases: Int = 0,
        activities: [UserActivity] = []
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
        self.casesHelped = casesHelped
        self.casesReported = casesReported
        self.ongoingCases = ongoingCases
        self.activities = activities
    }
    
    // Computed properties for badges
    var impactScore: Int {
        (casesHelped * 10) + (casesReported * 5) + (ongoingCases * 3)
    }
    
    var level: String {
        let score = impactScore
        if score >= 500 { return "Hero" }
        if score >= 250 { return "Champion" }
        if score >= 100 { return "Helper" }
        if score >= 50 { return "Supporter" }
        return "Newcomer"
    }
    
    var earnedBadges: [Badge] {
        var badges: [Badge] = []
        
        if casesHelped >= 1 { badges.append(.firstHelp) }
        if casesHelped >= 10 { badges.append(.tenHelps) }
        if casesHelped >= 50 { badges.append(.fiftyHelps) }
        if casesReported >= 1 { badges.append(.firstReport) }
        if casesReported >= 10 { badges.append(.tenReports) }
        if ongoingCases >= 3 { badges.append(.multiTasker) }
        
        return badges
    }
    
    static var preview: UserProfile {
        UserProfile(name: "Demo User", casesHelped: 12, casesReported: 3, ongoingCases: 5)
    }
    
    static func createWithMockData() -> UserProfile {
        let profile = UserProfile(
            name: "Demo User",
            casesHelped: 15,
            casesReported: 8,
            ongoingCases: 3
        )
        
        // Mock activities (20 items)
        let mockActivities: [(type: UserActivity.ActivityType, caseName: String?, hoursAgo: Double)] = [
            (.offered, "Elderly woman near market", 2),
            (.completed, "Elderly woman near market", 4),
            (.reported, "Man with dog", 6),
            (.offered, "Homeless man with dog", 8),
            (.offered, "Person in park", 12),
            (.completed, "Person in park", 14),
            (.reported, "Family near bus station", 18),
            (.offered, "Family with children", 20),
            (.reported, "Young man near bridge", 24),
            (.completed, "Homeless man with dog", 30),
            (.offered, "Elderly couple", 36),
            (.reported, "Woman with infant", 48),
            (.completed, "Elderly couple", 50),
            (.offered, "Young man near bridge", 60),
            (.reported, "Disabled veteran", 72),
            (.offered, "Woman with infant", 80),
            (.completed, "Woman with infant", 82),
            (.reported, "Teenage boy", 96),
            (.offered, "Disabled veteran", 110),
            (.completed, "Young man near bridge", 120)
        ]
        
        for item in mockActivities {
            let activity = UserActivity(
                caseId: UUID(),
                type: item.type,
                timestamp: Date().addingTimeInterval(-item.hoursAgo * 3600),
                caseName: item.caseName
            )
            profile.activities.append(activity)
        }
        
        return profile
    }
}

// MARK: - Badge System
enum Badge: String, CaseIterable {
    case firstHelp = "First Help"
    case tenHelps = "10 Helps"
    case fiftyHelps = "50 Helps"
    case firstReport = "First Report"
    case tenReports = "10 Reports"
    case multiTasker = "Multi-tasker"
    
    var icon: String {
        switch self {
        case .firstHelp: return "hand.raised.fill"
        case .tenHelps: return "star.fill"
        case .fiftyHelps: return "sparkles"
        case .firstReport: return "plus.circle.fill"
        case .tenReports: return "flame.fill"
        case .multiTasker: return "person.2.fill"
        }
    }
    
    var description: String {
        switch self {
        case .firstHelp: return "Offered help for the first time"
        case .tenHelps: return "Helped 10 people in need"
        case .fiftyHelps: return "Helped 50 people in need"
        case .firstReport: return "Reported your first case"
        case .tenReports: return "Reported 10 cases"
        case .multiTasker: return "Helping 3+ cases simultaneously"
        }
    }
    
    var color: String {
        switch self {
        case .firstHelp: return "blue"
        case .tenHelps: return "orange"
        case .fiftyHelps: return "purple"
        case .firstReport: return "green"
        case .tenReports: return "red"
        case .multiTasker: return "mint"
        }
    }
}

@Model
final class UserActivity {
    var id: UUID
    var caseId: UUID
    var type: ActivityType
    var timestamp: Date
    var caseName: String?
    
    enum ActivityType: String, Codable {
        case reported = "Reported"
        case offered = "Offered Help"
        case completed = "Completed"
        case verified = "Verified"
    }
    
    init(
        id: UUID = UUID(),
        caseId: UUID,
        type: ActivityType,
        timestamp: Date = Date(),
        caseName: String? = nil
    ) {
        self.id = id
        self.caseId = caseId
        self.type = type
        self.timestamp = timestamp
        self.caseName = caseName
    }
}
