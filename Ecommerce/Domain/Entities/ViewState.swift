//
//  ViewState.swift
//  Ecommerce
//
//  Created by Vibe on 15.05.2025.
//

import Foundation
import Combine

/// Standard view state pattern for managing async data loading states in SwiftUI views.
/// Provides a consistent way to handle idle, loading, loaded, and error states.
///
/// Usage:
/// ```swift
/// @Published private(set) var productsState: ViewState<[Product]> = .idle
///
/// func loadProducts() {
///     productsState = .loading
///     repository.getProducts()
///         .sink(receiveCompletion: { [weak self] completion in
///             if case .failure(let error) = completion {
///                 self?.productsState = .error(error)
///             }
///         }, receiveValue: { [weak self] products in
///             self?.productsState = .loaded(products)
///         })
///         .store(in: &cancellables)
/// }
/// ```
///
/// In SwiftUI View:
/// ```swift
/// switch viewModel.productsState {
/// case .idle:
///     EmptyStateView(title: "No products", message: "Pull to refresh")
/// case .loading:
///     LoadingOverlay()
/// case .loaded(let products):
///     ProductList(products: products)
/// case .error(let error):
///     ErrorView(error: error, retryAction: viewModel.loadProducts)
/// }
/// ```
public enum ViewState<T> {
    /// Initial state, no data loaded yet
    case idle
    
    /// Data is being loaded
    case loading
    
    /// Data loaded successfully
    case loaded(T)
    
    /// Loading failed with an error
    case error(APIError)
}

// MARK: - Computed Properties

public extension ViewState {
    /// Returns true if currently in loading state
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if in idle state (no data, no loading)
    var isIdle: Bool {
        switch self {
        case .idle:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if data was loaded successfully
    var isLoaded: Bool {
        switch self {
        case .loaded:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if an error occurred
    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
    
    /// Returns the loaded value if available
    var value: T? {
        switch self {
        case .loaded(let value):
            return value
        default:
            return nil
        }
    }
    
    /// Returns the error if one occurred
    var error: APIError? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
}

// MARK: - Map Transformation

public extension ViewState {
    /// Transforms the loaded value using a closure
    /// - Parameter transform: Closure to transform T to U
    /// - Returns: New ViewState with transformed value
    func map<U>(_ transform: (T) -> U) -> ViewState<U> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .loaded(let value):
            return .loaded(transform(value))
        case .error(let error):
            return .error(error)
        }
    }
    
    /// Flat maps the loaded value to another ViewState
    /// - Parameter transform: Closure to transform T to ViewState<U>
    /// - Returns: Resulting ViewState<U>
    func flatMap<U>(_ transform: (T) -> ViewState<U>) -> ViewState<U> {
        switch self {
        case .idle:
            return .idle
        case .loading:
            return .loading
        case .loaded(let value):
            return transform(value)
        case .error(let error):
            return .error(error)
        }
    }
}

// MARK: - Combine Publishers

public extension ViewState {
    /// Creates a publisher that emits the current state and any future changes
    /// - Returns: Publisher that emits ViewState<T>
    func publisher() -> AnyPublisher<ViewState<T>, Never> {
        CurrentValueSubject<ViewState<T>, Never>(self).eraseToAnyPublisher()
    }
}

// MARK: - Convenience Methods

public extension ViewState {
    /// Returns the loaded value or a default value
    /// - Parameter defaultValue: Default value to return if not loaded
    /// - Returns: The loaded value or default
    func getValue(_ defaultValue: T) -> T {
        switch self {
        case .loaded(let value):
            return value
        default:
            return defaultValue
        }
    }
    
    /// Returns the loaded value or throws the error
    /// - Returns: The loaded value
    /// - Throws: APIError if state is error
    func getValueOrThrow() throws -> T {
        switch self {
        case .loaded(let value):
            return value
        case .error(let error):
            throw error
        default:
            throw APIError.unknown(nil)
        }
    }
}

// MARK: - Equatable Conformance

extension ViewState: Equatable where T: Equatable {
    public static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsValue), .loaded(let rhsValue)):
            return lhsValue == rhsValue
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
