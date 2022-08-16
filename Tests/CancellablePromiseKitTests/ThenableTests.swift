//
//  CancellablePromiseUsageTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 18.05.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class ThenableTests: XCTestCase {
    
    var testPromise: CancellablePromise<String>!
    var testResolver: Resolver<String>!
    
    override func setUp() {
        super.setUp()
        let (basePromise, resolver) = Promise<String>.pending()
        testPromise = CancellablePromise(using: basePromise, cancel: { resolver.reject(CancellablePromiseError.cancelled) })
        testResolver = resolver
    }
    
    override func tearDown() {
        super.tearDown()
        testPromise = nil
        testResolver = nil
    }
    
    func testFulfill() {
        let rejectionExpectation = expectation(description: "Promise was rejected")
        rejectionExpectation.isInverted = true
        let fulfillmentExpectation = expectation(description: "Promise was not fulfilled")
        
        testPromise.done { _ in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            rejectionExpectation.fulfill()
        }
        
        testResolver.fulfill("")
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
    func testCancel() {
        let rejectionExpectation = expectation(description: "Promise was not rejected")
        let fulfillmentExpectation = expectation(description: "Promise was fulfilled")
        fulfillmentExpectation.isInverted = true
        
        testPromise.done { _ in
            fulfillmentExpectation.fulfill()
        }.catch(policy: .allErrors) { (error) in
            switch error {
            case CancellablePromiseError.cancelled:
                rejectionExpectation.fulfill()
            default:
                break
            }
        }
        
        testPromise.cancel()
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
    func testReject() {
        let rejectionExpectation = expectation(description: "Promise was not rejected")
        let fulfillmentExpectation = expectation(description: "Promise was fulfilled")
        fulfillmentExpectation.isInverted = true
        
        testPromise.done { _ in
            fulfillmentExpectation.fulfill()
        }.catch { (error) in
            rejectionExpectation.fulfill()
        }
        
        class TestError: Error { }
        testResolver.reject(TestError())
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
}
