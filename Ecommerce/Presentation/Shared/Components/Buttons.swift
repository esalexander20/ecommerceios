//
//  Buttons.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

// MARK: - Button Styles

/// Base button style configuration
public struct ButtonStyleConfig {
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let font: Font
    let padding: EdgeInsets
    let shadow: AppSpacing.ShadowStyle?
    
    public init(
        backgroundColor: Color,
        foregroundColor: Color,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        cornerRadius: CGFloat = AppSpacing.CornerRadius.medium,
        font: Font = AppFont.labelLarge(weight: .medium),
        padding: EdgeInsets = EdgeInsets(top: AppSpacing.small, leading: AppSpacing.medium, bottom: AppSpacing.small, trailing: AppSpacing.medium),
        shadow: AppSpacing.ShadowStyle? = AppSpacing.Shadow.small
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.font = font
        self.padding = padding
        self.shadow = shadow
    }
}

// MARK: - Button Components

/// Primary button - Used for main actions (e.g., "Add to Cart", "Checkout")
public struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let config: ButtonStyleConfig
    
    public init(
        _ title: String,
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        
        self.config = ButtonStyleConfig(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.textInverse,
            cornerRadius: AppSpacing.CornerRadius.medium,
            font: AppFont.labelLarge(weight: .semiBold)
        )
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: config.foregroundColor))
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(config.font)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(config.padding)
            .background(
                isDisabled ? 
                    AppColor.surface.opacity(0.5) : 
                    config.backgroundColor
            )
            .foregroundColor(
                isDisabled ? 
                    AppColor.textSecondary : 
                    config.foregroundColor
            )
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
            .applyShadow(config.shadow ?? AppSpacing.Shadow.small)
            .opacity(isDisabled ? 0.7 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Secondary button - Used for secondary actions (e.g., "Cancel", "Back")
public struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let config: ButtonStyleConfig
    
    public init(
        _ title: String,
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        
        self.config = ButtonStyleConfig(
            backgroundColor: AppColor.surface,
            foregroundColor: AppColor.textPrimary,
            borderColor: AppColor.border,
            borderWidth: 1,
            cornerRadius: AppSpacing.CornerRadius.medium,
            font: AppFont.labelLarge(weight: .semiBold)
        )
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: config.foregroundColor))
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(config.font)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(config.padding)
            .background(config.backgroundColor)
            .foregroundColor(
                isDisabled ? 
                    AppColor.textSecondary : 
                    config.foregroundColor
            )
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.borderColor ?? AppColor.border, lineWidth: config.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
            .opacity(isDisabled ? 0.7 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Outline button - Used for alternative actions with border only
public struct OutlineButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    let config: ButtonStyleConfig
    
    public init(
        _ title: String,
        action: @escaping () -> Void,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.action = action
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        
        self.config = ButtonStyleConfig(
            backgroundColor: .clear,
            foregroundColor: AppColor.primary,
            borderColor: AppColor.primary,
            borderWidth: 1,
            cornerRadius: AppSpacing.CornerRadius.medium,
            font: AppFont.labelLarge(weight: .semiBold),
            padding: EdgeInsets(top: AppSpacing.small, leading: AppSpacing.medium, bottom: AppSpacing.small, trailing: AppSpacing.medium),
            shadow: nil
        )
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: config.foregroundColor))
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(config.font)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(config.padding)
            .foregroundColor(
                isDisabled ? 
                    AppColor.textSecondary : 
                    config.foregroundColor
            )
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.borderColor ?? AppColor.border, lineWidth: config.borderWidth)
            )
            .opacity(isDisabled ? 0.7 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
}

/// Icon button - Used for icon-only actions
public struct IconButton: View {
    let icon: Image
    let action: () -> Void
    let isDisabled: Bool
    let config: ButtonStyleConfig
    
    public init(
        icon: Image,
        action: @escaping () -> Void,
        isDisabled: Bool = false
    ) {
        self.icon = icon
        self.action = action
        self.isDisabled = isDisabled
        
        self.config = ButtonStyleConfig(
            backgroundColor: AppColor.surface,
            foregroundColor: AppColor.textPrimary,
            cornerRadius: AppSpacing.CornerRadius.small,
            font: AppFont.labelLarge(weight: .medium),
            padding: EdgeInsets(top: AppSpacing.xs, leading: AppSpacing.xs, bottom: AppSpacing.xs, trailing: AppSpacing.xs),
            shadow: AppSpacing.Shadow.small
        )
    }
    
