//
//  CancellablePromiseError.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 18.05.18.
//

import PromiseKit

public enum CancellablePromiseError: Swift.Error, CancellableError {
    case cancelled
}

extension CancellablePromiseError {
    
    public var isCancelled: Bool {
        switch self  {
        case .cancelled:
            return true
        }
    }
    
}
