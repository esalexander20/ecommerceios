//
//  DataState.swift
//  Ecommerce
//
//  Created by Vibe on 15.05.2025.
//

import Foundation
import Combine

/// Pagination state management for infinite scroll and paginated data loading.
/// Handles loading states for initial load, pagination, and refresh operations.
///
/// Usage:
/// ```swift
/// @Published private(set) var productsDataState: DataState<[Product]> = .initial
///
/// func loadProducts(refresh: Bool = false) {
///     if refresh {
///         productsDataState = .refreshing(current: productsDataState.items)
///     } else if productsDataState.isInitial {
///         productsDataState = .loading
///     } else {
///         productsDataState = .loadingMore(items: productsDataState.items)
///     }
///     
///     repository.getProducts(page: nextPage)
///         .sink(receiveCompletion: { [weak self] completion in
///             if case .failure(let error) = completion {
///                 self?.productsDataState = .error(error, items: self?.productsDataState.items ?? [])
///             }
///         }, receiveValue: { [weak self] newProducts in
///             let allProducts = (self?.productsDataState.items ?? []) + newProducts
///             let hasMore = newProducts.count == self?.pageSize
///             self?.productsDataState = .loaded(items: allProducts, hasMore: hasMore)
///         })
///         .store(in: &cancellables)
/// }
/// ```
///
/// In SwiftUI View:
/// ```swift
/// switch viewModel.productsDataState {
/// case .initial:
///     EmptyStateView(title: "No products")
/// case .loading:
///     LoadingOverlay()
/// case .loaded(let items, let hasMore):
///     ProductList(items: items, showLoadingMore: hasMore)
/// case .loadingMore(let items):
///     ProductList(items: items, showLoadingMore: true)
/// case .refreshing(let items):
///     ProductList(items: items, showRefreshing: true)
/// case .error(let error, let items):
///     ProductList(items: items, error: error)
/// case .empty:
///     EmptyStateView(title: "No products found")
/// }
/// ```
public enum DataState<T: RandomAccessCollection> where T.Element: Identifiable {
    /// Initial state with no data loaded
    case initial
    
    /// Loading initial data
    case loading
    
    /// Data loaded successfully
    /// - Parameters:
    ///   - items: The loaded items
    ///   - hasMore: Whether there are more items to load
    case loaded(items: T, hasMore: Bool)
    
    /// Loading more items (pagination)
    case loadingMore(items: T)
    
    /// Refreshing data while keeping current items
    case refreshing(current: T)
    
    /// Error occurred
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - items: Previously loaded items (for partial display)
    case error(APIError, items: T)
    
    /// No items available (filtered or empty result)
    case empty
}

// MARK: - Type Aliases

public typealias PaginatedState<T> = DataState<[T]> where T: Identifiable

// MARK: - Computed Properties

public extension DataState {
    /// All items across all states
    var items: T {
        switch self {
        case .initial:
            return [] as! T
        case .loading:
            return [] as! T
        case .loaded(let items, _):
            return items
        case .loadingMore(let items):
            return items
        case .refreshing(let current):
            return current
        case .error(_, let items):
            return items
        case .empty:
            return [] as! T
        }
    }
    
