//
//  RaceTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class RaceTests: XCTestCase {
    
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
        let cancellablePromise = race([testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.done { (string) in
            if string == testValue1 {
                expectation.fulfill()
            }
        }
        testPromise1.resolver.fulfill(testValue1)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testRejected() {
        let expectation = self.expectation(description: "Promise was not rejected")
        
        let cancellablePromise = race([testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch { (error) in
            expectation.fulfill()
        }
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
        
        let cancellablePromise = race([testPromise1.promise, testPromise2.promise], autoCancel: true)
        _ = cancellablePromise.catch { (error) in
            expectation.fulfill()
        }
        testPromise2.resolver.reject(Error())
        
        wait(for: [expectation, cancelExpectation], timeout: 0.1)
    }
    
    func testCancel() {
        let expectation = self.expectation(description: "Promise was not cancelled")
        let cancelExpectation1 = self.expectation(description: "Promise 1 was cancelled")
        cancelExpectation1.isInverted = true
        let cancelExpectation2 = self.expectation(description: "Promise 1 was cancelled")
        cancelExpectation2.isInverted = true

        self.testPromise1.promise.catch(policy: .allErrors) { error in
            cancelExpectation1.fulfill()
        }
        self.testPromise2.promise.catch(policy: .allErrors) { error in
            cancelExpectation2.fulfill()
        }
        
        let cancellablePromise = race([testPromise1.promise, testPromise2.promise])
        _ = cancellablePromise.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                expectation.fulfill()
            default:
                break
            }
        }
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation1, cancelExpectation2], timeout: 0.1)
    }
    
    func testCancelAutoCancelOther() {
        let expectation = self.expectation(description: "Promise was not cancelled")
        let cancelExpectation1 = self.expectation(description: "Promise 1 was not cancelled")
        let cancelExpectation2 = self.expectation(description: "Promise 1 was not cancelled")

        self.testPromise1.promise.catch(policy: .allErrors) { error in
            switch error {
            case CancellablePromiseError.cancelled:
                cancelExpectation1.fulfill()
            default:
                break
            }
        }
        self.testPromise2.promise.catch(policy: .allErrors) { error in
            switch error {
            case CancellablePromiseError.cancelled:
                cancelExpectation2.fulfill()
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
        cancellablePromise.cancel()
        
        wait(for: [expectation, cancelExpectation1, cancelExpectation2], timeout: 0.1)
    }
    
}
