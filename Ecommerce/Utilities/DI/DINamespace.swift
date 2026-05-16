//
//  DINamespace.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation

/// Namespace for Dependency Injection related types
public enum DI {
    /// Provides access to the shared DIContainer instance
    public static var container: DIContainerProtocol {
        return DIContainer.shared
    }

    /// Convenience access to repositories
    public static var repositories: Repositories.Type {
        return Repositories.self
    }
}
