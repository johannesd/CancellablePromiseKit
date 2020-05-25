//
//  CancellablePromise.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 11.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import PromiseKit

public class CancellablePromise<T> {
    
    /**
     Returns: True if this promise has been cancelled
     */
    public private(set) var isCancelled: Bool = false
    
    internal var subsequentCancels = [() -> ()]()
    
    private let promise: Promise<T>
    
    /**
     Returns the undelying promise
     */
    public func asPromise() -> Promise<T> {
        return promise
    }

    private let cancelPromise: Promise<Void>
    private let cancelResolver: Resolver<Void>
    private let cancelFunction: (() -> ())
    
    /**
     Aborts the execution of the underlying task
     */
    public func cancel() {
        isCancelled = true
        subsequentCancels.forEach { $0() }
        if isPending {
            cancelFunction()
            // Let already scheduled promise blocks (like `then`) execute first, before rejecting:
            (conf.Q.map ?? DispatchQueue.main).async {
                self.cancelResolver.reject(CancellablePromiseError.cancelled)
            }
        }
    }
    
    internal init(_ body: (_ cancelPromise: Promise<Void>) -> Promise<T>, cancel: @escaping () -> ()) {
        (self.cancelPromise, self.cancelResolver) = Promise<Void>.pending()
        self.promise = when(body(cancelPromise), while: cancelPromise)
        cancelFunction = cancel
    }

    public convenience init(using promise: Promise<T>, cancel: @escaping () -> ()) {
        self.init({ _ in promise }, cancel: cancel)
    }
    
    public convenience init(resolver body: (Resolver<T>) throws -> (() -> ())) {
        let (promise, resolver) = Promise<T>.pending()
        do {
            let cancel = try body(resolver)
            self.init(using: promise, cancel: cancel)
        } catch let error {
            resolver.reject(error)
            self.init(using: promise, cancel: { })
        }
    }
    
    public convenience init(wrapper body: (_ cancelPromise: Promise<Void>) -> Promise<T>) {
        self.init(body, cancel: { })
    }
    
    deinit {
        // Prevent PromiseKit's warning that a pending promise has been deinited:
        let resolver = cancelResolver
        (conf.Q.map ?? DispatchQueue.main).async {
            resolver.fulfill(Void())
        }
    }
    
}

extension CancellablePromise: Thenable, CatchMixin {

    public func pipe(to: @escaping (Result<T>) -> Void) {
        asPromise().pipe(to: to)
    }
    
    public var result: Result<T>? {
        return asPromise().result
    }

}

internal func cancelAll<T>(`in` array: [CancellablePromise<T>]) {
    array.forEach { (cancellablePromise) in
        cancellablePromise.cancel()
    }
}

