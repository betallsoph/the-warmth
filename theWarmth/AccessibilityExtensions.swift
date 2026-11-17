//
//  AccessibilityExtensions.swift
//  Our Warmth
//
//  Accessibility helpers for VoiceOver and Dynamic Type
//

import SwiftUI

extension View {
    /// Add standard accessibility properties for buttons
    func accessibilityButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(hint ?? "")
    }
    
    /// Make text scale with Dynamic Type
    func dynamicTypeSize(min: DynamicTypeSize = .xSmall, max: DynamicTypeSize = .xxxLarge) -> some View {
        self.dynamicTypeSize(min...max)
    }
}
