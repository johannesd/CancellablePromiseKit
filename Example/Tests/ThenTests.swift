//
//  ThenTests.swift
//  CancellablePromiseKit_Tests
//
//  Created by Johannes Dörr on 18.05.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class ThenTests: XCTestCase {
    
    var testPromise1: CancellablePromise<String>!
    var testResolver1: Resolver<String>!
    var testPromise2: CancellablePromise<String>!
    var testResolver2: Resolver<String>!
    var thenPromise: CancellablePromise<String>!
    
    override func setUp() {
        super.setUp()
        let (basePromise1, resolver1) = Promise<String>.pending()
        testPromise1 = CancellablePromise(using: basePromise1, cancel: { resolver1.reject(CancellablePromiseError.cancelled) })
        testResolver1 = resolver1
        let (basePromise2, resolver2) = Promise<String>.pending()
        testPromise2 = CancellablePromise(using: basePromise2, cancel: { resolver2.reject(CancellablePromiseError.cancelled) })
        testResolver2 = resolver2
        thenPromise = testPromise1.then { value in
            return self.testPromise2
        }
    }
    
    override func tearDown() {
        super.tearDown()
        testPromise1 = nil
        testResolver1 = nil
        testPromise2 = nil
        testResolver2 = nil
        thenPromise = nil
    }
    
    func testFulfill() {
        let rejectionExpectation = expectation(description: "Promise was rejected")
        rejectionExpectation.isInverted = true
        let fulfillmentExpectation = expectation(description: "Promise was not fulfilled")
        
        thenPromise.done { _ in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            rejectionExpectation.fulfill()
        }
        
        testResolver1.fulfill("")
        testResolver2.fulfill("")
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
    func testCancelFirst() {
        let cancellationExpectation = expectation(description: "Promises were not cancelled")
        let fulfillmentExpectation = expectation(description: "Promise was fulfilled")
        fulfillmentExpectation.isInverted = true
        
        thenPromise.done { _ in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            if self.testPromise1.isCancelled && self.thenPromise.isCancelled {
                cancellationExpectation.fulfill()
            }
        }
        
        thenPromise.cancel()
        
        wait(for: [cancellationExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
    func testCancelSecond() {
        let cancellationExpectation = expectation(description: "Promises were not cancelled")
        let fulfillmentExpectation = expectation(description: "Promise was fulfilled")
        fulfillmentExpectation.isInverted = true
        
        thenPromise.done { value in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            if self.testPromise1.isCancelled && self.testPromise2.isCancelled && self.thenPromise.isCancelled {
                cancellationExpectation.fulfill()
            }
        }
        testResolver1.fulfill("")
        thenPromise.cancel()
        
        wait(for: [cancellationExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
    func testCancelSecondWithDelay() {
        let cancellationExpectation = expectation(description: "Promises were not cancelled")
        let fulfillmentExpectation = expectation(description: "Promise was fulfilled")
        fulfillmentExpectation.isInverted = true
        
        thenPromise.done { value in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            if self.testPromise1.isCancelled && self.testPromise2.isCancelled && self.thenPromise.isCancelled {
                cancellationExpectation.fulfill()
            }
        }
        testResolver1.fulfill("")
        DispatchQueue.main.async {
            self.thenPromise.cancel()
        }
        
        wait(for: [cancellationExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
}