    /// Returns true if currently loading (initial or more)
    var isLoading: Bool {
        switch self {
        case .loading, .loadingMore, .refreshing:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if initial loading is in progress
    var isInitialLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if loading more items (pagination)
    var isLoadingMore: Bool {
        switch self {
        case .loadingMore:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if refreshing data
    var isRefreshing: Bool {
        switch self {
        case .refreshing:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if in error state
    var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
    
    /// Returns true if no items are available
    var isEmpty: Bool {
        switch self {
        case .empty:
            return true
        default:
            return items.isEmpty
        }
    }
    
    /// Returns true if initial state
    var isInitial: Bool {
        switch self {
        case .initial:
            return true
        default:
            return false
        }
    }
    
    /// Returns the error if one occurred
    var error: APIError? {
        switch self {
        case .error(let error, _):
            return error
        default:
            return nil
        }
    }
    
    /// Returns whether there are more items to load (for pagination)
    var hasMore: Bool {
        switch self {
        case .loaded(_, let hasMore):
            return hasMore
        default:
            return false
        }
    }
    
    /// Count of items
    var count: Int {
        return items.count
    }
}

// MARK: - Array-specific Extensions

public extension DataState where T: RangeReplaceableCollection, T.Element: Identifiable {
    /// Creates a loaded state with array items
    /// - Parameters:
    ///   - items: The items
    ///   - hasMore: Whether there are more items
    init(items: T, hasMore: Bool) {
        self = .loaded(items: items, hasMore: hasMore)
    }
    
    /// Appends new items to current state
    /// - Parameter newItems: New items to append
    /// - Returns: Updated DataState with appended items
    func appending(_ newItems: T) -> DataState<T> {
        switch self {
        case .initial:
            return .loaded(items: newItems, hasMore: false)
        case .loading:
            return .loadingMore(items: newItems)
        case .loaded(let items, let hasMore):
            var combined = items
            combined.append(contentsOf: newItems)
            return .loaded(items: combined, hasMore: hasMore)
        case .loadingMore(let items):
            var combined = items
            combined.append(contentsOf: newItems)
            return .loadingMore(items: combined)
        case .refreshing(let current):
            var combined = current
            combined.append(contentsOf: newItems)
            return .refreshing(current: combined)
        case .error(let error, let items):
            var combined = items
            combined.append(contentsOf: newItems)
            return .error(error, items: combined)
        case .empty:
            return .loaded(items: newItems, hasMore: false)
        }
    }
    
    /// Prepends new items to current state
    /// - Parameter newItems: New items to prepend
    /// - Returns: Updated DataState with prepended items
    func prepending(_ newItems: T) -> DataState<T> {
        switch self {
        case .initial:
            return .loaded(items: newItems, hasMore: false)
        case .loading:
            return .loadingMore(items: newItems)
        case .loaded(let items, let hasMore):
            var combined = newItems
            combined.append(contentsOf: items)
            return .loaded(items: combined, hasMore: hasMore)
        case .loadingMore(let items):
            var combined = newItems
            combined.append(contentsOf: items)
            return .loadingMore(items: combined)
        case .refreshing(let current):
            var combined = newItems
            combined.append(contentsOf: current)
            return .refreshing(current: combined)
        case .error(let error, let items):
            var combined = newItems
            combined.append(contentsOf: items)
            return .error(error, items: combined)
        case .empty:
            return .loaded(items: newItems, hasMore: false)
        }
    }
}

// MARK: - Map Transformation

public extension DataState where T: Sequence, T.Element: Identifiable {
    /// Transforms items using a closure
    /// - Parameter transform: Closure to transform T.Element to U
    /// - Returns: New DataState with transformed items
    func map<U: Identifiable>(_ transform: @escaping (T.Element) -> U) -> DataState<[U]> {
        switch self {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case .loaded(let items, let hasMore):
            let transformed = items.map(transform)
            return .loaded(items: transformed, hasMore: hasMore)
        case .loadingMore(let items):
            let transformed = items.map(transform)
            return .loadingMore(items: transformed)
        case .refreshing(let current):
            let transformed = current.map(transform)
            return .refreshing(current: transformed)
        case .error(let error, let items):
            let transformed = items.map(transform)
            return .error(error, items: transformed)
        case .empty:
            return .empty
        }
    }
}

// MARK: - Filter Transformation

public extension DataState where T: RangeReplaceableCollection {
    /// Filters items using a closure
    /// - Parameter predicate: Closure to filter items
    /// - Returns: New DataState with filtered items
    func filter(_ predicate: @escaping (T.Element) -> Bool) -> DataState<T> {
        switch self {
        case .initial:
            return .initial
        case .loading:
            return .loading
        case .loaded(let items, let hasMore):
            let filtered = items.filter(predicate)
            return .loaded(items: filtered, hasMore: hasMore)
        case .loadingMore(let items):
            let filtered = items.filter(predicate)
            return .loadingMore(items: filtered)
        case .refreshing(let current):
            let filtered = current.filter(predicate)
            return .refreshing(current: filtered)
        case .error(let error, let items):
            let filtered = items.filter(predicate)
            return .error(error, items: filtered)
        case .empty:
            return .empty
        }
    }
}

// MARK: - Combine Publishers

public extension DataState {
    /// Creates a publisher that emits the current state and any future changes
    /// - Returns: Publisher that emits DataState<T>
    func publisher() -> AnyPublisher<DataState<T>, Never> {
        CurrentValueSubject<DataState<T>, Never>(self).eraseToAnyPublisher()
    }
}

// MARK: - Equatable Conformance

extension DataState: Equatable where T: Equatable {
    public static func == (lhs: DataState<T>, rhs: DataState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.loaded(let lhsItems, let lhsHasMore), .loaded(let rhsItems, let rhsHasMore)):
            return lhsItems == rhsItems && lhsHasMore == rhsHasMore
        case (.loadingMore(let lhsItems), .loadingMore(let rhsItems)):
            return lhsItems == rhsItems
        case (.refreshing(let lhsCurrent), .refreshing(let rhsCurrent)):
            return lhsCurrent == rhsCurrent
        case (.error(let lhsError, let lhsItems), .error(let rhsError, let rhsItems)):
            return lhsError == rhsError && lhsItems == rhsItems
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

// MARK: - Convenience Static Methods

public extension DataState {
    /// Creates a loaded state
    /// - Parameters:
    ///   - items: The items
    ///   - hasMore: Whether there are more items
    static func makeLoaded(_ items: T, hasMore: Bool = false) -> DataState<T> {
        return .loaded(items: items, hasMore: hasMore)
    }
    
    /// Creates an error state with items
    /// - Parameters:
    ///   - error: The error
    ///   - items: Previously loaded items
    static func makeError(_ error: APIError, items: T) -> DataState<T> {
        return .error(error, items: items)
    }
    
    /// Creates a loading more state
    /// - Parameter items: Current items
    static func makeLoadingMore(_ items: T) -> DataState<T> {
        return .loadingMore(items: items)
    }
    
    /// Creates a refreshing state
    /// - Parameter current: Current items
    static func makeRefreshing(_ current: T) -> DataState<T> {
        return .refreshing(current: current)
    }
}