    public var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(config.padding)
                .background(config.backgroundColor)
                .foregroundColor(
                    isDisabled ? 
                        AppColor.textSecondary : 
                        config.foregroundColor
                )
                .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                .applyShadow(config.shadow ?? AppSpacing.Shadow.small)
                .opacity(isDisabled ? 0.7 : 1.0)
        }
        .disabled(isDisabled)
    }
}

/// Floating Action Button (FAB) - Used for primary floating actions
public struct FAB: View {
    let icon: Image
    let action: () -> Void
    let config: ButtonStyleConfig
    
    public init(icon: Image, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
        
        self.config = ButtonStyleConfig(
            backgroundColor: AppColor.primary,
            foregroundColor: AppColor.textInverse,
            cornerRadius: AppSpacing.CornerRadius.full,
            font: AppFont.labelMedium(weight: .medium),
            padding: EdgeInsets(top: AppSpacing.medium, leading: AppSpacing.medium, bottom: AppSpacing.medium, trailing: AppSpacing.medium),
            shadow: AppSpacing.Shadow.medium
        )
    }
    
    public var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(config.padding)
                .background(config.backgroundColor)
                .foregroundColor(config.foregroundColor)
                .clipShape(Circle())
                .applyShadow(config.shadow ?? AppSpacing.Shadow.small)
        }
    }
}

/// Social login button - Used for social authentication (Google, Apple, Facebook)
public struct SocialButton: View {
    let icon: Image
    let title: String
    let action: () -> Void
    let config: ButtonStyleConfig
    
    public init(icon: Image, title: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.action = action
        
        self.config = ButtonStyleConfig(
            backgroundColor: AppColor.surface,
            foregroundColor: AppColor.textPrimary,
            borderColor: AppColor.border,
            borderWidth: 1,
            cornerRadius: AppSpacing.CornerRadius.medium,
            font: AppFont.labelMedium(weight: .medium),
            shadow: nil
        )
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(config.font)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(config.padding)
            .background(config.backgroundColor)
            .foregroundColor(config.foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: config.cornerRadius)
                    .stroke(config.borderColor ?? AppColor.border, lineWidth: config.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
        }
    }
}

/// Button group - Used for grouping multiple buttons horizontally or vertically
public struct ButtonGroup: View {
    let buttons: [AnyView]
    let spacing: CGFloat
    let isHorizontal: Bool
    
    public init(@ViewBuilder buttons: () -> some View, spacing: CGFloat = AppSpacing.small, isHorizontal: Bool = false) {
        self.buttons = buttons().anyViews
        self.spacing = spacing
        self.isHorizontal = isHorizontal
    }
    
    public var body: some View {
        if isHorizontal {
            HStack(spacing: spacing) {
                ForEach(0..<buttons.count, id: \.self) { index in
                    buttons[index]
                }
            }
        } else {
            VStack(spacing: spacing) {
                ForEach(0..<buttons.count, id: \.self) { index in
                    buttons[index]
                }
            }
        }
    }
}

// MARK: - ViewBuilder Extensions

extension View {
    var anyView: AnyView {
        AnyView(self)
    }
    
    var anyViews: [AnyView] {
        [anyView]
    }
}

extension ViewBuilder {
    static func buildBlock(_ components: AnyView...) -> some View {
        ButtonGroup(buttons: { ForEach(0..<components.count, id: \.self) { index in components[index] } }, isHorizontal: false)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.medium) {
        PrimaryButton("Primary Action") {}
        SecondaryButton("Secondary Action") {}
        OutlineButton("Outline Action") {}
        
        HStack(spacing: AppSpacing.small) {
            IconButton(icon: Image(systemName: "heart")) {}
            IconButton(icon: Image(systemName: "star")) {}
        }
        
        FAB(icon: Image(systemName: "plus")) {}
        
        SocialButton(icon: Image(systemName: "applelogo"), title: "Continue with Apple") {}
    }
    .padding()
}
