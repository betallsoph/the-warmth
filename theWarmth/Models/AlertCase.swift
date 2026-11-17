import Foundation
import CoreLocation
import SwiftData

enum HelpStatus {
    case urgent    // Red - needs help
    case partial   // Yellow - some help on the way
    case fulfilled // Green - enough helpers
    
    var color: String {
        switch self {
        case .urgent: return "red"
        case .partial: return "yellow"
        case .fulfilled: return "green"
        }
    }
    
    var label: String {
        switch self {
        case .urgent: return "Needs Help"
        case .partial: return "Help On The Way"
        case .fulfilled: return "Help Secured"
        }
    }
}

@Model
final class AlertCase {
    var id: UUID
    var personName: String?
    var latitude: Double
    var longitude: Double
    var address: String
    var needs: [String] // Store as String array for SwiftData
    var urgency: String
    var caseDescription: String
    var reportedBy: String
    var reportedAt: Date
    var status: String
    var helpersAssigned: Int
    var helpersOnTheWay: Int
    var maxHelpers: Int

    
    init(
        id: UUID = UUID(),
        personName: String? = nil,
        latitude: Double,
        longitude: Double,
        address: String,
        needs: [Need],
        urgency: Urgency,
        description: String,
        reportedBy: String,
        reportedAt: Date = Date(),
        status: CaseStatus = .open,
        helpersAssigned: Int = 0,
        helpersOnTheWay: Int = 0,
        maxHelpers: Int = 3
    ) {
        self.id = id
        self.personName = personName
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.needs = needs.map { $0.rawValue }
        self.urgency = urgency.rawValue
        self.caseDescription = description
        self.reportedBy = reportedBy
        self.reportedAt = reportedAt
        self.status = status.rawValue
        self.helpersAssigned = helpersAssigned
        self.helpersOnTheWay = helpersOnTheWay
        self.maxHelpers = maxHelpers
    }
}

extension AlertCase {
    // Computed properties for convenience
    var helpStatus: HelpStatus {
        let total = helpersAssigned + helpersOnTheWay
        if total == 0 { return .urgent }
        if total < maxHelpers { return .partial }
        return .fulfilled
    }
    
    var location: LocationData {
        LocationData(latitude: latitude, longitude: longitude, address: address)
    }
    
    var urgencyEnum: Urgency {
        Urgency(rawValue: urgency) ?? .moderate
    }
    
    var statusEnum: CaseStatus {
        CaseStatus(rawValue: status) ?? .open
    }
    
    var needsArray: [Need] {
        needs.compactMap { Need(rawValue: $0) }
    }
}

enum Urgency: String, Codable, CaseIterable {
    case critical = "Critical"
    case high = "High"
    case moderate = "Moderate"
    case low = "Low"
    
    var color: String {
        switch self {
        case .critical: return "red"
        case .high: return "orange"
        case .moderate: return "yellow"
        case .low: return "blue"
        }
    }
}

enum CaseStatus: String, Codable, CaseIterable {
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case verified = "Verified"
}

