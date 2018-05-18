//
//  when.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import PromiseKit

/**
 Wait for promise, but abort if conditionPromise fails
 */
public func when<T>(_ promise: Promise<T>, while conditionPromise: Promise<Void>) -> Promise<T> {
    return when(fulfilled: [promise.asVoid(), race([promise.asVoid(), conditionPromise.asVoid()])]).map({ _ -> T in
        promise.value!
    })
}

public func when<T>(_ cancellablePromise: CancellablePromise<T>, while conditionPromise: Promise<Void>, autoCancel: Bool = false) -> Promise<T> {
    return when(fulfilled: [cancellablePromise.asVoid(), race([cancellablePromise.asVoid(), conditionPromise.asVoid()])]).map({ _ -> T in
        cancellablePromise.value!
    }).ensure {
        if autoCancel {
            cancellablePromise.cancel()
        }
    }
}

/**
 Parameter cancellablePromises: The promises to wait for
 Parameter autoCancel: Specifies if the provided promises should be cancelled when one of them rejects, or when the returned promise is cancelled
 */
public func when<T>(fulfilled cancellablePromises: [CancellablePromise<T>], autoCancel: Bool) -> CancellablePromise<[T]> {
    return CancellablePromise { (cancelPromise) -> Promise<[T]> in
        let promise = when(fulfilled: cancellablePromises.map{ $0.asPromise() })
        return when(promise, while: cancelPromise).ensure {
            if autoCancel {
                cancelAll(in: cancellablePromises)
            }
        }
    }
}

public func when<T>(fulfilled cancellablePromises: [CancellablePromise<T>]) -> CancellablePromise<[T]> {
    return when(fulfilled: cancellablePromises, autoCancel: false)
}

/**
 Parameter cancellablePromises: The promises to wait for
 Parameter autoCancel: Specifies if the provided promises should be cancelled when the returned promise is cancelled
 */
public func when<T>(resolved cancellablePromises: [CancellablePromise<T>], autoCancel: Bool) -> CancellablePromise<[Result<T>]> {
    return CancellablePromise { (cancelPromise) -> Promise<[Result<T>]> in
        let guarantee = when(resolved: cancellablePromises.map{ $0.asPromise() })
        let promise = guarantee.mapValues({ v in return v })
        return when(promise, while: cancelPromise).ensure {
            if autoCancel {
                cancelAll(in: cancellablePromises)
            }
        }
    }
}

public func when<T>(resolved cancellablePromises: [CancellablePromise<T>]) -> CancellablePromise<[Result<T>]> {
    return when(resolved: cancellablePromises, autoCancel: false)
}
