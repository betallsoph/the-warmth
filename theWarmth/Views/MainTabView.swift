//
//  MainTabView.swift
//  Our Warmth
//
//  Main tab view with Liquid Glass design
//

import SwiftUI
import MapKit
import PhotosUI
import SwiftData

// MARK: - Urgency Color Helper
extension Urgency {
    var accentColor: Color {
        switch self {
        case .critical: return .red
        case .high:     return Color(hue: 0.07, saturation: 0.85, brightness: 0.95)
        case .moderate: return Color(hue: 0.13, saturation: 0.75, brightness: 0.95)
        case .low:      return .blue
        }
    }
}

// MARK: - Tab Selection
enum TabID: Hashable {
    case map
    case cases
    case home
    case add
}

struct MainTabView: View {
    @State private var selectedTab: TabID = .map
    @State private var previousTab: TabID = .map
    @State private var showCreateAlert = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Map", systemImage: "map.fill", value: .map) {
                MapView()
            }

            Tab("Cases", systemImage: "list.bullet.rectangle.fill", value: .cases) {
                AlertsListView()
            }

            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView()
            }

            Tab("Add", systemImage: "plus", value: .add, role: .search) {
                Color.clear
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                showCreateAlert = true
                selectedTab = oldValue
            }
            previousTab = oldValue
        }
        .sheet(isPresented: $showCreateAlert) {
            CreateAlertView()
        }
    }
}

// MARK: - Map View
struct MapView: View {
    @Query private var alertCases: [AlertCase]
    
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var selectedCaseId: UUID?
    @State private var showLocationDenied = false
    @State private var selectedCaseForDetail: AlertCase?
    
    private var selectedCase: AlertCase? {
        guard let selectedCaseId else { return nil }
        return alertCases.first(where: { $0.id == selectedCaseId })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedCaseId) {
                ForEach(alertCases) { alertCase in
                    Marker(alertCase.personName ?? "Unknown", coordinate: alertCase.location.coordinate)
                        .tint(alertCase.urgencyEnum.accentColor)
                        .tag(alertCase.id)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange { _ in
                // dismiss card when user pans away
            }

            if let selectedCase {
                SelectedCaseCard(
                    alertCase: selectedCase,
                    onDismiss: {
                        withAnimation(.spring(duration: 0.3)) {
                            self.selectedCaseId = nil
                        }
                    },
                    onOfferHelp: {
                        selectedCaseForDetail = selectedCase
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        .alert("Location Access Denied", isPresented: $showLocationDenied) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable location in Settings to see cases near you.")
        }
        .sheet(item: $selectedCaseForDetail) { alertCase in
            CaseDetailView(alertCase: alertCase)
        }
    }
}

// MARK: - Case Marker View
struct CaseMarkerView: View {
    let alertCase: AlertCase
    let isSelected: Bool

    private var size: CGFloat { isSelected ? 44 : 34 }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(alertCase.urgencyEnum.accentColor)
                    .frame(width: size, height: size)
                    .shadow(
                        color: alertCase.urgencyEnum.accentColor.opacity(0.35),
                        radius: isSelected ? 10 : 4,
                        x: 0, y: 3
                    )

                Image(systemName: alertCase.needsArray.first?.icon ?? "person.fill")
                    .font(.system(size: isSelected ? 20 : 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(alertCase.urgencyEnum.accentColor)
                .frame(width: 10, height: 7)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(duration: 0.2), value: isSelected)
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Cluster Annotation View
struct ClusterAnnotationView: View {
    let count: Int
    
    private var size: CGFloat {
        if count < 10 { return 44 }
        if count < 50 { return 52 }
        return 60
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.blue)
                .frame(width: size, height: size)
                .shadow(color: .blue.opacity(0.35), radius: 8, x: 0, y: 4)
            
            Text("\(count)")
                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Selected Case Card (map pop-up)
struct SelectedCaseCard: View {
    let alertCase: AlertCase
    let onDismiss: () -> Void
    let onOfferHelp: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(alertCase.personName ?? "Anonymous")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .shadow(color: .white.opacity(0.5), radius: 8, x: 0, y: 0)

                        Label(alertCase.location.address, systemImage: "mappin")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundStyle(.secondary)
                            .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 0)
                    }

                    Spacer()

                    Text(alertCase.urgency)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .glassEffect(.regular.tint(alertCase.urgencyEnum.accentColor), in: .capsule)

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.tertiary)
                            .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 0)
                    }
                    .accessibilityLabel("Close")
                    .accessibilityHint("Dismiss case details")
                }

