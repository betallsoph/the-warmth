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
    let style: ButtonVariant
    let action: () -> Void

    enum ButtonVariant {
        case primary
        case secondary
        case destructive
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonVariant = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }

    var body: some View {
        if style == .primary {
            Button(action: action) {
                buttonLabel
            }
            .buttonStyle(.glassProminent)
        } else {
            Button(action: action) {
                buttonLabel
            }
            .buttonStyle(.glass)
        }
    }

    private var buttonLabel: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
            }
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}

#Preview {
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            GlassButton("Start Helping", icon: "hand.raised.fill", style: .primary) {}
            GlassButton("Learn More", icon: "info.circle", style: .secondary) {}
        }
        .padding()
    }
}
