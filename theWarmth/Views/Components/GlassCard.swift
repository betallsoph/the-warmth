//
//  GlassCard.swift
//  TheWarmth
//
//  Reusable Liquid Glass card component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var style: GlassStyle = .regular
    var interactive: Bool = false
    
    enum GlassStyle {
        case regular
        case prominent
        case subtle
    }
    
    init(
        style: GlassStyle = .regular,
        interactive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.interactive = interactive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
            }
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 20) {
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Regular Glass")
                        .font(.headline)
                    Text("This is a regular glass card")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GlassCard(interactive: true) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                    Text("Interactive Glass")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
    }
}
