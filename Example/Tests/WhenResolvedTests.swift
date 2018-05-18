//
//  WhenResolvedTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import Foundation

import XCTest
import PromiseKit
import CancellablePromiseKit

class WhenResolvedTests: XCTestCase {
    
    var testPromise1: PromiseAndResolver!
    var testPromise2: PromiseAndResolver!
    
    class Error: Swift.Error { }
    
    override func setUp() {
        super.setUp()
        testPromise1 = createPromise()
        testPromise2 = createPromise()
    }
    
    override func tearDown() {
        super.tearDown()
        testPromise1 = nil
        testPromise2 = nil
    }
    
    func testFulfilled() {
        let expectation = self.expectation(description: "Promise was not fulfilled")
        
        let testValue1 = "test1"
        let cancellablePromise = when(resolved: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.done { (results) in
            switch (results[0], results[1]) {
            case (.fulfilled(let value), .rejected) where value == testValue1:
                expectation.fulfill()
            default:
                break
            }
        }
        testPromise1.resolver.fulfill(testValue1)
        testPromise2.resolver.reject(Error())
        
        wait(for: [expectation], timeout: 0.1)
    }

    func testCancel() {
        let expectation = self.expectation(description: "Promise was not cancelled")
        let cancelExpectation = self.expectation(description: "Promise 1 was cancelled")
        cancelExpectation.isInverted = true
        
        self.testPromise2.promise.catch(policy: .allErrors) { error in
            cancelExpectation.fulfill()
        }
        
        let testValue1 = "test1"
        let cancellablePromise = when(resolved: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                expectation.fulfill()
            default:
                break
            }
        }
        testPromise1.resolver.fulfill(testValue1)
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
    func testCancelAutoCancel() {
        let expectation = self.expectation(description: "Promise was not cancelled")
        let cancelExpectation = self.expectation(description: "Promise 1 was not cancelled")
        
        self.testPromise2.promise.catch(policy: .allErrors) { error in
            switch error {
            case CancellablePromiseError.cancelled:
                cancelExpectation.fulfill()
            default:
                break
            }
        }
        
        let testValue1 = "test1"
        let cancellablePromise = when(resolved: [testPromise1.promise, testPromise2.promise], autoCancel: true)
        _ = cancellablePromise.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                expectation.fulfill()
            default:
                break
            }
        }
        testPromise1.resolver.fulfill(testValue1)
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
}
