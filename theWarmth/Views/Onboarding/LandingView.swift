//
//  LandingView.swift
//  Our Warmth
//
//  Landing page with Apple Glass style
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
                // Fresh light pink gradient background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.99),   // Ultra light pink
                        Color(red: 0.995, green: 0.96, blue: 0.98), // Very very light pink
                        Color(red: 0.99, green: 0.94, blue: 0.96)   // Very light pink
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Hero Section
                    VStack(spacing: 40) {
                        // App Icon
                        ZStack {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.90, blue: 0.94),   // Light pink
                                            Color(red: 0.98, green: 0.87, blue: 0.92)   // Soft pink
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .shadow(color: .black.opacity(0.15), radius: 28, x: 0, y: 14)

                            Image(systemName: "heart.fill")
                                .font(.system(size: 52, weight: .medium))
                                .foregroundStyle(
                                    Color(red: 0.95, green: 0.30, blue: 0.50)  // Deep pink/rose
                                )
                        }
                        .scaleEffect(isAnimating ? 1 : 0.8)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: isAnimating)

                        // Title & Description
                        VStack(spacing: 20) {
                            Text("Our Warmth")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(red: 0.90, green: 0.25, blue: 0.45))  // Deep pink for title
                                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                                .accessibilityAddTraits(.isHeader)

                            Text("Sometimes a small gesture can change someone's day. Share our warmth with those in urgent need through direct, dignified support!")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(Color(red: 0.85, green: 0.30, blue: 0.50))  // Deep pink for description
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                        }
                        .padding(.horizontal, 32)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                    }

                    Spacer()

                    // CTA Button
                    Button {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showMainApp = true
                        }
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.glassProminent)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                    .accessibilityLabel("Get Started")
                    .accessibilityHint("Begin using Our Warmth to help people in need")

                    Spacer()
                        .frame(height: 60)
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

#Preview {
    LandingView()
}