                Text(alertCase.caseDescription)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .shadow(color: .white.opacity(0.3), radius: 4, x: 0, y: 0)
                    .lineLimit(2)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(alertCase.needsArray, id: \.self) { need in
                            HStack(spacing: 5) {
                                Image(systemName: need.icon).font(.system(size: 11))
                                Text(need.rawValue).font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glassEffect(.regular, in: .capsule)
                        }
                    }
                }

                Button(action: onOfferHelp) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("I'll take care of this")
                    }
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.glassProminent)
                .accessibilityLabel("I'll take care of this for \(alertCase.personName ?? "this person")")
                .accessibilityHint("Double tap to volunteer assistance for this case")
            }
            .padding(16)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

// MARK: - Case Detail View
struct CaseDetailView: View {
    let alertCase: AlertCase
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var showOfferConfirmation = false
    @State private var isHelper = false // simulate user offered help
    @State private var showStatusUpdate = false
    @State private var showReportSheet = false
    @State private var currentStatus: CaseStatus

    init(alertCase: AlertCase) {
        self.alertCase = alertCase
        _currentStatus = State(initialValue: alertCase.statusEnum)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Urgency banner
                    HStack(spacing: 12) {
                        Image(systemName: urgencyIcon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(alertCase.urgencyEnum.accentColor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(alertCase.urgency + " Priority")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(alertCase.urgencyEnum.accentColor)
                            
                            HStack(spacing: 6) {
                                Text(statusLabel(for: currentStatus))
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundStyle(.secondary)
                                
                                if isHelper {
                                    Button {
                                        showStatusUpdate = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.blue)
                                    }
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            // Help status indicator
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(helpStatusColor)
                                    .frame(width: 8, height: 8)
                                Text(alertCase.helpStatus.label)
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(helpStatusColor)
                            }
                            
                            // Helper counts - X/3 format
                            let totalHelpers = alertCase.helpersOnTheWay + alertCase.helpersAssigned
                            if totalHelpers > 0 {
                                Text("\(totalHelpers)/\(alertCase.maxHelpers) helped")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(helpStatusColor.opacity(0.08))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About this case")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(alertCase.caseDescription)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineSpacing(3)
                    }

                    // Needs
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Needs")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(alertCase.needsArray, id: \.self) { need in
                                HStack(spacing: 8) {
                                    Image(systemName: need.icon)
                                        .font(.system(size: 14))
                                        .foregroundStyle(alertCase.urgencyEnum.accentColor)
                                    Text(need.rawValue)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(.primary)
                                    Spacer()
                                }
                                .padding(12)
                                .background {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(.quaternary)
                                }
                            }
                        }
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Location")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        Map(initialPosition: .region(MKCoordinateRegion(
                            center: alertCase.location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))) {
                            Annotation("", coordinate: alertCase.location.coordinate) {
                                Circle()
                                    .fill(alertCase.urgencyEnum.accentColor)
                                    .frame(width: 16, height: 16)
                                    .shadow(color: alertCase.urgencyEnum.accentColor.opacity(0.4), radius: 6)
                            }
                        }
                        .mapStyle(.standard(pointsOfInterest: .excludingAll))
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        Label(alertCase.location.address, systemImage: "mappin.and.ellipse")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    // Meta
                    HStack {
                        Label(timeAgo(from: alertCase.reportedAt), systemImage: "clock")
                        Spacer()
                        Label("Reported by \(alertCase.reportedBy)", systemImage: "person")
                    }
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.tertiary)
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .background {
                Color.clear
                    .background(.regularMaterial)
            }
            .navigationTitle(alertCase.personName ?? "Anonymous")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        // Debug: Simulate helpers
                        Section("Debug Helper Simulation") {
                            Button {
                                if alertCase.helpersOnTheWay > 0 {
                                    alertCase.helpersOnTheWay -= 1
                                    alertCase.helpersAssigned += 1
                                }
                                try? modelContext.save()
                            } label: {
                                Label("Convert: On Way → Arrived", systemImage: "arrow.right.circle")
                            }
                            .disabled(alertCase.helpersOnTheWay == 0)
                            
                            Button {
                                if alertCase.helpersOnTheWay + alertCase.helpersAssigned < alertCase.maxHelpers {
                                    alertCase.helpersOnTheWay += 1
                                }
                                try? modelContext.save()
                            } label: {
                                Label("Add Helper On The Way", systemImage: "plus.circle")
                            }
                            .disabled(alertCase.helpersOnTheWay + alertCase.helpersAssigned >= alertCase.maxHelpers)
                        }
                        
                        Section {
                            Button(role: .destructive) {
                                showReportSheet = true
                            } label: {
                                Label("Report Case", systemImage: "exclamationmark.triangle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 18))
                    }
                    .buttonStyle(.glass)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !isHelper {
                    let totalHelpers = alertCase.helpersOnTheWay + alertCase.helpersAssigned
                    let isCapacityFull = totalHelpers >= alertCase.maxHelpers
                    
                    Button(action: { 
                        showOfferConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("I'll take care of this")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(isCapacityFull)
                    .opacity(isCapacityFull ? 0.5 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
                    .padding(.top, 8)
                    .accessibilityLabel(isCapacityFull ? "This case has enough helpers" : "I'll take care of this")
                    .accessibilityHint(isCapacityFull ? "Maximum helpers reached" : "Offer to help with this case")
                }
            }
            .alert("You're on the way!", isPresented: $showOfferConfirmation) {
                Button("OK") {
                    isHelper = true
                    if currentStatus == .open {
                        currentStatus = .inProgress
                    }
                    
                    // Increment helpersOnTheWay count
                    alertCase.helpersOnTheWay += 1
                    
                    // Track activity
                    if let profile = profiles.first {
                        let newActivity = UserActivity(
                            caseId: alertCase.id,
                            type: .offered,
                            caseName: alertCase.personName
                        )
                        profile.activities.append(newActivity)
                        profile.ongoingCases += 1
                        try? modelContext.save()
                    }
                }
            } message: {
                Text("You're now marked as helping with this case. The person in need will see you're on the way.")
            }
            .sheet(isPresented: $showStatusUpdate) {
                StatusUpdateSheet(currentStatus: $currentStatus)
            }
            .sheet(isPresented: $showReportSheet) {
                ReportCaseSheet()
            }
        }
    }

    private var urgencyIcon: String {
        switch alertCase.urgencyEnum {
        case .critical: return "exclamationmark.3"
        case .high:     return "exclamationmark.2"
        case .moderate: return "exclamationmark"
        case .low:      return "info.circle"
        }
    }

    private func statusLabel(for status: CaseStatus) -> String {
        switch status {
        case .open:       return "Awaiting help"
        case .inProgress: return "Help on the way"
        case .resolved:   return "Resolved"
        case .verified:   return "Verified & resolved"
        }
    }
    
    private var helpStatusColor: Color {
        switch alertCase.helpStatus {
        case .urgent: return .red
        case .partial: return .orange
        case .fulfilled: return .green
        }
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        if hours > 0 { return "\(hours)h ago" }
        if minutes > 0 { return "\(minutes)m ago" }
        return "Just now"
    }
}

// MARK: - Alerts List View
struct AlertsListView: View {
    @Query private var allCases: [AlertCase]
    @State private var selectedCase: AlertCase?
    @State private var searchText = ""
    @State private var showFilters = false

    @State private var filterUrgency: Set<Urgency> = []
    @State private var filterStatus: Set<CaseStatus> = []
    @State private var filterNeeds: Set<Need> = []
    @State private var sortOption: SortOption = .newest

    enum SortOption: String, CaseIterable {
        case newest = "Newest First"
        case oldest = "Oldest First"
        case urgent = "Most Urgent"
        case nearby = "Nearby" // placeholder for when we have real location
    }

    private var filtered: [AlertCase] {
        var cases = allCases
        
        // Search filter
        if !searchText.isEmpty {
            cases = cases.filter {
                ($0.personName ?? "").localizedCaseInsensitiveContains(searchText) ||
                $0.location.address.localizedCaseInsensitiveContains(searchText) ||
                $0.caseDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Urgency filter
        if !filterUrgency.isEmpty {
            cases = cases.filter { filterUrgency.contains($0.urgencyEnum) }
        }
        
        // Status filter
        if !filterStatus.isEmpty {
            cases = cases.filter { filterStatus.contains($0.statusEnum) }
        }
        
        // Needs filter
        if !filterNeeds.isEmpty {
            cases = cases.filter { alertCase in
                !Set(alertCase.needsArray).isDisjoint(with: filterNeeds)
            }
        }
        
        // Sort
        switch sortOption {
        case .newest:
            cases.sort { $0.reportedAt > $1.reportedAt }
        case .oldest:
            cases.sort { $0.reportedAt < $1.reportedAt }
        case .urgent:
            let urgencyOrder: [Urgency] = [.critical, .high, .moderate, .low]
            cases.sort { urgencyOrder.firstIndex(of: $0.urgencyEnum)! < urgencyOrder.firstIndex(of: $1.urgencyEnum)! }
        case .nearby:
            // placeholder - would need real location
            break
        }
        
        return cases
    }
    
    private var hasActiveFilters: Bool {
        !filterUrgency.isEmpty || !filterStatus.isEmpty || !filterNeeds.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Active filters chips
                    if hasActiveFilters {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(filterUrgency), id: \.self) { urgency in
                                    FilterChip(label: urgency.rawValue, color: urgency.accentColor) {
                                        filterUrgency.remove(urgency)
                                    }
                                }
                                ForEach(Array(filterStatus), id: \.self) { status in
                                    FilterChip(label: status.rawValue, color: .primary) {
                                        filterStatus.remove(status)
                                    }
                                }
                                ForEach(Array(filterNeeds), id: \.self) { need in
                                    FilterChip(label: need.rawValue, color: .secondary) {
                                        filterNeeds.remove(need)
                                    }
                                }
                                
                                Button {
                                    filterUrgency.removeAll()
                                    filterStatus.removeAll()
                                    filterNeeds.removeAll()
                                } label: {
                                    Text("Clear All")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(.red)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(.red.opacity(0.1)))
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 4)
                    }
                    
                    ForEach(filtered) { alertCase in
                        Button {
                            selectedCase = alertCase
                        } label: {
                            AlertCaseCard(alertCase: alertCase)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if filtered.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48, weight: .light))
                                .foregroundStyle(Color(red: 0.85, green: 0.30, blue: 0.50).opacity(0.5))
                            Text("No cases found")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.85, green: 0.30, blue: 0.50))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.99),
                        Color(red: 0.995, green: 0.96, blue: 0.98),
                        Color(red: 0.99, green: 0.94, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Active Cases")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cases")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort by") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    sortOption = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        Spacer()
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Button {
                            showFilters = true
                        } label: {
                            Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                        }
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundStyle(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
            .sheet(item: $selectedCase) { alertCase in
                CaseDetailView(alertCase: alertCase)
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet(
                    filterUrgency: $filterUrgency,
                    filterStatus: $filterStatus,
                    filterNeeds: $filterNeeds
                )
            }
        }
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let label: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.15)))
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filterUrgency: Set<Urgency>
    @Binding var filterStatus: Set<CaseStatus>
    @Binding var filterNeeds: Set<Need>
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Urgency") {
                    ForEach(Urgency.allCases, id: \.self) { urgency in
                        Toggle(isOn: Binding(
                            get: { filterUrgency.contains(urgency) },
                            set: { isOn in
                                if isOn { filterUrgency.insert(urgency) }
                                else { filterUrgency.remove(urgency) }
                            }
                        )) {
                            Label(urgency.rawValue, systemImage: "exclamationmark.circle.fill")
                                .foregroundStyle(urgency.accentColor)
                        }
                    }
                }
                
                Section("Status") {
                    ForEach(CaseStatus.allCases, id: \.self) { status in
                        Toggle(isOn: Binding(
                            get: { filterStatus.contains(status) },
                            set: { isOn in
                                if isOn { filterStatus.insert(status) }
                                else { filterStatus.remove(status) }
                            }
                        )) {
                            Text(status.rawValue)
                        }
                    }
                }
                
                Section("Needs") {
                    ForEach(Need.allCases, id: \.self) { need in
                        Toggle(isOn: Binding(
                            get: { filterNeeds.contains(need) },
                            set: { isOn in
                                if isOn { filterNeeds.insert(need) }
                                else { filterNeeds.remove(need) }
                            }
                        )) {
                            Label(need.rawValue, systemImage: need.icon)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        filterUrgency.removeAll()
                        filterStatus.removeAll()
                        filterNeeds.removeAll()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.glass)
                }
            }
        }
    }
}

