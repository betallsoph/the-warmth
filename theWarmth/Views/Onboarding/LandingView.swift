//
//  LandingView.swift
//  TheWarmth
//
//  Main landing page with Liquid Glass design
//

import SwiftUI

struct LandingView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false

    var body: some View {
        if showMainApp {
            MainTabView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        } else {
            ZStack {
                // Clean neutral background
                Color(white: 0.97)
                    .ignoresSafeArea()

                // Subtle depth blobs
                GeometryReader { geo in
                    Circle()
                        .fill(Color(white: 0.88).opacity(0.6))
                        .frame(width: 320, height: 320)
                        .blur(radius: 80)
                        .offset(x: geo.size.width * 0.5, y: -60)

                    Circle()
                        .fill(Color(white: 0.82).opacity(0.4))
                        .frame(width: 260, height: 260)
                        .blur(radius: 60)
                        .offset(x: -60, y: geo.size.height * 0.6)
                }
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Hero
                    HeroSection(isAnimating: $isAnimating)
                        .padding(.horizontal, 24)

                    Spacer()

                    // Stats
                    StatsSection()
                        .padding(.horizontal, 24)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)

                    Spacer()

                    // CTA
                    CTASection(showMainApp: $showMainApp)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 52)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: isAnimating)
                }
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    isAnimating = true
                }
            }
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    @Binding var isAnimating: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(white: 0.92))
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 8)

                Image(systemName: "heart.fill")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(.primary.opacity(0.75))
            }
            .scaleEffect(isAnimating ? 1 : 0.5)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: isAnimating)

            // Title
            VStack(spacing: 8) {
                Text("The Warmth")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Bringing warmth to the streets")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)

            // Description
            Text("A community alert app for helping vulnerable neighbors. Spot and map those in need, turning compassion into immediate, dignified action.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 12)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
        }
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    var body: some View {
        GlassEffectContainer(spacing: 16) {
            HStack(spacing: 1) {
                StatItem(number: "247", label: "Helped", icon: "person.2.fill")
                Divider()
                    .frame(height: 36)
                    .opacity(0.3)
                StatItem(number: "89", label: "Cases", icon: "map.fill")
                Divider()
                    .frame(height: 36)
                    .opacity(0.3)
                StatItem(number: "156", label: "Volunteers", icon: "hand.raised.fill")
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .glassEffect(in: .rect(cornerRadius: 20))
        }
    }
}

struct StatItem: View {
    let number: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.primary.opacity(0.6))

            Text(number)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - CTA Section
struct CTASection: View {
    @Binding var showMainApp: Bool
    @State private var showHowItWorks = false

    var body: some View {
        VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showMainApp = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Start Helping Now")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.glassProminent)

            Button {
                showHowItWorks = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14, weight: .medium))
                    Text("Learn How It Works")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .sheet(isPresented: $showHowItWorks) {
                HowItWorksView()
            }
        }
    }
}

// MARK: - How It Works View
struct HowItWorksView: View {
    @Environment(\.dismiss) private var dismiss

    private let steps: [(icon: String, title: String, description: String)] = [
        ("eyes",           "Spot someone in need",   "See a homeless person, an elderly individual, or anyone who needs help on the street."),
        ("mappin.and.ellipse", "Open the app",       "Tap the + button to start a new report. Your location is automatically detected."),
        ("list.bullet.clipboard", "Describe the situation", "Add a brief description, select what they need — food, water, medical help — and set the urgency level."),
        ("paperplane.fill", "Submit the alert",      "Your report is shared with nearby volunteers and organisations who can respond quickly."),
        ("hand.raised.fill", "Help arrives",         "Volunteers see the case on the map and can offer help directly. You can track the status in real time.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 16) {
                            // Step indicator
                            VStack(spacing: 0) {
                                ZStack {
                                    Circle()
                                        .fill(.quaternary)
                                        .frame(width: 44, height: 44)
                                    Image(systemName: step.icon)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(.primary.opacity(0.7))
                                }

                                if index < steps.count - 1 {
                                    Rectangle()
                                        .fill(.quaternary)
                                        .frame(width: 2, height: 32)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(step.title)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)
                                Text(step.description)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, index < steps.count - 1 ? 0 : 0)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, index < steps.count - 1 ? 4 : 0)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LandingView()
}