struct LocationData {
    let latitude: Double
    let longitude: Double
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum Need: String, Codable, CaseIterable {
    case food = "Food"
    case water = "Water"
    case blanket = "Blanket"
    case clothing = "Clothing"
    case medical = "Medical"
    case shelter = "Shelter"
    case hygiene = "Hygiene"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .water: return "drop.fill"
        case .blanket: return "bed.double.fill"
        case .clothing: return "tshirt.fill"
        case .medical: return "cross.case.fill"
        case .shelter: return "house.fill"
        case .hygiene: return "shower.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Mock Data
struct MockAlertCases {
    static var all: [AlertCase] {
        [
            // 90% basic needs: food, water, shelter, clothing
            AlertCase(
                id: UUID(),
                personName: "Elderly woman",
                latitude: 10.7724,
                longitude: 106.6980,
                address: "Ben Thanh Market, District 1",
                needs: [.food, .water],
                urgency: .moderate,
                description: "Elderly woman hasn't eaten today. Asking for food and water.",
                reportedBy: "Sarah Chen",
                reportedAt: Date().addingTimeInterval(-1800),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: "Man with backpack",
                latitude: 10.7746,
                longitude: 106.7012,
                address: "Nguyen Hue Walking Street",
                needs: [.food, .water],
                urgency: .low,
                description: "Person asking for help getting a meal.",
                reportedBy: "Michael Park",
                reportedAt: Date().addingTimeInterval(-3600),
                status: .open,
                helpersAssigned: 1,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: nil,
                latitude: 10.7820,
                longitude: 106.6896,
                address: "District 3, near park",
                needs: [.shelter, .blanket],
                urgency: .moderate,
                description: "Person sleeping on sidewalk. Needs blanket for tonight.",
                reportedBy: "Emma Wilson",
                reportedAt: Date().addingTimeInterval(-7200),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 1
            ),
            AlertCase(
                id: UUID(),
                personName: "Young woman",
                latitude: 10.7550,
                longitude: 106.6660,
                address: "Bus station, District 5",
                needs: [.food, .water],
                urgency: .moderate,
                description: "Young woman with children needs food. Missed last meal.",
                reportedBy: "David Martinez",
                reportedAt: Date().addingTimeInterval(-900),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 2
            ),
            AlertCase(
                id: UUID(),
                personName: "Elderly man",
                latitude: 10.7920,
                longitude: 106.7210,
                address: "Thu Thiem Bridge, District 2",
                needs: [.food, .water, .shelter],
                urgency: .moderate,
                description: "Elderly man asking for meal and place to rest for the night.",
                reportedBy: "James Anderson",
                reportedAt: Date().addingTimeInterval(-5400),
                status: .inProgress,
                helpersAssigned: 1,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: "Street vendor",
                latitude: 10.7831,
                longitude: 106.6958,
                address: "Tao Dan Park, District 1",
                needs: [.food, .water],
                urgency: .low,
                description: "Vendor who lost income today. Needs food assistance.",
                reportedBy: "Lisa Thompson",
                reportedAt: Date().addingTimeInterval(-10800),
                status: .open,
                helpersAssigned: 2,
                helpersOnTheWay: 1
            ),
            AlertCase(
                id: UUID(),
                personName: "Mother with baby",
                latitude: 10.7718,
                longitude: 106.6704,
                address: "District 10, residential area",
                needs: [.food, .water, .hygiene],
                urgency: .high,
                description: "Young mother with infant. Baby needs formula and diapers.",
                reportedBy: "Robert Kim",
                reportedAt: Date().addingTimeInterval(-600),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: nil,
                latitude: 10.7684,
                longitude: 106.6918,
                address: "Pham Ngu Lao Street",
                needs: [.shelter, .clothing],
                urgency: .low,
                description: "Person needs warm clothes and shelter for tonight.",
                reportedBy: "Jennifer Lee",
                reportedAt: Date().addingTimeInterval(-14400),
                status: .open,
                helpersAssigned: 1,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: "Construction worker",
                latitude: 10.7382,
                longitude: 106.7225,
                address: "Industrial area, District 7",
                needs: [.food, .water],
                urgency: .moderate,
                description: "Worker who lost day's wages. Asking for meal assistance.",
                reportedBy: "Daniel Brown",
                reportedAt: Date().addingTimeInterval(-2700),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 0
            ),
            AlertCase(
                id: UUID(),
                personName: "Family of 3",
                latitude: 10.7589,
                longitude: 106.7018,
                address: "District 4, near market",
                needs: [.food, .shelter],
                urgency: .high,
                description: "Family lost housing. Need food and temporary shelter tonight.",
                reportedBy: "Amanda White",
                reportedAt: Date().addingTimeInterval(-1200),
                status: .open,
                helpersAssigned: 0,
                helpersOnTheWay: 1
            ),
            // 10% medical emergencies
            AlertCase(
                id: UUID(),
                personName: "Injured cyclist",
                latitude: 10.7869,
                longitude: 106.6952,
                address: "September 23 Park, District 1",
                needs: [.medical],
                urgency: .critical,
                description: "Person fell from bicycle. Has visible injuries, needs immediate medical help.",
                reportedBy: "Kevin Davis",
                reportedAt: Date().addingTimeInterval(-300),
                status: .open,
                helpersAssigned: 1,
                helpersOnTheWay: 2
            ),
            AlertCase(
                id: UUID(),
                personName: "Elderly person collapsed",
                latitude: 10.7798,
                longitude: 106.6992,
                address: "Notre Dame Cathedral area",
                needs: [.medical],
                urgency: .critical,
                description: "Elderly person collapsed on street. Appears unconscious. Emergency assistance needed NOW.",
                reportedBy: "Michelle Taylor",
                reportedAt: Date().addingTimeInterval(-120),
                status: .inProgress,
                helpersAssigned: 2,
                helpersOnTheWay: 1
            )
        ]
    }
    
    static var preview: AlertCase {
        all[0]
    }
}