struct AlertCaseCard: View {
    let alertCase: AlertCase
    
    private var accessibilityDescription: String {
        let needsList = alertCase.needsArray.map { $0.rawValue }.joined(separator: ", ")
        let helpStatus = alertCase.helpersAssigned > 0 ? "\(alertCase.helpersAssigned) people helping." : "No helpers yet."
        return "\(alertCase.urgency) priority case. \(alertCase.personName ?? "Anonymous") at \(alertCase.location.address). Needs: \(needsList). \(helpStatus)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(alertCase.personName ?? "Anonymous")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.90, green: 0.25, blue: 0.45))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)

                    Label(alertCase.location.address, systemImage: "mappin")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }

                Spacer()

                Text(alertCase.urgency)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(alertCase.urgencyEnum.accentColor))
            }

            Text(alertCase.caseDescription)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(alertCase.needsArray, id: \.self) { need in
                        Label(need.rawValue, systemImage: need.icon)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(.quaternary))
                    }
                }
            }

            HStack {
                Label(timeAgo(from: alertCase.reportedAt), systemImage: "clock")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.tertiary)

                Spacer()

                if alertCase.helpersAssigned > 0 {
                    Label("\(alertCase.helpersAssigned) helping", systemImage: "person.2.fill")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Double tap to view full case details and offer help")
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        if hours > 0 { return "\(hours)h ago" }
        if minutes > 0 { return "\(minutes)m ago" }
        return "Just now"
    }
}

