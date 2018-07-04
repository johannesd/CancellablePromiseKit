//
//  map.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 04.07.18.
//

import Foundation
import PromiseKit

extension CancellablePromise {

    public func map<U>(on: DispatchQueue? = conf.Q.map, _ transform: @escaping(T) throws -> U) -> CancellablePromise<U> {
        return CancellablePromise<U>(using: self.asPromise().map(on: on, transform), cancel: cancel)
    }
    
    public func asVoid() -> CancellablePromise<Void> {
        return map(on: nil) { _ in }
    }
    
}
