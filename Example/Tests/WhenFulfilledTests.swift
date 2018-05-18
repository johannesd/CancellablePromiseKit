//
//  WhenFulfilledTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

typealias PromiseAndResolver = (promise: CancellablePromise<String>, resolver: Resolver<String>)

func createPromise() -> PromiseAndResolver {
    let (basePromise, resolver) = Promise<String>.pending()
    let promise = CancellablePromise(using: basePromise, cancel: { resolver.reject(CancellablePromiseError.cancelled) })
    return (promise, resolver)
}

class WhenFulfilledTests: XCTestCase {
    
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
        let testValue2 = "test2"
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.done { (strings) in
            if strings == [testValue1, testValue2] {
                expectation.fulfill()
            }
        }
        testPromise1.resolver.fulfill(testValue1)
        testPromise2.resolver.fulfill(testValue2)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRejected() {
        let expectation = self.expectation(description: "Promise was not rejected")
        
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch { (error) in
            expectation.fulfill()
        }
        testPromise2.resolver.reject(Error())
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRejectedOtherFulfilled() {
        let expectation = self.expectation(description: "Promise was not rejected")
        
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch { (error) in
            expectation.fulfill()
        }
        testPromise1.resolver.fulfill("test1")
        testPromise2.resolver.reject(Error())
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRejectedAutoCancelOther() {
        let expectation = self.expectation(description: "Promise was not rejected")
        let cancelExpectation = self.expectation(description: "Other Promise was not cancelled")
        
        self.testPromise1.promise.catch(policy: .allErrors) { error in
            switch error {
            case CancellablePromiseError.cancelled:
                cancelExpectation.fulfill()
            default:
                break
            }
        }
        
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise], autoCancel: true)
        _ = cancellablePromise.catch { (error) in
            expectation.fulfill()
        }
        testPromise2.resolver.reject(Error())
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
    func testCancel() {
        let expectation = self.expectation(description: "Promise was not cancelled")
        let cancelExpectation = self.expectation(description: "Promise 1 was cancelled")
        cancelExpectation.isInverted = true
      
        self.testPromise2.promise.catch(policy: .allErrors) { error in
            cancelExpectation.fulfill()
        }
        
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                expectation.fulfill()
            default:
                break
            }
        }
        testPromise1.resolver.fulfill("test1")
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
    func testCancelAutoCancelOther() {
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
        
        let cancellablePromise = when(fulfilled: [testPromise1.promise, testPromise2.promise], autoCancel: true)
        _ = cancellablePromise.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                expectation.fulfill()
            default:
                break
            }
        }
        testPromise1.resolver.fulfill("test1")
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
}
