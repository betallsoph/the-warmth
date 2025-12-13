//
//  MainTabView.swift
//  TheWarmth
//
//  Main tab view with Liquid Glass design
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    init() {
        // Configure tab bar with standard UIKit API
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapViewPlaceholder()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }
                .tag(0)
            
            AlertsListPlaceholder()
                .tabItem {
                    Label("Cases", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(1)
            
            CreateAlertPlaceholder()
                .tabItem {
                    Label("Report", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            ProfilePlaceholder()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 1.0, green: 0.5, blue: 0.35))
    }
}

// MARK: - Placeholder Views
struct MapViewPlaceholder: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.96)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "map.fill")
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
                    Text("Map View")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                    
                    Text("Interactive map showing all active cases")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(Color(red: 1.0, green: 0.5, blue: 0.35))
                        Text("Coming Soon")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
                    }
                    
                    Text("Map integration with real-time case markers and clustering")
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
