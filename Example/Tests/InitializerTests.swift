//
//  CancellablePromiseTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 12.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class InitializerTests: XCTestCase {
    
    var testPromise: CancellablePromise<String>!

    override func tearDown() {
        super.tearDown()
        testPromise = nil
    }
    
    func testCancelFunc() {
        let expectation = self.expectation(description: "Cancel function was not called")
        
        let promise = Promise<String>.pending().promise
        func cancelFunc() {
            expectation.fulfill()
        }
        testPromise = CancellablePromise(using: promise, cancel: cancelFunc)
        testPromise.cancel()
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testCancelPromise() {
        let rejectionExpectation = expectation(description: "Cancel promise was not rejected")
        let fulfillmentExpectation = expectation(description: "CancelPromise was fulfilled")
        fulfillmentExpectation.isInverted = true

        testPromise = CancellablePromise { (cancelPromise) -> Promise<String> in
            cancelPromise.done {
                fulfillmentExpectation.fulfill()
            }.catch(policy: .allErrors) { (error) in
                rejectionExpectation.fulfill()
            }
            return Promise<String>.pending().promise
        }
        testPromise.cancel()
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }

    func testDeinitPromise() {
        let rejectionExpectation = expectation(description: "Cancel promise was rejected")
        rejectionExpectation.isInverted = true
        let fulfillmentExpectation = expectation(description: "CancelPromise was not fulfilled")
        
        testPromise = CancellablePromise { (cancelPromise) -> Promise<String> in
            cancelPromise.done {
                fulfillmentExpectation.fulfill()
            }.catch(policy: .allErrors) { (error) in
                rejectionExpectation.fulfill()
            }
            return Promise<String>.pending().promise
        }
        testPromise = nil
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
}
