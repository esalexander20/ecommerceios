//
//  Loaders.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import SwiftUI

// MARK: - Loading State View

/// Full-screen loading overlay
public struct LoadingOverlay: View {
    private let isLoading: Bool
    private let message: String?
    
    public init(isLoading: Bool, message: String? = nil) {
        self.isLoading = isLoading
        self.message = message
    }
    
    public var body: some View {
        if isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.medium) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColor.primary))
                        .scaleEffect(1.5)
                    
                    if let message = message {
                        Text(message)
                            .font(AppFont.bodyMedium(weight: .medium))
                            .foregroundColor(AppColor.textInverse)
                    }
                }
                .padding(AppSpacing.large)
                .background(AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.CornerRadius.large))
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: isLoading)
        }
    }
}

// MARK: - Spinner Components

/// Small inline spinner
public struct InlineSpinner: View {
    private let color: Color
    private let size: CGFloat
    
    public init(color: Color = AppColor.primary, size: CGFloat = 20) {
        self.color = color
        self.size = size
    }
    
    public var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color))
            .frame(width: size, height: size)
    }
}

/// Determinate progress bar
public struct ProgressBar: View {
    private let progress: Double
    private let height: CGFloat
    private let color: Color
    private let backgroundColor: Color
    
    public init(
        progress: Double,
        height: CGFloat = 4,
        color: Color = AppColor.primary,
        backgroundColor: Color = AppColor.surfaceVariant
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.color = color
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                backgroundColor
                    .frame(height: height)
                    .clipShape(RoundedRectangle(cornerRadius: height / 2))
                
                color
                    .frame(width: CGFloat(progress) * geometry.size.width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: height / 2))
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Shimmer Effect (Skeleton Loading)

public struct ShimmerModifier: ViewModifier {
    @State private var isShimmering: Bool = false
    private let animationDuration: Double
    
    public init(animationDuration: Double = 1.5) {
        self.animationDuration = animationDuration
    }
    
    public func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white, .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isShimmering ? UIScreen.main.bounds.width : -UIScreen.main.bounds.width)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: animationDuration)
                    .repeatForever(autoreverses: false)
                ) {
                    isShimmering = true
                }
            }
    }
}

public extension View {
    /// Applies shimmer effect for skeleton loading
    func shimmer(animationDuration: Double = 1.5) -> some View {
        self.modifier(ShimmerModifier(animationDuration: animationDuration))
    }
}

// MARK: - Skeleton Views

/// Skeleton view for text
public struct SkeletonText: View {
    private let width: CGFloat?
    private let height: CGFloat
    private let lines: Int
    private let cornerRadius: CGFloat
    
    public init(width: CGFloat? = nil, height: CGFloat = 16, lines: Int = 1, cornerRadius: CGFloat = 2) {
        self.width = width
        self.height = height
        self.lines = lines
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.xs) {
            ForEach(0..<lines, id: \.self) { _ in
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColor.surfaceVariant)
                    .frame(width: width, height: height)
                    .shimmer()
            }
        }
    }
}

/// Skeleton view for rectangular content (images, cards)
public struct SkeletonRect: View {
    private let width: CGFloat?
    private let height: CGFloat?
    private let cornerRadius: CGFloat
    
    public init(width: CGFloat? = nil, height: CGFloat? = nil, cornerRadius: CGFloat = AppSpacing.CornerRadius.medium) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColor.surfaceVariant)
            .frame(width: width, height: height)
            .shimmer()
    }
}

/// Skeleton view for circular content (avatars, icons)
public struct SkeletonCircle: View {
    private let diameter: CGFloat
    
    public init(diameter: CGFloat = 40) {
        self.diameter = diameter
    }
    
    public var body: some View {
        Circle()
            .fill(AppColor.surfaceVariant)
            .frame(width: diameter, height: diameter)
            .shimmer()
    }
}

/// Skeleton view for product card
public struct SkeletonProductCard: View {
    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            SkeletonRect(height: 150, cornerRadius: AppSpacing.CornerRadius.medium)
            
            SkeletonText(width: 150, height: 16, lines: 1, cornerRadius: 2)
            
            SkeletonText(width: 100, height: 14, lines: 1, cornerRadius: 2)
            
            HStack {
                SkeletonText(width: 60, height: 14, lines: 1, cornerRadius: 2)
                Spacer()
                SkeletonCircle(diameter: 24)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Skeleton view for list row
public struct SkeletonListRow: View {
    public var body: some View {
        HStack(spacing: AppSpacing.medium) {
            SkeletonCircle(diameter: 48)
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                SkeletonText(width: 150, height: 16, lines: 1)
                SkeletonText(width: 100, height: 14, lines: 1)
            }
            
            Spacer()
            
            SkeletonText(width: 60, height: 14, lines: 1)
        }
        .padding(.vertical, AppSpacing.small)
    }
}

// MARK: - Empty State View

public enum EmptyStateType {
    case noProducts
    case noOrders
    case noNotifications
    case noCartItems
    case noSearchResults
    case noFavorites
    case networkError
    case custom(image: String, title: String, message: String)
    
