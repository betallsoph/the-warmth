//
//  GlassButton.swift
//  TheWarmth
//
//  Reusable Liquid Glass button component
//

import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case destructive
        
        var tint: Color {
            switch self {
            case .primary: return .orange
            case .secondary: return .blue
            case .destructive: return .red
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .tint(style.tint)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            GlassButton("Get Started", icon: "hand.raised.fill", style: .primary) {
                print("Tapped primary")
            }
            
            GlassButton("Learn More", icon: "info.circle.fill", style: .secondary) {
                print("Tapped secondary")
            }
            
            GlassButton("Report", icon: "exclamationmark.triangle.fill", style: .destructive) {
                print("Tapped destructive")
            }
        }
        .padding()
    }
}
