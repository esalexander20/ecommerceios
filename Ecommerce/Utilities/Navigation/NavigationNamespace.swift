//
//  NavigationNamespace.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

/// Namespace for Navigation related types
/// Provides convenient access to navigation components
public enum Navigation {
    /// Provides access to the shared SwiftUINavigator instance
    public static var navigator: SwiftUINavigator {
        return SwiftUINavigator.shared
    }
}
