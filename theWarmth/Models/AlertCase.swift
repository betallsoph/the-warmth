import Foundation
import CoreLocation

struct AlertCase: Identifiable, Codable, Hashable {
    static func == (lhs: AlertCase, rhs: AlertCase) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    let id: UUID
    let personName: String?
    let location: LocationData
    let needs: [Need]
    let urgency: Urgency
    let description: String
    let reportedBy: String
    let reportedAt: Date
    var status: CaseStatus
    var helpersAssigned: Int
    
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
    
    enum CaseStatus: String, Codable {
        case open = "Open"
        case inProgress = "In Progress"
        case resolved = "Resolved"
        case verified = "Verified"
    }
    
    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let address: String
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
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
extension AlertCase {
    static let mockCases: [AlertCase] = [
        AlertCase(
            id: UUID(),
            personName: "Elderly woman near market",
            location: LocationData(
                latitude: 10.7769,
                longitude: 106.7009,
                address: "Ben Thanh Market, District 1"
            ),
            needs: [.food, .water, .blanket],
            urgency: .critical,
            description: "Elderly woman sitting outside Ben Thanh Market. Appears frail and hasn't eaten. Needs immediate food and water.",
            reportedBy: "Nguyen Van A",
            reportedAt: Date().addingTimeInterval(-3600),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: "Homeless man with dog",
            location: LocationData(
                latitude: 10.7756,
                longitude: 106.7019,
                address: "Nguyen Hue Walking Street"
            ),
            needs: [.food, .shelter, .medical],
            urgency: .high,
            description: "Man with small dog sleeping on street. Has visible injuries that may need medical attention.",
            reportedBy: "Tran Thi B",
            reportedAt: Date().addingTimeInterval(-7200),
            status: .inProgress,
            helpersAssigned: 2
        ),
        AlertCase(
            id: UUID(),
            personName: nil,
            location: LocationData(
                latitude: 10.7625,
                longitude: 106.6825,
                address: "District 3, near park"
            ),
            needs: [.clothing, .hygiene],
            urgency: .moderate,
            description: "Person sleeping in park entrance. Needs clean clothes and hygiene supplies.",
            reportedBy: "Le Van C",
            reportedAt: Date().addingTimeInterval(-10800),
            status: .open,
            helpersAssigned: 1
        ),
        AlertCase(
            id: UUID(),
            personName: "Family with children",
            location: LocationData(
                latitude: 10.7545,
                longitude: 106.6954,
                address: "Near bus station, District 5"
            ),
            needs: [.food, .water, .shelter, .clothing],
            urgency: .critical,
            description: "Family with two young children. Lost housing recently. Urgently need food and temporary shelter.",
            reportedBy: "Pham Thi D",
            reportedAt: Date().addingTimeInterval(-1800),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: "Young man near bridge",
            location: LocationData(
                latitude: 10.7890,
                longitude: 106.7100,
                address: "Thu Thiem Bridge, District 2"
            ),
            needs: [.food, .water],
            urgency: .moderate,
            description: "Young man asking for help near the bridge. Seems disoriented.",
            reportedBy: "Hoang Van E",
            reportedAt: Date().addingTimeInterval(-14400),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: "Elderly couple",
            location: LocationData(
                latitude: 10.7650,
                longitude: 106.6780,
                address: "Tao Dan Park, District 1"
            ),
            needs: [.medical, .food, .blanket],
            urgency: .high,
            description: "Elderly couple sleeping on bench. One appears to have breathing difficulties.",
            reportedBy: "Nguyen Thi F",
            reportedAt: Date().addingTimeInterval(-5400),
            status: .inProgress,
            helpersAssigned: 1
        ),
        AlertCase(
            id: UUID(),
            personName: "Woman with infant",
            location: LocationData(
                latitude: 10.7580,
                longitude: 106.6890,
                address: "District 10, near hospital"
            ),
            needs: [.food, .water, .clothing, .hygiene],
            urgency: .critical,
            description: "Young mother with infant. Baby needs formula and diapers urgently.",
            reportedBy: "Tran Van G",
            reportedAt: Date().addingTimeInterval(-900),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: nil,
            location: LocationData(
                latitude: 10.7720,
                longitude: 106.6950,
                address: "Pham Ngu Lao Street, District 1"
            ),
            needs: [.shelter, .clothing],
            urgency: .low,
            description: "Person sheltering under awning. Relatively stable but needs long-term support.",
            reportedBy: "Le Thi H",
            reportedAt: Date().addingTimeInterval(-21600),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: "Disabled veteran",
            location: LocationData(
                latitude: 10.7800,
                longitude: 106.6920,
                address: "September 23 Park, District 1"
            ),
            needs: [.medical, .food, .shelter],
            urgency: .high,
            description: "Veteran in wheelchair. Leg injury needs medical attention. Has been here for days.",
            reportedBy: "Pham Van I",
            reportedAt: Date().addingTimeInterval(-43200),
            status: .inProgress,
            helpersAssigned: 3
        ),
        AlertCase(
            id: UUID(),
            personName: "Teenage boy",
            location: LocationData(
                latitude: 10.7510,
                longitude: 106.7050,
                address: "District 4, near market"
            ),
            needs: [.food, .clothing, .shelter],
            urgency: .high,
            description: "Runaway teen, appears scared. Needs food and safe shelter.",
            reportedBy: "Nguyen Van K",
            reportedAt: Date().addingTimeInterval(-7200),
            status: .open,
            helpersAssigned: 0
        ),
        AlertCase(
            id: UUID(),
            personName: "Group of workers",
            location: LocationData(
                latitude: 10.7400,
                longitude: 106.7200,
                address: "Industrial area, District 7"
            ),
            needs: [.food, .water, .hygiene],
            urgency: .moderate,
            description: "Group of 5 migrant workers who lost jobs. Sharing temporary shelter but need food.",
            reportedBy: "Tran Thi L",
            reportedAt: Date().addingTimeInterval(-28800),
            status: .inProgress,
            helpersAssigned: 2
        ),
        AlertCase(
            id: UUID(),
            personName: "Elderly man with cane",
            location: LocationData(
                latitude: 10.7680,
                longitude: 106.7080,
                address: "Notre Dame Cathedral area"
            ),
            needs: [.food, .medical],
            urgency: .moderate,
            description: "Elderly man sitting near cathedral steps. Walking with difficulty.",
            reportedBy: "Hoang Thi M",
            reportedAt: Date().addingTimeInterval(-16200),
            status: .open,
            helpersAssigned: 1
        )
    ]

    static var preview: AlertCase {
        mockCases[0]
    }
}
