//
//  MainTabView.swift
//  TheWarmth
//
//  Main tab view with Liquid Glass design
//

import SwiftUI
import MapKit

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
            // Các tab chính - group bên trái
            Tab("Map", systemImage: "map.fill", value: .map) {
                MapViewPlaceholder()
            }

            Tab("Cases", systemImage: "list.bullet.rectangle.fill", value: .cases) {
                AlertsListPlaceholder()
            }

            Tab("Profile", systemImage: "person.fill", value: .profile) {
                ProfilePlaceholder()
            }

            // Nút + tách riêng bên phải (dùng role: .search để tách ra)
            Tab("Add", systemImage: "plus", value: .add, role: .search) {
                // Empty view - sẽ không bao giờ hiển thị vì ta intercept
                Color.clear
            }
        }
        .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
        .tabBarMinimizeBehavior(.onScrollDown)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .add {
                // Khi tap vào nút +, mở sheet thay vì navigate
                showCreateAlert = true
                // Quay về tab trước đó
                selectedTab = oldValue
            }
            previousTab = oldValue
        }
        .sheet(isPresented: $showCreateAlert) {
            CreateAlertPlaceholder()
        }
    }
}

// MARK: - Placeholder Views
struct MapViewPlaceholder: View {
    // Camera position centered on Ho Chi Minh City
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.7769, longitude: 106.7009),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    @State private var selectedCase: AlertCase?

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
                                if selectedCase?.id == alertCase.id {
                                    selectedCase = nil
                                } else {
                                    selectedCase = alertCase
                                }
                            }
                        } label: {
                            CaseMarkerView(alertCase: alertCase, isSelected: selectedCase?.id == alertCase.id)
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

            // Selected case card
            if let selectedCase {
                SelectedCaseCard(alertCase: selectedCase) {
                    withAnimation(.spring(duration: 0.3)) {
                        self.selectedCase = nil
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }
}

// MARK: - Case Marker View
struct CaseMarkerView: View {
    let alertCase: AlertCase
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(urgencyColor.gradient)
                    .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                    .shadow(color: urgencyColor.opacity(0.4), radius: isSelected ? 8 : 4, x: 0, y: 2)

                Image(systemName: alertCase.needs.first?.icon ?? "person.fill")
                    .font(.system(size: isSelected ? 20 : 16, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Triangle pointer
            Triangle()
                .fill(urgencyColor.gradient)
                .frame(width: 12, height: 8)
                .offset(y: -1)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(duration: 0.2), value: isSelected)
    }

    private var urgencyColor: Color {
        switch alertCase.urgency {
        case .critical: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .high: return Color(red: 1.0, green: 0.5, blue: 0.2)
        case .moderate: return Color(red: 1.0, green: 0.7, blue: 0.2)
        case .low: return Color(red: 0.3, green: 0.6, blue: 1.0)
        }
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

// MARK: - Selected Case Card
struct SelectedCaseCard: View {
    let alertCase: AlertCase
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(alertCase.personName ?? "Anonymous")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.2, green: 0.15, blue: 0.15))

                    Text(alertCase.location.address)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Urgency badge
                Text(alertCase.urgency.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .fill(urgencyColor)
                    }

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)
                }
            }

            // Description
            Text(alertCase.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color(red: 0.4, green: 0.35, blue: 0.35))
                .lineLimit(2)

            // Needs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(alertCase.needs, id: \.self) { need in
                        HStack(spacing: 5) {
                            Image(systemName: need.icon)
                                .font(.system(size: 11))
                            Text(need.rawValue)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.45))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(Color(red: 0.96, green: 0.95, blue: 0.94))
                        }
                    }
                }
            }

            // Action button
            Button(action: {}) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                    Text("Offer Help")
                }
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(red: 1.0, green: 0.5, blue: 0.35))
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }

    private var urgencyColor: Color {
        switch alertCase.urgency {
        case .critical: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .high: return Color(red: 1.0, green: 0.5, blue: 0.2)
        case .moderate: return Color(red: 1.0, green: 0.7, blue: 0.2)
        case .low: return Color(red: 0.3, green: 0.6, blue: 1.0)
        }
    }
}

struct AlertsListPlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(AlertCase.mockCases) { alertCase in
                            AlertCasePreviewCard(alertCase: alertCase)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Active Cases")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AlertCasePreviewCard: View {
    let alertCase: AlertCase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(alertCase.personName ?? "Anonymous")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                    
                    Text(alertCase.location.address)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                }
                
                Spacer()
                
                // Urgency badge
                Text(alertCase.urgency.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        Capsule()
                            .fill(urgencyColor(alertCase.urgency))
                    }
            }
            
            // Description
            Text(alertCase.description)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color(red: 0.45, green: 0.4, blue: 0.4))
                .lineLimit(2)
            
            // Needs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(alertCase.needs, id: \.self) { need in
                        HStack(spacing: 5) {
                            Image(systemName: need.icon)
                                .font(.system(size: 11))
                            Text(need.rawValue)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.45))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(Color(red: 0.96, green: 0.95, blue: 0.94))
                        }
                    }
                }
            }
            
            // Footer
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                    Text(timeAgo(from: alertCase.reportedAt))
                        .font(.system(size: 12, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.6, green: 0.55, blue: 0.55))
                
                Spacer()
                
                if alertCase.helpersAssigned > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 11))
                        Text("\(alertCase.helpersAssigned) helping")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Color(red: 0.2, green: 0.7, blue: 0.4))
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
    
    private func urgencyColor(_ urgency: AlertCase.Urgency) -> Color {
        switch urgency {
        case .critical: return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .high: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .moderate: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .low: return Color(red: 0.3, green: 0.6, blue: 1.0)
        }
    }
    
    private func timeAgo(from date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = Int(seconds / 60)
        let hours = Int(seconds / 3600)
        
        if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "Just now"
        }
    }
}

struct CreateAlertPlaceholder: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.45, blue: 0.3),
                                Color(red: 1.0, green: 0.55, blue: 0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: 10) {
                    Text("Report a Case")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                    
                    Text("Help someone in need by creating an alert")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.35))
                        Text("Coming Soon")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                    }
                    
                    Text("Form to report new cases with location, photos, and needs")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

struct ProfilePlaceholder: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.96)
                    .ignoresSafeArea()
                
                VStack(spacing: 28) {
                    // Profile avatar
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.orange.opacity(0.2),
                                        Color.orange.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 90))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.45, blue: 0.3),
                                        Color(red: 1.0, green: 0.55, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 110, height: 110)
                                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                            }
                    }
                    
                    VStack(spacing: 8) {
                        Text("Your Profile")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                        
                        Text("Track your impact and manage settings")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                    }
                    
                    // Stats
                    HStack(spacing: 14) {
                        VStack(spacing: 6) {
                            Text("12")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                            Text("Helped")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                        }
                        
                        VStack(spacing: 6) {
                            Text("5")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                            Text("Ongoing")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                        }
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    MainTabView()
}
