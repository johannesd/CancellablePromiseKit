//
//  then.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 17.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation
import PromiseKit

extension CancellablePromise {
    
    public func then<V>(on: DispatchQueue? = conf.Q.map, file: StaticString = #file, line: UInt = #line, _ body: @escaping(T) throws -> CancellablePromise<V>) -> CancellablePromise<V> {
        let promise: Promise<V> = then { (value) -> Promise<V> in
            let cancellablePromise = try body(value)
            if self.isCancelled {
                cancellablePromise.cancel()
            }
            self.subsequentCancels.append(cancellablePromise.cancel)
            return cancellablePromise.asPromise()
        }
        let cancellablePromise = CancellablePromise<V>(using: promise, cancel: cancel)
        return cancellablePromise
    }
    
}
