//
//  WhenTests.swift
//  CancellablePromiseKit
//
//  Created by Johannes Dörr on 13.05.18.
//  Copyright © 2018 Johannes Dörr. All rights reserved.
//

import XCTest
import PromiseKit
import CancellablePromiseKit

class WhenTests: XCTestCase {
    
    var testPromise: (promise: Promise<String>, resolver: Resolver<String>)!
    
    class Error: Swift.Error { }
    
    override func setUp() {
        super.setUp()
        testPromise = Promise<String>.pending()
    }
    
    override func tearDown() {
        super.tearDown()
        testPromise = nil
    }
    
    func testFulfilled() {
        let expectation = self.expectation(description: "Promise was not fulfilled")
        
        let (conditionPromise, _) = Promise<Void>.pending()
        let testValue = "test"
        _ = when(testPromise.promise, while: conditionPromise).done { value in
            if value == testValue {
                expectation.fulfill()
            }
        }
        testPromise.resolver.fulfill(testValue)
        
        wait(for: [expectation], timeout: 0.1)
    }

    func testFulfilledAndConditionFulfilled() {
        let expectation = self.expectation(description: "Promise was not fulfilled")
        
        let (conditionPromise, conditionResolver) = Promise<Void>.pending()
        let testValue = "test"
        _ = when(testPromise.promise, while: conditionPromise).done { value in
            if value == testValue {
                expectation.fulfill()
            }
        }
        conditionResolver.fulfill(Void())
        testPromise.resolver.fulfill(testValue)
        
        wait(for: [expectation], timeout: 0.1)
    }

    func testConditionRejected() {
        let expectation = self.expectation(description: "Promise was fulfilled")
        expectation.isInverted = true
        
        let (conditionPromise, conditionResolver) = Promise<Void>.pending()
        let testValue = "test"
        _ = when(testPromise.promise, while: conditionPromise).done { value in
            if value == testValue {
                expectation.fulfill()
            }
        }
        conditionResolver.reject(Error())
        testPromise.resolver.fulfill(testValue)
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func testConditionRejectedAfterFulfilled() {
        let expectation = self.expectation(description: "Promise was not fulfilled")
        
        let (conditionPromise, conditionResolver) = Promise<Void>.pending()
        let testValue = "test"
        _ = when(testPromise.promise, while: conditionPromise).done { value in
            if value == testValue {
                expectation.fulfill()
            }
        }
        testPromise.resolver.fulfill(testValue)
        conditionResolver.reject(Error())
        
        wait(for: [expectation], timeout: 0.1)
    }
    
}
