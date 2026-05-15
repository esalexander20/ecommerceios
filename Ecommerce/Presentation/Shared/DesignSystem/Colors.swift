//
//  Colors.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

/// Semantic color system for the e-commerce app
/// All colors are defined in Assets.xcassets and referenced here for type safety
public enum AppColor {
    // Primary palette
    public static let primary = Color("PrimaryColor")
    public static let primaryLight = Color("PrimaryLightColor")
    public static let primaryDark = Color("PrimaryDarkColor")
    
    // Secondary palette
    public static let secondary = Color("SecondaryColor")
    public static let secondaryLight = Color("SecondaryLightColor")
    
    // Background colors
    public static let background = Color("BackgroundColor")
    public static let surface = Color("SurfaceColor")
    public static let surfaceVariant = Color("SurfaceVariantColor")
    
    // Text colors
    public static let textPrimary = Color("TextPrimary")
    public static let textSecondary = Color("TextSecondary")
    public static let textTertiary = Color("TextTertiary")
    public static let textInverse = Color("TextInverse")
    
    // Status colors
    public static let error = Color("ErrorColor")
    public static let errorLight = Color("ErrorLightColor")
    public static let success = Color("SuccessColor")
    public static let successLight = Color("SuccessLightColor")
    public static let warning = Color("WarningColor")
    public static let info = Color("InfoColor")
    
    // Border colors
    public static let border = Color("BorderColor")
    public static let borderLight = Color("BorderLightColor")
    
    // Overlay colors
    public static let overlay = Color("OverlayColor")
    public static let scrim = Color("ScrimColor")
    
    // Gradient colors
    public static let gradientPrimary = LinearGradient(
        gradient: Gradient(colors: [AppColor.primary, AppColor.primaryDark]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    public static let gradientSecondary = LinearGradient(
        gradient: Gradient(colors: [AppColor.secondary, AppColor.secondaryLight]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extensions for Common Use Cases

public extension Color {
    /// Convenience initializer with hex string
    /// - Parameter hex: Hex string (with or without # prefix)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    /// Default colors for preview purposes (used when Asset catalog colors are not available)
    static var defaultPrimary: Color { Color(hex: "#6200EE") }
    static var defaultSecondary: Color { Color(hex: "#03DAC6") }
    static var defaultBackground: Color { Color(hex: "#FFFFFF") }
    static var defaultSurface: Color { Color(hex: "#FFFFFF") }
    static var defaultTextPrimary: Color { Color(hex: "#1A1A1A") }
    static var defaultTextSecondary: Color { Color(hex: "#666666") }
    static var defaultError: Color { Color(hex: "#FF3B30") }
    static var defaultSuccess: Color { Color(hex: "#4CAF50") }
}

// MARK: - Preview Provider

#Preview {
    VStack(spacing: 16) {
        Text("Primary Colors")
            .font(.headline)
        
        Rectangle()
            .fill(AppColor.primary)
            .frame(height: 40)
        
        Rectangle()
            .fill(AppColor.primaryLight)
            .frame(height: 40)
            
        Rectangle()
            .fill(AppColor.primaryDark)
            .frame(height: 40)
        
        Text("Secondary Colors")
            .font(.headline)
        
        Rectangle()
            .fill(AppColor.secondary)
            .frame(height: 40)
            
        Rectangle()
            .fill(AppColor.secondaryLight)
            .frame(height: 40)
        
        Text("Status Colors")
            .font(.headline)
        
        HStack(spacing: 16) {
            Rectangle()
                .fill(AppColor.error)
                .frame(width: 40, height: 40)
            
            Rectangle()
                .fill(AppColor.success)
                .frame(width: 40, height: 40)
                
            Rectangle()
                .fill(AppColor.warning)
                .frame(width: 40, height: 40)
                
            Rectangle()
                .fill(AppColor.info)
                .frame(width: 40, height: 40)
        }
    }
    .padding()
}
