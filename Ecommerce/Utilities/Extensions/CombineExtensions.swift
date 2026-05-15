//
//  CombineExtensions.swift
//  Ecommerce
//
//  Created by Vibe on 15.05.2025.
//

import Foundation
import Combine

/// Custom Combine publishers and operators for the e-commerce app.
/// Extends Combine functionality with commonly used patterns and utilities.

// MARK: - Custom Publishers

public extension Publishers {
    /// A publisher that emits a value after a specified delay.
    /// Useful for debouncing or delayed actions.
    ///
    /// - Parameters:
    ///   - value: The value to emit
    ///   - delay: The delay in seconds before emitting the value
    ///   - scheduler: The scheduler to use
    /// - Returns: A publisher that emits the value after the delay
    ///
    /// Usage:
    /// ```swift
    /// Publishers.delayedValue(someValue, delay: 1.0)
    ///     .sink { value in
    ///         print(value)
    ///     }
    /// ```
    static func delayedValue<T>(_ value: T, delay: TimeInterval, scheduler: DispatchQueue = .main) -> AnyPublisher<T, Never> {
        Just(value)
            .delay(for: .seconds(delay), scheduler: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// A publisher that emits the result of an async operation.
    /// Converts async/await functions to Combine publishers.
    ///
    /// - Parameter operation: Async closure to execute
    /// - Returns: A publisher that emits the result or error
    ///
    /// Usage:
    /// ```swift
    /// Publishers.async { try await fetchData() }
    ///     .sink(receiveCompletion: { _ in }, receiveValue: { data in
    ///         print(data)
    ///     })
    /// ```
    static func async<T>(_ operation: @escaping () async throws -> T) -> AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            Task {
                do {
                    let result = try await operation()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// A publisher that emits the result of a throwing closure.
    /// Useful for wrapping synchronous throwing functions.
    ///
    /// - Parameter operation: Throwing closure to execute
    /// - Returns: A publisher that emits the result or error
    static func `defer`<T>(_ operation: @escaping () throws -> T) -> AnyPublisher<T, Error> {
        Deferred {
            Future<T, Error> { promise in
                do {
                    let result = try operation()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Combines two publishers and emits their results as a tuple.
    ///
    /// - Parameters:
    ///   - publisher1: First publisher
    ///   - publisher2: Second publisher
    /// - Returns: A publisher that emits a tuple of both values
    static func combineLatest<T, U>(_ publisher1: AnyPublisher<T, Error>, _ publisher2: AnyPublisher<U, Error>) -> AnyPublisher<(T, U), Error> {
        CombineLatest(publisher1, publisher2)
            .eraseToAnyPublisher()
    }
    
    /// Combines three publishers and emits their results as a tuple.
    static func combineLatest<T, U, V>(_ p1: AnyPublisher<T, Error>, _ p2: AnyPublisher<U, Error>, _ p3: AnyPublisher<V, Error>) -> AnyPublisher<(T, U, V), Error> {
        CombineLatest3(p1, p2, p3)
            .eraseToAnyPublisher()
    }
    
    /// Combines four publishers and emits their results as a tuple.
    static func combineLatest<T, U, V, W>(_ p1: AnyPublisher<T, Error>, _ p2: AnyPublisher<U, Error>, _ p3: AnyPublisher<V, Error>, _ p4: AnyPublisher<W, Error>) -> AnyPublisher<(T, U, V, W), Error> {
        CombineLatest4(p1, p2, p3, p4)
            .eraseToAnyPublisher()
    }
}

// MARK: - Custom Operators

public extension Publisher where Output == Bool {
    /// Inverts the boolean output of a publisher.
    ///
    /// Usage:
    /// ```swift
    /// someBoolPublisher
    ///     .not()
    ///     .sink { isNotValue in
    ///         print(isNotValue)
    ///     }
    /// ```
    func not() -> AnyPublisher<Bool, Failure> {
        self.map { !$0 }
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Equatable {
    /// Filters out consecutive duplicate values.
    /// Only emits when the value changes from the previous emission.
    ///
    /// Usage:
    /// ```swift
    /// somePublisher
    ///     .skipDuplicates()
    ///     .sink { changedValue in
    ///         print(changedValue)
    ///     }
    /// ```
    func skipDuplicates() -> AnyPublisher<Output, Failure> {
        self.removeDuplicates()
            .eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Debounces the publisher with a specified interval.
    /// Only emits the most recent value after the specified interval has elapsed without any new values.
    ///
    /// - Parameters:
    ///   - interval: The debounce interval
    ///   - scheduler: The scheduler to use
    /// - Returns: A debounced publisher
    ///
    /// Usage:
    /// ```swift
    /// searchTextPublisher
    ///     .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
    ///     .sink { searchText in
    ///         performSearch(searchText)
    ///     }
    /// ```
    func debounce(for interval: TimeInterval, scheduler: DispatchQueue = .main) -> AnyPublisher<Output, Failure> {
        self.debounce(for: .seconds(interval), scheduler: scheduler)
            .eraseToAnyPublisher()
    }
    
    /// Throttles the publisher to emit at most once per interval.
    ///
    /// - Parameters:
    ///   - interval: The throttle interval
    ///   - scheduler: The scheduler to use
    ///   - latest: Whether to emit the latest value when the interval ends
    /// - Returns: A throttled publisher
    func throttle(for interval: TimeInterval, scheduler: DispatchQueue = .main, latest: Bool = true) -> AnyPublisher<Output, Failure> {
        self.throttle(for: .seconds(interval), scheduler: scheduler, latest: latest)
            .eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Never {
    /// Converts a publisher with Never failure to one with Error failure.
    /// Useful for combining with other publishers that can fail.
    func mapError<E: Error>() -> AnyPublisher<Output, E> {
        self.setFailureType(to: E.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Timeout Operators

/// Custom timeout error
public struct TimeoutError: Error, LocalizedError {
    public var errorDescription: String? {
        return "The operation timed out"
    }
    
    public init() {}
}

public extension Publisher {
    /// Times out the publisher if it doesn't emit a value within the specified interval.
    ///
    /// - Parameters:
    ///   - interval: Timeout interval
    ///   - scheduler: Scheduler to use
    ///   - customError: Custom error to emit on timeout
    /// - Returns: A publisher that times out
    ///
    /// Usage:
    /// ```swift
    /// networkRequest
    ///     .timeout(for: .seconds(10), scheduler: DispatchQueue.main)
    ///     .sink(receiveCompletion: { completion in
    ///         if case .failure(let error) = completion, error is TimeoutError {
    ///             print("Request timed out")
    ///         }
    ///     }, receiveValue: { data in
    ///         print(data)
    ///     })
    /// ```
    func timeout(
        for interval: TimeInterval,
        scheduler: DispatchQueue = .main
    ) -> AnyPublisher<Output, Failure> {
        self.timeout(.seconds(interval), scheduler: scheduler, customError: { TimeoutError() as! Failure })
            .eraseToAnyPublisher()
    }
}

// MARK: - Logging Operators

public extension Publisher {
    /// Logs all events from the publisher.
    ///
    /// - Parameters:
    ///   - prefix: Prefix for log messages
    ///   - logger: Closure to handle log messages
    /// - Returns: A publisher that logs events
    ///
    /// Usage:
    /// ```swift
    /// somePublisher
    ///     .logEvents(prefix: "[Network]")
    ///     .sink(...)
    /// ```
    func logEvents(prefix: String = "", logger: @escaping (String) -> Void = { Swift.print($0) }) -> AnyPublisher<Output, Failure> {
        self.handleEvents(
            receiveSubscription: { _ in logger("{" + prefix + "} Subscribed") },
            receiveOutput: { output in logger("{" + prefix + "} Received: \(output)") },
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    logger("{" + prefix + "} Completed")
                case .failure(let error):
                    logger("{" + prefix + "} Failed: \(error)")
                }
            },
            receiveCancel: { logger("{" + prefix + "} Cancelled") },
            receiveRequest: { demand in logger("{" + prefix + "} Requested: \(demand)") }
        )
        .eraseToAnyPublisher()
    }
    
    /// Logs errors from the publisher.
    ///
    /// - Parameters:
    ///   - prefix: Prefix for log messages
    ///   - logger: Closure to handle log messages
    /// - Returns: A publisher that logs errors
    func logErrors(prefix: String = "", logger: @escaping (String) -> Void = { Swift.print($0) }) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            logger("{" + prefix + "} Error: \(error)")
            return Fail(outputType: Output.self, failure: error)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - UI-Specific Operators

public extension Publisher where Output: Equatable {
    /// Emits only when the output changes from the previous value.
    /// Similar to skipDuplicates but with more control.
    ///
    /// - Parameter comparator: Closure to compare current and previous values
    /// - Returns: A publisher that emits only on changes
    ///
    /// Usage:
    /// ```swift
    /// somePublisher
    ///     .onChange { oldValue, newValue in
    ///         return oldValue != newValue
    ///     }
    ///     .sink(...)
    /// ```
    func onChange(_ comparator: @escaping (Output, Output) -> Bool = { $0 != $1 }) -> AnyPublisher<Output, Failure> {
        self.scan(Optional<Output>.none) { previous, current in
            guard let previous = previous else {
                return current
            }
            return comparator(previous, current) ? current : previous
        }
        .compactMap { $0 }
        .eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Performs an action when the publisher emits a value.
    ///
    /// - Parameter action: Closure to execute on each emission
    /// - Returns: A publisher that performs the action
    ///
    /// Usage:
    /// ```swift
    /// somePublisher
    ///     .onEmit { value in
    ///         Swift.print("New value:", value)
    ///     }
    ///     .sink(...)
    /// ```
    func onEmit(_ action: @escaping (Output) -> Void) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveOutput: action)
            .eraseToAnyPublisher()
    }
    
    /// Performs an action when the publisher completes.
    ///
    /// - Parameter action: Closure to execute on completion
    /// - Returns: A publisher that performs the action
    func onComplete(_ action: @escaping (Subscribers.Completion<Failure>) -> Void) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveCompletion: action)
            .eraseToAnyPublisher()
    }
    
    /// Performs an action when the publisher is subscribed.
    ///
    /// - Parameter action: Closure to execute on subscription
    /// - Returns: A publisher that performs the action
    func onSubscribe(_ action: @escaping () -> Void) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveSubscription: { _ in action() })
            .eraseToAnyPublisher()
    }
}

// MARK: - Collection Operators

public extension Publisher where Output: RandomAccessCollection {
    /// Emits the element at a specific index.
    ///
    /// - Parameter index: Index of the element to emit
    /// - Returns: A publisher that emits the element at the specified index
    func element(at index: Int) -> AnyPublisher<Output.Element, Failure> {
        self.flatMap { collection in
            if index < collection.count {
                return Just(collection[collection.index(collection.startIndex, offsetBy: index)])
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(outputType: Output.Element.self, failure: IndexOutOfRangeError() as! Failure)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Emits the first element of the collection.
    ///
    /// - Returns: A publisher that emits the first element
    func firstElement() -> AnyPublisher<Output.Element, Failure> {
        self.element(at: 0)
    }
    
    /// Emits the last element of the collection.
    ///
    /// - Returns: A publisher that emits the last element
    func lastElement() -> AnyPublisher<Output.Element, Failure> {
        self.flatMap { collection in
            if let last = collection.last {
                return Just(last)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(outputType: Output.Element.self, failure: IndexOutOfRangeError() as! Failure)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Dictionary Operators

public extension Publisher where Output == [String: Any] {
    /// Emits the value for a specific key.
    ///
    /// - Parameter key: Key to look up
    /// - Returns: A publisher that emits the value for the key
    func value(forKey key: String) -> AnyPublisher<Any, Failure> {
        self.flatMap { dict in
            if let value = dict[key] {
                return Just(value)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(outputType: Any.self, failure: KeyNotFoundError() as! Failure)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Retry Operators

public extension Publisher {
    /// Retries the publisher a specified number of times with exponential backoff.
    ///
    /// - Parameters:
    ///   - maxAttempts: Maximum number of retry attempts
    ///   - initialDelay: Initial delay before first retry
    ///   - maxDelay: Maximum delay between retries
    ///   - multiplier: Multiplier for exponential backoff
    ///   - scheduler: Scheduler to use for delays
    /// - Returns: A publisher that retries on failure
    ///
    /// Usage:
    /// ```swift
    /// networkRequest
    ///     .retryWithBackoff(maxAttempts: 3, initialDelay: 1.0, maxDelay: 30.0)
    ///     .sink(receiveCompletion: { _ in }, receiveValue: { data in
    ///         print(data)
    ///     })
    /// ```
    func retryWithBackoff(
        maxAttempts: Int,
        initialDelay: TimeInterval = 1.0,
        maxDelay: TimeInterval = 30.0,
        multiplier: Double = 2.0,
        scheduler: DispatchQueue = .main
    ) -> AnyPublisher<Output, Failure> {
        var attempts = 0
        
        return self.catch { error -> AnyPublisher<Output, Failure> in
            guard attempts < maxAttempts else {
                return Fail(outputType: Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
            
            attempts += 1
            let delay = Swift.min(initialDelay * pow(multiplier, Double(attempts - 1)), maxDelay)
            
            return Just(())
                .delay(for: .seconds(delay), scheduler: scheduler)
                .flatMap { _ in self.retryWithBackoff(
                    maxAttempts: maxAttempts,
                    initialDelay: initialDelay,
                    maxDelay: maxDelay,
                    multiplier: multiplier,
                    scheduler: scheduler
                ) }
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    /// Retries the publisher when a condition is met.
    ///
    /// - Parameter shouldRetry: Closure that determines if retry should be attempted
    /// - Returns: A publisher that retries conditionally
    ///
    /// Usage:
    /// ```swift
    /// networkRequest
    ///     .retryWhen { error in
    ///         // Only retry on network errors
    ///         return (error as? APIError)?.isNetworkError == true
    ///     }
    ///     .sink(...)
    /// ```
    func retryWhen(_ shouldRetry: @escaping (Failure) -> Bool) -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            if shouldRetry(error) {
                return self.retryWhen(shouldRetry)
                    .eraseToAnyPublisher()
            } else {
                return Fail(outputType: Output.self, failure: error)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Validation Operators

/// Custom validation error for Combine operations
public struct CombineValidationError: Error, LocalizedError {
    public let message: String
    
    public static let invalidInput = CombineValidationError("Invalid input")
    
    public init(_ message: String = "Validation failed") {
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
}

public extension Publisher {
    /// Validates the output using a closure.
    /// If validation fails, emits a CombineValidationError.
    ///
    /// - Parameter validator: Closure that validates the output
    /// - Returns: A publisher that validates output
    ///
    /// Usage:
    /// ```swift
    /// formPublisher
    ///     .validate { form in
    ///         form.isValid
    ///     }
    ///     .sink(receiveCompletion: { _ in }, receiveValue: { validForm in
    ///         // Only receives valid forms
    ///     })
    /// ```
    func validate(_ validator: @escaping (Output) -> Bool) -> AnyPublisher<Output, Failure> where Failure: Error {
        self.flatMap { output in
            if validator(output) {
                return Just(output)
                    .setFailureType(to: Failure.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(outputType: Output.self, failure: CombineValidationError.invalidInput as! Failure)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Error Types

public struct IndexOutOfRangeError: Error, LocalizedError {
    public var errorDescription: String? {
        return "Index out of range"
    }
}

public struct KeyNotFoundError: Error, LocalizedError {
    public var errorDescription: String? {
        return "Key not found"
    }
}

// MARK: - Weak Reference Storage

/// A cancellable that holds a weak reference to an object.
/// Useful for storing cancellables in objects that might be deallocated.
public class WeakCancellable: Cancellable {
    private weak var object: AnyObject?
    private var cancellable: AnyCancellable?
    
    public init<T: AnyObject>(_ object: T, cancellable: AnyCancellable) {
        self.object = object
        self.cancellable = cancellable
    }
    
    public func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
    
    deinit {
        cancel()
    }
}

public extension Cancellable {
    /// Stores the cancellable in a set with a weak reference to the owner.
    /// Automatically cancels when the owner is deallocated.
    ///
    /// - Parameters:
    ///   - owner: The owner object
    ///   - set: The set to store in
    func store(in owner: AnyObject, in set: inout Set<AnyCancellable>) {
        let weakCancellable = WeakCancellable(owner, cancellable: AnyCancellable(self))
        set.insert(AnyCancellable(weakCancellable))
    }
}

// MARK: - Event Type for Materialize

/// Event enum for materialized publishers
public enum Event<Output, Failure: Error> {
    case value(Output)
    case failure(Failure)
    case finished
}

public extension Publisher {
    /// Materializes the publisher's events (values and completion) into a single stream.
    ///
    /// Usage:
    /// ```swift
    /// somePublisher
    ///     .materialize()
    ///     .sink { event in
    ///         switch event {
    ///         case .value(let value): print(value)
    ///         case .failure(let error): print(error)
    ///         case .finished: print("Completed")
    ///         }
    ///     }
    /// ```
    func materialize() -> AnyPublisher<Event<Output, Failure>, Never> {
        self.map { Event.value($0) }
            .catch { error -> AnyPublisher<Event<Output, Failure>, Never> in
                Just(Event.failure(error))
                    .eraseToAnyPublisher()
            }
            .append(Event.finished)
            .eraseToAnyPublisher()
    }
}
