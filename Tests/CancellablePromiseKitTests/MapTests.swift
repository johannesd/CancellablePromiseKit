//
//  MapTests.swift
//  CancellablePromiseKit_Tests
//
//  Created by Johannes Dörr on 04.07.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class MapTests: XCTestCase {

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

    func testMap() {
        let expectation = self.expectation(description: "Value was not mapped correctly")
        let testValue = "test"
        
        _ = testPromise.map({ (value) -> String in
            return value + value
        }).done { (mappedValue) in
            if mappedValue == testValue + testValue {
                expectation.fulfill()
            }
        }
        
        testResolver.fulfill(testValue)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testCancel() {
        let rejectionExpectation = expectation(description: "Cancel promise was not rejected")
        let fulfillmentExpectation = expectation(description: "CancelPromise was fulfilled")
        fulfillmentExpectation.isInverted = true

        _ = testPromise.map({ (value) -> String in
            return value + value
        }).done({ (mappedValue) in
            fulfillmentExpectation.fulfill()
        }).catch(policy: .allErrors) { (error) in
            rejectionExpectation.fulfill()
        }
        
        testPromise.cancel()
        
        wait(for: [rejectionExpectation, fulfillmentExpectation], timeout: 0.1)
    }
    
}