    var image: String {
        switch self {
        case .noProducts: return "cart.badge.minus"
        case .noOrders: return "shippingbox"
        case .noNotifications: return "bell.badge"
        case .noCartItems: return "cart"
        case .noSearchResults: return "magnifyingglass"
        case .noFavorites: return "heart"
        case .networkError: return "wifi.exclamationmark"
        case .custom(let image, _, _): return image
        }
    }
    
    var title: String {
        switch self {
        case .noProducts: return "No Products Found"
        case .noOrders: return "No Orders Yet"
        case .noNotifications: return "No Notifications"
        case .noCartItems: return "Your Cart is Empty"
        case .noSearchResults: return "No Results Found"
        case .noFavorites: return "No Favorites"
        case .networkError: return "Network Error"
        case .custom(_, let title, _): return title
        }
    }
    
    var message: String {
        switch self {
        case .noProducts: return "Check back later for new arrivals"
        case .noOrders: return "Start shopping to see your orders here"
        case .noNotifications: return "You'll see notifications here"
        case .noCartItems: return "Browse products to add items to your cart"
        case .noSearchResults: return "Try a different search term"
        case .noFavorites: return "Tap the heart icon to save favorites"
        case .networkError: return "Check your connection and try again"
        case .custom(_, _, let message): return message
        }
    }
}

public struct EmptyStateView: View {
    private let type: EmptyStateType
    private let actionTitle: String?
    private let action: (() -> Void)?
    
    public init(
        type: EmptyStateType,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.type = type
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: AppSpacing.large) {
            Image(systemName: type.image)
                .font(.system(size: 64))
                .foregroundColor(AppColor.textSecondary)
                .symbolEffect(.bounce, value: UUID())
            
            VStack(spacing: AppSpacing.small) {
                Text(type.title)
                    .font(AppFont.titleLarge(weight: .bold))
                    .foregroundColor(AppColor.textPrimary)
                
                Text(type.message)
                    .font(AppFont.bodyMedium())
                    .foregroundColor(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.large)
            }
            
            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(actionTitle, action: action)
                    .padding(.top, AppSpacing.medium)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xxLarge)
    }
}

// MARK: - Placeholder View (For content that will load)

public struct PlaceholderView: View {
    private let type: PlaceholderType
    
    public enum PlaceholderType {
        case text(lines: Int)
        case image
        case card
        case list(rows: Int)
        case grid(items: Int)
        case custom(content: AnyView)
    }
    
    public init(type: PlaceholderType) {
        self.type = type
    }
    
    public var body: some View {
        Group {
            switch type {
            case .text(let lines):
                SkeletonText(lines: lines)
            case .image:
                SkeletonRect(height: 200)
            case .card:
                SkeletonProductCard()
            case .list(let rows):
                VStack(spacing: AppSpacing.small) {
                    ForEach(0..<rows, id: \.self) { _ in
                        SkeletonListRow()
                    }
                }
            case .grid(let items):
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.medium) {
                    ForEach(0..<items, id: \.self) { _ in
                        SkeletonProductCard()
                    }
                }
            case .custom(let content):
                content
            }
        }
        .shimmer()
    }
}

// MARK: - Pull to Refresh Modifier

public struct RefreshableModifier: ViewModifier {
    @State private var isRefreshing: Bool = false
    private let onRefresh: () async -> Void
    
    public init(onRefresh: @escaping () async -> Void) {
        self.onRefresh = onRefresh
    }
    
    public func body(content: Content) -> some View {
        content
            .refreshable {
                isRefreshing = true
                await onRefresh()
                isRefreshing = false
            }
            .overlay(
                Group {
                    if isRefreshing {
                        LoadingOverlay(isLoading: true)
                    }
                }
            )
    }
}

public extension View {
    func refreshable(onRefresh: @escaping () async -> Void) -> some View {
        self.modifier(RefreshableModifier(onRefresh: onRefresh))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppSpacing.xLarge) {
        // Loading Overlay
        LoadingOverlay(isLoading: true, message: "Loading...")
            .frame(height: 100)
        
        // Spinner
        HStack(spacing: AppSpacing.medium) {
            InlineSpinner()
            InlineSpinner(color: .blue, size: 30)
        }
        
        // Progress Bar
        ProgressBar(progress: 0.7)
            .frame(width: 200)
        
        Divider()
        
        // Skeleton Views
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Skeleton Loaders")
                .font(AppFont.titleMedium())
            
            SkeletonText(width: 150, lines: 1)
            
            SkeletonText(width: 200, lines: 3)
            
            SkeletonRect(width: 100, height: 100)
            
            SkeletonCircle(diameter: 50)
            
            SkeletonProductCard()
        }
        
        Divider()
        
        // Empty State
        EmptyStateView(
            type: .noCartItems,
            actionTitle: "Continue Shopping",
            action: {}
        )
        .frame(height: 200)
        
        // Placeholder
        PlaceholderView(type: .list(rows: 5))
    }
    .padding()
}
