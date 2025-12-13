//
//  LandingView.swift
//  TheWarmth
//
//  Main landing page with hero section and Liquid Glass design
//

import SwiftUI

struct LandingView: View {
    @State private var isAnimating = false
    @State private var showMainApp = false
    @Namespace private var namespace
    
    var body: some View {
        if showMainApp {
            MainTabView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
        } else {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero section
                    HeroSection(isAnimating: $isAnimating)
                        .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Stats section
                    StatsSection()
                        .padding(.horizontal, 24)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                    
                    Spacer()
                    
                    // CTA section
                    CTASection(showMainApp: $showMainApp)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 50)
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

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.95, blue: 0.9),   // Soft peach
                Color(red: 1.0, green: 0.92, blue: 0.85),  // Warm cream
                Color(red: 0.98, green: 0.94, blue: 0.92)  // Light blush
            ],
            startPoint: animateGradient ? .topLeading : .top,
            endPoint: animateGradient ? .bottomTrailing : .bottom
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Hero Section
struct HeroSection: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // App Icon with Glass Effect
            ZStack {
                // Soft glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.orange.opacity(0.3),
                                Color.orange.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                
                ZStack {
                    Image(systemName: "heart.circle.fill")
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
                }
                .frame(width: 110, height: 110)
                .background {
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                }
            }
            .scaleEffect(isAnimating ? 1 : 0.5)
            .opacity(isAnimating ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1), value: isAnimating)
            
            // Title
            VStack(spacing: 8) {
                Text("The Warmth")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.25, blue: 0.25),
                                Color(red: 0.4, green: 0.35, blue: 0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Bringing warmth to the streets")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.45))
                    .multilineTextAlignment(.center)
            }
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 20)
            .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
            
            // Description
            Text("A community alert app for helping vulnerable neighbors. Spot and map those in need, turning compassion into immediate, dignified action.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 24)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimating)
        }
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    var body: some View {
        HStack(spacing: 16) {
            StatCard(number: "247", label: "People Helped", icon: "person.2.fill")
            StatCard(number: "89", label: "Active Cases", icon: "map.fill")
            StatCard(number: "156", label: "Volunteers", icon: "hand.raised.fill")
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
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
            
            Text(number)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 0.3, green: 0.25, blue: 0.25))
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color(red: 0.55, green: 0.5, blue: 0.5))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - CTA Section
struct CTASection: View {
    @Binding var showMainApp: Bool
    
    var body: some View {
        VStack(spacing: 14) {
            // Primary CTA
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showMainApp = true
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Helping Now")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.45, blue: 0.3),
                                    Color(red: 1.0, green: 0.55, blue: 0.4)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color(red: 1.0, green: 0.5, blue: 0.35).opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
            
            // Secondary CTA
            Button {
                // Learn more action
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15, weight: .medium))
                    Text("Learn How It Works")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Color(red: 0.5, green: 0.45, blue: 0.45))
                .padding(.vertical, 12)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LandingView()
}
