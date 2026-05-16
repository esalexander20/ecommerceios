//
//  CoordinatorProtocol.swift
//  Ecommerce
//
//  Created by Developer on 15/5/26.
//

import Foundation
import SwiftUI

/// Base protocol for all coordinators
/// Defines the common interface that all coordinators must implement
public protocol CoordinatorProtocol: AnyObject {
    /// The navigation controller or router used for navigation
    var router: RouterProtocol { get }
    
    /// Child coordinators that this coordinator manages
    var childCoordinators: [CoordinatorProtocol] { get set }
    
    /// Starts the coordinator's flow
    func start()
    
    /// Adds a child coordinator
    func childDidFinish(_ child: CoordinatorProtocol?)
}

/// Extension providing default implementation for child coordinator management
public extension CoordinatorProtocol {
    /// Removes a child coordinator from the list
    func childDidFinish(_ child: CoordinatorProtocol?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}

/// Protocol for navigation routing
/// Abstracts the actual navigation implementation (SwiftUI NavigationPath, UINavigationController, etc.)
public protocol RouterProtocol: AnyObject {
    /// Navigates to a view
    func navigate(to view: AnyView, animated: Bool)
    
    /// Navigates to a view with a specific route
    func navigate(to route: AppRoute, animated: Bool)
    
    /// Pops the top view (goes back)
    func pop(animated: Bool)
    
    /// Pops to the root view
    func popToRoot(animated: Bool)
    
    /// Dismisses the current view/modal
    func dismiss(animated: Bool)
    
    /// Presents a view modally
    func present(_ view: AnyView, animated: Bool, completion: (() -> Void)?)
    
    /// Dismisses a modal view
    func dismissModal(animated: Bool, completion: (() -> Void)?)
    
    /// Resets the navigation stack
    func reset()
}
