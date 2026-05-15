//
//  Spacing.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

/// Spacing system based on 8px grid
/// All spacing values are multiples of 8 for consistency
public enum AppSpacing {
    // Base spacing unit = 8px
    private static let base: CGFloat = 8
    
    // MARK: - Spacing Values (Multiples of 8)
    
    /// 0px - No spacing
    public static let none: CGFloat = 0
    
    /// 2px - Micro spacing (for hairline borders)
    public static let micro: CGFloat = 2
    
    /// 4px - Extra small spacing
    public static let xs: CGFloat = 4
    
    /// 8px - Small spacing (1x base)
    public static let small: CGFloat = base
    
    /// 12px - Small+ spacing
    public static let smallPlus: CGFloat = base + 4
    
    /// 16px - Medium spacing (2x base)
    public static let medium: CGFloat = base * 2
    
    /// 24px - Medium+ spacing (3x base)
    public static let mediumPlus: CGFloat = base * 3
    
    /// 32px - Large spacing (4x base)
    public static let large: CGFloat = base * 4
    
    /// 40px - Large+ spacing
    public static let largePlus: CGFloat = base * 5
    
    /// 48px - Extra large spacing (6x base)
    public static let xLarge: CGFloat = base * 6
    
    /// 56px - Extra large+ spacing
    public static let xLargePlus: CGFloat = base * 7
    
    /// 64px - XXL spacing (8x base)
    public static let xxLarge: CGFloat = base * 8
    
    /// 80px - XXL+ spacing
    public static let xxLargePlus: CGFloat = base * 10
    
    // MARK: - Padding Presets
    
    /// Standard padding for cards and containers
    public static let cardPadding: EdgeInsets = EdgeInsets(
        top: medium,
        leading: medium,
        bottom: medium,
        trailing: medium
    )
    
    /// Small padding for compact elements
    public static let smallPadding: EdgeInsets = EdgeInsets(
        top: small,
        leading: small,
        bottom: small,
        trailing: small
    )
    
    /// Large padding for spacious layouts
    public static let largePadding: EdgeInsets = EdgeInsets(
        top: large,
        leading: large,
        bottom: large,
        trailing: large
    )
    
    /// Horizontal padding only
    public static let horizontalPadding: EdgeInsets = EdgeInsets(
        top: 0,
        leading: medium,
        bottom: 0,
        trailing: medium
    )
    
    /// Vertical padding only
    public static let verticalPadding: EdgeInsets = EdgeInsets(
        top: medium,
        leading: 0,
        bottom: medium,
        trailing: 0
    )
    
    // MARK: - Corner Radius
    
    public enum CornerRadius {
        /// 0 - No rounding
        public static let none: CGFloat = 0
        
        /// 4px - Small rounding
        public static let small: CGFloat = 4
        
        /// 8px - Medium rounding
        public static let medium: CGFloat = 8
        
        /// 12px - Large rounding
        public static let large: CGFloat = 12
        
        /// 16px - Extra large rounding
        public static let xLarge: CGFloat = 16
        
        /// 24px - Pill shape
        public static let pill: CGFloat = 24
        
        /// Full circle (for circular elements)
        public static let full: CGFloat = .infinity
    }
    
    // MARK: - Shadow Presets
    
    public enum Shadow {
        /// Small shadow for elevated elements
        public static let small = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )
        
        /// Medium shadow for cards
        public static let medium = ShadowStyle(
            color: Color.black.opacity(0.1),
            radius: 4,
            x: 0,
            y: 2
        )
        
        /// Large shadow for modals and dialogs
        public static let large = ShadowStyle(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        /// Extra large shadow for floating elements
        public static let xLarge = ShadowStyle(
            color: Color.black.opacity(0.2),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    public struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        
        func apply(to view: some View) -> some View {
            view.shadow(color: color, radius: radius, x: x, y: y)
        }
    }
}

// MARK: - View Extensions for Spacing

public extension View {
    /// Applies standard card styling with background, corner radius, and shadow
    func cardStyle() -> some View {
        self
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .applyShadow(AppSpacing.Shadow.medium)
    }
    
    /// Applies pill styling (fully rounded)
    func pillStyle() -> some View {
        self
            .background(AppColor.surface)
            .clipShape(Capsule())
            .applyShadow(AppSpacing.Shadow.small)
    }
    
    /// Applies standard button styling
    func buttonStyle() -> some View {
        self
            .padding(EdgeInsets(top: AppSpacing.small, leading: AppSpacing.medium, bottom: AppSpacing.small, trailing: AppSpacing.medium))
            .background(AppColor.primary)
            .foregroundColor(AppColor.textInverse)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            .applyShadow(AppSpacing.Shadow.small)
    }
    
    /// Applies the given shadow style
    func applyShadow(_ style: AppSpacing.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.large) {
        // Spacing examples
        VStack(spacing: AppSpacing.small) {
            ForEach([AppSpacing.xs, AppSpacing.small, AppSpacing.medium, AppSpacing.large, AppSpacing.xLarge], id: \.self) { spacing in
                Rectangle()
                    .fill(Color.blue)
                    .frame(height: 2)
                    .padding(.vertical, spacing)
            }
        }
        
        Divider()
        
        // Corner radius examples
        VStack(spacing: AppSpacing.medium) {
            Text("Corner Radius Examples")
                .font(AppFont.titleMedium())
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.none))
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.small))
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.medium))
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large))
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: 60)
                .clipShape(Capsule())
        }
        
        Divider()
        
        // Shadow examples
        VStack(spacing: AppSpacing.medium) {
            Text("Shadow Examples")
                .font(AppFont.titleMedium())
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 60)
                .applyShadow(AppSpacing.Shadow.small)
                .border(Color.gray)
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 60)
                .applyShadow(AppSpacing.Shadow.medium)
                .border(Color.gray)
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 60)
                .applyShadow(AppSpacing.Shadow.large)
                .border(Color.gray)
        }
    }
    .padding()
}