// MARK: - Create Alert View
struct CreateAlertView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var personName = ""
    @State private var description = ""
    @State private var selectedNeeds: Set<Need> = []
    @State private var selectedUrgency: Urgency = .moderate
    @State private var address = ""
    @State private var showSubmitConfirmation = false
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []
    @State private var isProcessingPhotos = false

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedNeeds.isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            List {
                // Person name (optional)
                Section {
                    TextField("Name or description", text: $personName)
                        .font(.system(size: 17, design: .rounded))
                } header: {
                    Text("Who needs help?")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }

                // Description (required)
                Section {
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("What did you observe?")
                                .font(.system(size: 17, design: .rounded))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                        }
                        TextEditor(text: $description)
                            .font(.system(size: 17, design: .rounded))
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                    }
                } header: {
                    Text("Describe the situation *")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }

                // Location (required)
                Section {
                    TextField("Street address or landmark", text: $address)
                        .font(.system(size: 17, design: .rounded))
                } header: {
                    Text("Location *")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }

                // Photos (optional)
                Section {
                        VStack(spacing: 12) {
                            if isProcessingPhotos {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Detecting and blurring faces...")
                                        .font(.system(size: 13, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                            }
                            
                            if !photoImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(Array(photoImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                                
                                                Button {
                                                    photoImages.remove(at: index)
                                                    selectedPhotos.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(.white)
                                                        .background(Circle().fill(.black.opacity(0.5)))
                                                }
                                                .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 3, matching: .images) {
                                HStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 16))
                                    Text(photoImages.isEmpty ? "Add Photos" : "Add More Photos")
                                        .font(.system(size: 15, weight: .medium, design: .rounded))
                                }
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .disabled(isProcessingPhotos)
                            
                            // Privacy notice
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.green)
                                Text("Faces are automatically blurred to protect privacy")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onChange(of: selectedPhotos) { _, newItems in
                                Task {
                                    photoImages.removeAll()
                                    for item in newItems {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            // Auto blur faces for privacy
                                            await blurAndAppend(image)
                                        }
                                    }
                                }
                            }
                        }
                    }

                // Urgency
                Section {
                    HStack(spacing: 8) {
                        ForEach(Urgency.allCases, id: \.self) { urgency in
                            Button {
                                selectedUrgency = urgency
                            } label: {
                                Text(urgency.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(selectedUrgency == urgency ? .white : .primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        Capsule()
                                            .fill(selectedUrgency == urgency
                                                  ? urgency.accentColor
                                                  : Color(.secondarySystemGroupedBackground))
                                    }
                            }
                            .buttonStyle(.plain)
                            .animation(.spring(duration: 0.2), value: selectedUrgency)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Urgency level")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .textCase(.none)
                }

                    // Needs (required)
                    FormSection(title: "What do they need? *") {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(Need.allCases, id: \.self) { need in
                                Button {
                                    if selectedNeeds.contains(need) {
                                        selectedNeeds.remove(need)
                                    } else {
                                        selectedNeeds.insert(need)
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: need.icon)
                                            .font(.system(size: 14))
                                            .foregroundStyle(selectedNeeds.contains(need) ? .white : .secondary)
                                        Text(need.rawValue)
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(selectedNeeds.contains(need) ? .white : .primary)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .fill(selectedNeeds.contains(need)
                                                  ? Color.primary
                                                  : Color(.secondarySystemGroupedBackground))
                                    }
                                }
                                .buttonStyle(.plain)
                                .animation(.spring(duration: 0.2), value: selectedNeeds)
                            }
                        }
                    }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background {
                Color.clear
                    .background(.regularMaterial)
            }
            .navigationTitle("Report a Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.glass)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showSubmitConfirmation = true
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!isValid)
                }
            }
            .alert("Report Submitted", isPresented: $showSubmitConfirmation) {
                Button("Done") {
                    // Create and save the new AlertCase
                    let newCase = AlertCase(
                        personName: personName.isEmpty ? nil : personName,
                        latitude: 10.7769,  // Default to HCMC center for now
                        longitude: 106.7009,
                        address: address,
                        needs: Array(selectedNeeds),
                        urgency: selectedUrgency,
                        description: description,
                        reportedBy: profiles.first?.name ?? "Anonymous",
                        reportedAt: Date(),
                        status: .open
                    )
                    
                    modelContext.insert(newCase)
                    
                    // Track activity
                    if let profile = profiles.first {
                        let newActivity = UserActivity(
                            caseId: newCase.id,
                            type: .reported,
                            caseName: personName.isEmpty ? nil : personName
                        )
                        profile.activities.append(newActivity)
                        profile.casesReported += 1
                    }
                    
                    try? modelContext.save()
                    dismiss()
                }
            } message: {
                Text("Thank you for reporting. Nearby volunteers will be notified.")
            }
        }
    }
    
    // Helper function to blur faces
    private func blurAndAppend(_ image: UIImage) async {
        await MainActor.run { isProcessingPhotos = true }
        
        await withCheckedContinuation { continuation in
            FaceBlurProcessor.blurFaces(in: image) { blurredImage in
                Task { @MainActor in
                    if let processed = blurredImage {
                        photoImages.append(processed)
                    }
                    isProcessingPhotos = false
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - Form Section Helper
struct FormSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Home View
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var alertCases: [AlertCase]
    @State private var showProfile = false
    
    private var currentProfile: UserProfile {
        if let profile = profiles.first {
            return profile
        }
        // Create profile with mock data for demo
        let newProfile = UserProfile.createWithMockData()
        modelContext.insert(newProfile)
        try? modelContext.save()
        return newProfile
    }
    
    private var activeAlerts: Int {
        alertCases.filter { $0.statusEnum == .open || $0.statusEnum == .inProgress }.count
    }
    
    private var urgentAlerts: Int {
        alertCases.filter { $0.urgencyEnum == .critical || $0.urgencyEnum == .high }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile summary card
                    GlassEffectContainer(spacing: 20) {
                        Button {
                            showProfile = true
                        } label: {
                            HStack(spacing: 16) {
                                // Avatar
                                ZStack {
                                    Circle()
                                        .fill(.quaternary)
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28))
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(currentProfile.name)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)
                                    
                                    Text("\(currentProfile.level) • \(currentProfile.impactScore) pts")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(16)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(in: .rect(cornerRadius: 18))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Stats overview
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Community Overview")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.90, green: 0.25, blue: 0.45))
                            .padding(.horizontal, 20)
                        
                        GlassEffectContainer(spacing: 20) {
                            VStack(spacing: 0) {
                                HomeStatRow(
                                    icon: "exclamationmark.triangle.fill",
                                    iconColor: .red,
                                    label: "Active Alerts",
                                    value: "\(activeAlerts)"
                                )
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                HomeStatRow(
                                    icon: "bolt.fill",
                                    iconColor: .orange,
                                    label: "Urgent Cases",
                                    value: "\(urgentAlerts)"
                                )
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                HomeStatRow(
                                    icon: "heart.fill",
                                    iconColor: .green,
                                    label: "People Helped",
                                    value: "\(currentProfile.casesHelped)"
                                )
                            }
                            .padding(.vertical, 8)
                            .glassEffect(in: .rect(cornerRadius: 18))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Explore section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Explore")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.90, green: 0.25, blue: 0.45))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            NavigationLink {
                                AnimalAlertsView()
                            } label: {
                                ExploreCard(
                                    title: "Animals Need Help Too",
                                    subtitle: "Not only humans need help, animals also deserve our care",
                                    icon: "pawprint.fill",
                                    gradient: LinearGradient(
                                        colors: [Color.orange.opacity(0.7), Color.pink.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                CharityKitchensView()
                            } label: {
                                ExploreCard(
                                    title: "Charity Kitchens",
                                    subtitle: "Find free meals and community kitchens near you",
                                    icon: "fork.knife",
                                    gradient: LinearGradient(
                                        colors: [Color.green.opacity(0.7), Color.mint.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                FreeSupplyPointsView()
                            } label: {
                                ExploreCard(
                                    title: "Free Supply Points",
                                    subtitle: "Locate donation centers offering free essentials",
                                    icon: "shippingbox.fill",
                                    gradient: LinearGradient(
                                        colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Placeholder for future content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Actions")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.90, green: 0.25, blue: 0.45))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            PlaceholderCard(title: "Leaderboard", subtitle: "See top contributors", icon: "chart.bar.fill")
                            PlaceholderCard(title: "Impact Stories", subtitle: "Read success stories", icon: "book.fill")
                            PlaceholderCard(title: "Community News", subtitle: "Latest updates", icon: "newspaper.fill")
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.99),
                        Color(red: 0.995, green: 0.96, blue: 0.98),
                        Color(red: 0.99, green: 0.94, blue: 0.96)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("Our Warmth")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

// MARK: - Home Stat Row
struct HomeStatRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
                .frame(width: 24, height: 24)
            
            Text(label)
                .font(.system(size: 16, design: .rounded))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Explore Card
struct ExploreCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 180)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(gradient)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        }
    }
}

// MARK: - Placeholder Card
struct PlaceholderCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Animal Alerts View
struct AnimalAlertsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "pawprint.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 20)
                    
                    Text("Animal Rescue")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Not only humans need help.\nAnimals also deserve our care and compassion.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Coming soon message
                GlassEffectContainer(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.orange)
                        
                        Text("Coming Soon")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("We're building a dedicated space to help animals in need. Report injured, lost, or stray animals that need assistance.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 20)
                    .glassEffect(in: .rect(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
                
                // Feature preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upcoming Features")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        FeaturePreviewRow(
                            icon: "location.fill",
                            title: "Report Strays",
                            description: "Help lost or stray animals find their way home"
                        )
                        
                        FeaturePreviewRow(
                            icon: "cross.case.fill",
                            title: "Medical Help",
                            description: "Alert for injured animals needing care"
                        )
                        
                        FeaturePreviewRow(
                            icon: "house.fill",
                            title: "Foster Network",
                            description: "Connect animals with temporary homes"
                        )
                        
                        FeaturePreviewRow(
                            icon: "heart.fill",
                            title: "Adoption",
                            description: "Find forever homes for rescued animals"
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Animal Rescue")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Charity Kitchens View
struct CharityKitchensView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.mint.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "fork.knife")
                            .font(.system(size: 46))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .mint],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 20)
                    
                    Text("Charity Kitchens")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Find free meals and community kitchens\noffering warm food to those in need.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Coming soon message
                GlassEffectContainer(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.green)
                        
                        Text("Coming Soon")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("We're mapping charity kitchens and meal distribution points across the community to help everyone find warm meals nearby.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 20)
                    .glassEffect(in: .rect(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
                
                // Feature preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upcoming Features")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        FeaturePreviewRow(
                            icon: "map.fill",
                            iconGradient: [.green, .mint],
                            title: "Interactive Map",
                            description: "See all charity kitchens on the map"
                        )
                        
                        FeaturePreviewRow(
                            icon: "clock.fill",
                            iconGradient: [.green, .mint],
                            title: "Meal Times",
                            description: "View serving schedules and hours"
                        )
                        
                        FeaturePreviewRow(
                            icon: "person.3.fill",
                            iconGradient: [.green, .mint],
                            title: "Capacity Info",
                            description: "Check available spots in real-time"
                        )
                        
                        FeaturePreviewRow(
                            icon: "star.fill",
                            iconGradient: [.green, .mint],
                            title: "Reviews",
                            description: "Community ratings and experiences"
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Charity Kitchens")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Free Supply Points View
struct FreeSupplyPointsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "shippingbox.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 20)
                    
                    Text("Free Supply Points")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Locate donation centers offering free\nclothing, hygiene products, and essentials.")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Coming soon message
                GlassEffectContainer(spacing: 20) {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(.blue)
                        
                        Text("Coming Soon")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("We're building a directory of donation centers where you can get free essentials like clothing, hygiene products, and daily necessities.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 20)
                    .glassEffect(in: .rect(cornerRadius: 20))
                }
                .padding(.horizontal, 20)
                
                // Feature preview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upcoming Features")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 12) {
                        FeaturePreviewRow(
                            icon: "tshirt.fill",
                            iconGradient: [.blue, .cyan],
                            title: "Clothing Donations",
                            description: "Free clothes for all ages and sizes"
                        )
                        
                        FeaturePreviewRow(
                            icon: "shower.fill",
                            iconGradient: [.blue, .cyan],
                            title: "Hygiene Products",
                            description: "Personal care items and toiletries"
                        )
                        
                        FeaturePreviewRow(
                            icon: "bag.fill",
                            iconGradient: [.blue, .cyan],
                            title: "Daily Essentials",
                            description: "Basic necessities and supplies"
                        )
                        
                        FeaturePreviewRow(
                            icon: "calendar.badge.clock",
                            iconGradient: [.blue, .cyan],
                            title: "Availability",
                            description: "Real-time stock and opening hours"
                        )
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Free Supply Points")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Feature Preview Row
struct FeaturePreviewRow: View {
    let icon: String
    var iconGradient: [Color] = [.orange, .pink]
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: iconGradient.map { $0.opacity(0.2) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: iconGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @State private var showEditProfile = false
    
    private var currentProfile: UserProfile {
        if let profile = profiles.first {
            return profile
        }
        // Create profile with mock data for demo
        let newProfile = UserProfile.createWithMockData()
        modelContext.insert(newProfile)
        try? modelContext.save()
        return newProfile
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(.quaternary)
                            .frame(width: 100, height: 100)

                        Image(systemName: "person.fill")
                            .font(.system(size: 46))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 16)
                    
                    // Name
                    Text(currentProfile.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)

                    // Level badge
                    VStack(spacing: 4) {
                        Text(currentProfile.level)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text("\(currentProfile.impactScore) Impact Score")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.tertiary)
                    }
                    
                    // Stats
                    GlassEffectContainer(spacing: 20) {
                        HStack(spacing: 1) {
                            ProfileStat(value: "\(currentProfile.casesHelped)", label: "Helped")
                            Divider().frame(height: 32).opacity(0.3)
                            ProfileStat(value: "\(currentProfile.ongoingCases)", label: "Ongoing")
                            Divider().frame(height: 32).opacity(0.3)
                            ProfileStat(value: "\(currentProfile.casesReported)", label: "Reported")
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 8)
                        .glassEffect(in: .rect(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                    
                    // Badges
                    if !currentProfile.earnedBadges.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Badges Earned")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(currentProfile.earnedBadges, id: \.self) { badge in
                                        BadgeCard(badge: badge)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Recent activity
                    if !currentProfile.activities.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activity")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .padding(.horizontal, 24)
                            
                            ForEach(currentProfile.activities.sorted(by: { $0.timestamp > $1.timestamp }).prefix(5), id: \.id) { activity in
                                ActivityRow(activity: activity)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                }
            }
        }
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: UserActivity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: activityIcon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(activityColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.type.rawValue)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                if let caseName = activity.caseName {
                    Text(caseName)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(timeAgo(from: activity.timestamp))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
        }
    }
    
    private var activityIcon: String {
        switch activity.type {
        case .reported: return "plus.circle.fill"
        case .offered: return "hand.raised.fill"
        case .completed: return "checkmark.circle.fill"
        case .verified: return "checkmark.seal.fill"
        }
    }
    
    private var activityColor: Color {
        switch activity.type {
        case .reported: return .blue
        case .offered: return .orange
        case .completed: return .green
        case .verified: return .purple
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        let days = Int(seconds / 86400)
        if days > 0 { return "\(days)d ago" }
        if hours > 0 { return "\(hours)h ago" }
        if minutes > 0 { return "\(minutes)m ago" }
        return "Just now"
    }
}

struct ProfileStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Badge Card
struct BadgeCard: View {
    let badge: Badge
    
    private var badgeColor: Color {
        switch badge.color {
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "mint": return .mint
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(badgeColor)
            }
            
            VStack(spacing: 2) {
                Text(badge.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(badge.description)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(width: 110)
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Status Update Sheet
struct StatusUpdateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var currentStatus: CaseStatus
    @State private var selectedStatus: CaseStatus
    
    init(currentStatus: Binding<CaseStatus>) {
        _currentStatus = currentStatus
        _selectedStatus = State(initialValue: currentStatus.wrappedValue)
    }
    
    private let statusOptions: [(status: CaseStatus, icon: String, description: String)] = [
        (.open, "clock", "Case is open and awaiting help"),
        (.inProgress, "figure.walk", "You're on the way or currently helping"),
        (.resolved, "checkmark.circle", "Help has been provided successfully"),
        (.verified, "checkmark.seal", "Reporter has verified the resolution")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(statusOptions, id: \.status) { option in
                    StatusOptionRow(
                        option: option,
                        isSelected: selectedStatus == option.status,
                        onTap: { selectedStatus = option.status }
                    )
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Update Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .buttonStyle(.glass)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        currentStatus = selectedStatus
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(selectedStatus == currentStatus)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Status Option Row
struct StatusOptionRow: View {
    let option: (status: CaseStatus, icon: String, description: String)
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    let bgColor: Color = isSelected ? .blue.opacity(0.1) : Color(white: 0.9)
                    Circle()
                        .fill(bgColor)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: option.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(option.status.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text(option.description)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Report Case Sheet
struct ReportCaseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason = .spam
    @State private var additionalInfo = ""
    @State private var showConfirmation = false
    
    enum ReportReason: String, CaseIterable {
        case spam = "Spam or Scam"
        case fake = "Fake or Misleading"
        case inappropriate = "Inappropriate Content"
        case duplicate = "Duplicate Case"
        case resolved = "Already Resolved"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .spam: return "exclamationmark.triangle.fill"
            case .fake: return "xmark.circle.fill"
            case .inappropriate: return "hand.raised.fill"
            case .duplicate: return "doc.on.doc.fill"
            case .resolved: return "checkmark.circle.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Why are you reporting this case?") {
                    ForEach(ReportReason.allCases, id: \.self) { reason in
                        Button {
                            selectedReason = reason
                        } label: {
                            HStack {
                                Image(systemName: reason.icon)
                                    .foregroundStyle(selectedReason == reason ? .red : .secondary)
                                Text(reason.rawValue)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
                
                Section("Additional Information (Optional)") {
                    TextEditor(text: $additionalInfo)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Report Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        showConfirmation = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .alert("Report Submitted", isPresented: $showConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("Thank you for reporting. Our team will review this case shortly.")
            }
        }
    }
}

#Preview {
    MainTabView()
}
