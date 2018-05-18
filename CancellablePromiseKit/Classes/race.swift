//
//  race.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import PromiseKit

/**
 Parameter cancellablePromises: The promises to wait for
 Parameter autoCancel: Specifies if the other provided promises should be cancelled when one of them fulfills, or when the returned promise is cancelled
 */
public func race<T>(_ cancellablePromises: [CancellablePromise<T>], autoCancel: Bool) -> CancellablePromise<T> {
    return CancellablePromise { (cancelPromise) -> Promise<T> in
        let promise = race(cancellablePromises.map{ $0.asPromise() })
        return when(promise, while: cancelPromise).ensure {
            if autoCancel {
                cancelAll(in: cancellablePromises)
            }
        }
    }
}

public func race<T>(_ cancellablePromises: [CancellablePromise<T>]) -> CancellablePromise<T> {
    return race(cancellablePromises, autoCancel: false)
}
