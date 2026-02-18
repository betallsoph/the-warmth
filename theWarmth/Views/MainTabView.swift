//
//  MainTabView.swift
//  TheWarmth
//
//  Main tab view with Liquid Glass design
//

import SwiftUI
import MapKit

// MARK: - Urgency Color Helper
extension AlertCase.Urgency {
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
    case profile
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

            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfileView()
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
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var selectedCase: AlertCase?
    @State private var showLocationDenied = false
    @State private var selectedCaseForDetail: AlertCase?

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(AlertCase.mockCases) { alertCase in
                    Annotation(
                        alertCase.personName ?? "Unknown",
                        coordinate: alertCase.location.coordinate
                    ) {
                        Button {
                            withAnimation(.spring(duration: 0.3)) {
                                selectedCase = selectedCase?.id == alertCase.id ? nil : alertCase
                            }
                        } label: {
                            CaseMarkerView(
                                alertCase: alertCase,
                                isSelected: selectedCase?.id == alertCase.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .annotationTitles(.hidden)
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
                            self.selectedCase = nil
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
                    .fill(alertCase.urgency.accentColor)
                    .frame(width: size, height: size)
                    .shadow(
                        color: alertCase.urgency.accentColor.opacity(0.35),
                        radius: isSelected ? 10 : 4,
                        x: 0, y: 3
                    )

                Image(systemName: alertCase.needs.first?.icon ?? "person.fill")
                    .font(.system(size: isSelected ? 20 : 15, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Triangle()
                .fill(alertCase.urgency.accentColor)
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

// MARK: - Selected Case Card (map pop-up)
struct SelectedCaseCard: View {
    let alertCase: AlertCase
    let onDismiss: () -> Void
    let onOfferHelp: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(alertCase.personName ?? "Anonymous")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Label(alertCase.location.address, systemImage: "mappin")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(alertCase.urgency.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(alertCase.urgency.accentColor))

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)
                }
            }

            Text(alertCase.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(alertCase.needs, id: \.self) { need in
                        HStack(spacing: 5) {
                            Image(systemName: need.icon).font(.system(size: 11))
                            Text(need.rawValue).font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .glassEffect(in: .capsule)
                    }
                }
            }

            Button(action: onOfferHelp) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                    Text("Offer Help")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.glassProminent)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Case Detail View
struct CaseDetailView: View {
    let alertCase: AlertCase
    @Environment(\.dismiss) private var dismiss
    @State private var showOfferConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Urgency banner
                    HStack(spacing: 12) {
                        Image(systemName: urgencyIcon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(alertCase.urgency.accentColor)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(alertCase.urgency.rawValue + " Priority")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(alertCase.urgency.accentColor)
                            Text(statusLabel)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if alertCase.helpersAssigned > 0 {
                            Label("\(alertCase.helpersAssigned) helping", systemImage: "person.2.fill")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(alertCase.urgency.accentColor.opacity(0.08))
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About this case")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        Text(alertCase.description)
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
                            ForEach(alertCase.needs, id: \.self) { need in
                                HStack(spacing: 8) {
                                    Image(systemName: need.icon)
                                        .font(.system(size: 14))
                                        .foregroundStyle(alertCase.urgency.accentColor)
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
                                    .fill(alertCase.urgency.accentColor)
                                    .frame(width: 16, height: 16)
                                    .shadow(color: alertCase.urgency.accentColor.opacity(0.4), radius: 6)
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle(alertCase.personName ?? "Anonymous")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: { showOfferConfirmation = true }) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                        Text("Offer Help")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.glassProminent)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .padding(.top, 8)
            }
            .alert("Thank you!", isPresented: $showOfferConfirmation) {
                Button("OK") { dismiss() }
            } message: {
                Text("You've been added as a helper for this case. The reporter will be notified.")
            }
        }
    }

    private var urgencyIcon: String {
        switch alertCase.urgency {
        case .critical: return "exclamationmark.3"
        case .high:     return "exclamationmark.2"
        case .moderate: return "exclamationmark"
        case .low:      return "info.circle"
        }
    }

    private var statusLabel: String {
        switch alertCase.status {
        case .open:       return "Awaiting help"
        case .inProgress: return "Help on the way"
        case .resolved:   return "Resolved"
        case .verified:   return "Verified & resolved"
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
    @State private var selectedCase: AlertCase?
    @State private var searchText = ""

    private var filtered: [AlertCase] {
        if searchText.isEmpty { return AlertCase.mockCases }
        return AlertCase.mockCases.filter {
            ($0.personName ?? "").localizedCaseInsensitiveContains(searchText) ||
            $0.location.address.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filtered) { alertCase in
                        Button {
                            selectedCase = alertCase
                        } label: {
                            AlertCaseCard(alertCase: alertCase)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Active Cases")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search cases")
            .sheet(item: $selectedCase) { alertCase in
                CaseDetailView(alertCase: alertCase)
            }
        }
    }
}

struct AlertCaseCard: View {
    let alertCase: AlertCase

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(alertCase.personName ?? "Anonymous")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)

                    Label(alertCase.location.address, systemImage: "mappin")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(alertCase.urgency.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(alertCase.urgency.accentColor))
            }

            Text(alertCase.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(alertCase.needs, id: \.self) { need in
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

    @State private var personName = ""
    @State private var description = ""
    @State private var selectedNeeds: Set<Need> = []
    @State private var selectedUrgency: AlertCase.Urgency = .moderate
    @State private var address = ""
    @State private var showSubmitConfirmation = false

    private var isValid: Bool {
        !description.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedNeeds.isEmpty &&
        !address.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Person name (optional)
                    FormSection(title: "Who needs help?") {
                        TextField("Name or description (optional)", text: $personName)
                            .font(.system(size: 15, design: .rounded))
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Description (required)
                    FormSection(title: "Describe the situation *") {
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("What did you observe? The more detail, the better.")
                                    .font(.system(size: 15, design: .rounded))
                                    .foregroundStyle(.tertiary)
                                    .padding(12)
                            }
                            TextEditor(text: $description)
                                .font(.system(size: 15, design: .rounded))
                                .frame(minHeight: 90)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Location (required)
                    FormSection(title: "Location *") {
                        TextField("Street address or landmark", text: $address)
                            .font(.system(size: 15, design: .rounded))
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Urgency
                    FormSection(title: "Urgency level") {
                        HStack(spacing: 8) {
                            ForEach(AlertCase.Urgency.allCases, id: \.self) { urgency in
                                Button {
                                    selectedUrgency = urgency
                                } label: {
                                    Text(urgency.rawValue)
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundStyle(selectedUrgency == urgency ? .white : .primary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
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
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Report a Case")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: { showSubmitConfirmation = true }) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Report")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.glassProminent)
                .disabled(!isValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .padding(.top, 8)
            }
            .alert("Report Submitted", isPresented: $showSubmitConfirmation) {
                Button("Done") { dismiss() }
            } message: {
                Text("Thank you for reporting. Nearby volunteers will be notified.")
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

// MARK: - Profile View
struct ProfileView: View {
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

                    // Stats
                    GlassEffectContainer(spacing: 20) {
                        HStack(spacing: 1) {
                            ProfileStat(value: "12", label: "Helped")
                            Divider().frame(height: 32).opacity(0.3)
                            ProfileStat(value: "5", label: "Ongoing")
                            Divider().frame(height: 32).opacity(0.3)
                            ProfileStat(value: "3", label: "Reported")
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 8)
                        .glassEffect(in: .rect(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
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

#Preview {
    MainTabView()
}
