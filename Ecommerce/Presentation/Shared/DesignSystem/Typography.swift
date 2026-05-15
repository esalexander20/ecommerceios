//
//  Typography.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

/// Typography system following 8px grid for consistent spacing
/// Font sizes are based on Material Design typography scale
public enum AppFont {
    // MARK: - Font Families
    
    public static let familyPrimary = "Inter"
    public static let familySecondary = "SF Pro"
    
    // MARK: - Font Weights
    
    public enum Weight {
        case light
        case regular
        case medium
        case semiBold
        case bold
        case black
        
        var value: Font.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semiBold: return .semibold
            case .bold: return .bold
            case .black: return .black
            }
        }
    }
    
    // MARK: - Display Styles
    
    public static func displayLarge(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 57).weight(weight.value)
    }
    
    public static func displayMedium(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 45).weight(weight.value)
    }
    
    public static func displaySmall(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 36).weight(weight.value)
    }
    
    // MARK: - Headline Styles
    
    public static func headlineLarge(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 32).weight(weight.value)
    }
    
    public static func headlineMedium(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 28).weight(weight.value)
    }
    
    public static func headlineSmall(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 24).weight(weight.value)
    }
    
    // MARK: - Title Styles
    
    public static func titleLarge(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 22).weight(weight.value)
    }
    
    public static func titleMedium(weight: Weight = .medium) -> Font {
        Font.custom(familyPrimary, size: 18).weight(weight.value)
    }
    
    public static func titleSmall(weight: Weight = .medium) -> Font {
        Font.custom(familyPrimary, size: 16).weight(weight.value)
    }
    
    // MARK: - Label Styles
    
    public static func labelLarge(weight: Weight = .medium) -> Font {
        Font.custom(familyPrimary, size: 16).weight(weight.value)
    }
    
    public static func labelMedium(weight: Weight = .medium) -> Font {
        Font.custom(familyPrimary, size: 14).weight(weight.value)
    }
    
    public static func labelSmall(weight: Weight = .medium) -> Font {
        Font.custom(familyPrimary, size: 12).weight(weight.value)
    }
    
    // MARK: - Body Styles
    
    public static func bodyLarge(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 16).weight(weight.value)
    }
    
    public static func bodyMedium(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 14).weight(weight.value)
    }
    
    public static func bodySmall(weight: Weight = .regular) -> Font {
        Font.custom(familyPrimary, size: 12).weight(weight.value)
    }
}

// MARK: - Text Style Modifiers

public extension Text {
    /// Applies primary text style (bodyMedium with primary color)
    func primaryStyle() -> some View {
        self
            .font(AppFont.bodyMedium())
            .foregroundColor(AppColor.textPrimary)
    }
    
    /// Applies secondary text style (bodyMedium with secondary color)
    func secondaryStyle() -> some View {
        self
            .font(AppFont.bodyMedium())
            .foregroundColor(AppColor.textSecondary)
    }
    
    /// Applies tertiary text style (bodySmall with tertiary color)
    func tertiaryStyle() -> some View {
        self
            .font(AppFont.bodySmall())
            .foregroundColor(AppColor.textTertiary)
    }
    
    /// Applies headline style
    func headlineStyle(level: Int = 1) -> some View {
        switch level {
        case 1: return self.font(AppFont.headlineLarge(weight: .bold))
        case 2: return self.font(AppFont.headlineMedium(weight: .bold))
        case 3: return self.font(AppFont.headlineSmall(weight: .bold))
        default: return self.font(AppFont.headlineSmall(weight: .bold))
        }
    }
    
    /// Applies title style
    func titleStyle(level: Int = 1) -> some View {
        switch level {
        case 1: return self.font(AppFont.titleLarge(weight: .medium))
        case 2: return self.font(AppFont.titleMedium(weight: .medium))
        case 3: return self.font(AppFont.titleSmall(weight: .medium))
        default: return self.font(AppFont.titleMedium(weight: .medium))
        }
    }
    
    /// Applies label style
    func labelStyle(size: String = "medium") -> some View {
        switch size {
        case "large": return self.font(AppFont.labelLarge(weight: .medium))
        case "small": return self.font(AppFont.labelSmall(weight: .medium))
        default: return self.font(AppFont.labelMedium(weight: .medium))
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        Text("Display Large")
            .font(AppFont.displayLarge(weight: .bold))
        
        Text("Display Medium")
            .font(AppFont.displayMedium(weight: .bold))
        
        Text("Display Small")
            .font(AppFont.displaySmall(weight: .bold))
        
        Divider()
        
        Text("Headline Large")
            .font(AppFont.headlineLarge(weight: .bold))
        
        Text("Headline Medium")
            .font(AppFont.headlineMedium(weight: .bold))
        
        Text("Headline Small")
            .font(AppFont.headlineSmall(weight: .bold))
        
        Divider()
        
        Text("Title Large")
            .font(AppFont.titleLarge(weight: .medium))
        
        Text("Title Medium")
            .font(AppFont.titleMedium(weight: .medium))
        
        Text("Title Small")
            .font(AppFont.titleSmall(weight: .medium))
        
        Divider()
        
        Text("Body Large")
            .font(AppFont.bodyLarge())
        
        Text("Body Medium")
            .font(AppFont.bodyMedium())
        
        Text("Body Small")
            .font(AppFont.bodySmall())
        
        Divider()
        
        Text("Label Large")
            .font(AppFont.labelLarge(weight: .medium))
        
        Text("Label Medium")
            .font(AppFont.labelMedium(weight: .medium))
        
        Text("Label Small")
            .font(AppFont.labelSmall(weight: .medium))
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
}
