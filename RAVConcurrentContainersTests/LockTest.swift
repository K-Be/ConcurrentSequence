//
//  LockTest.swift
//  RAVConcurrentContainersTests
//
//  Created by Andrew Romanov on 21.07.2020.
//  Copyright © 2020 Andrew Romanov. All rights reserved.
//

import XCTest
@testable import RAVConcurrentContainers

class LockTest: XCTestCase {

    func testLock() throws {
        let lock = Lock()
        let operationQueue = OperationQueue()
        var val = 0
        let numberOfOperations = 1000
        
        for _ in 1...numberOfOperations {
            operationQueue.addOperation {
                lock.sync {
                    val += 1
                }
            }
        }
        operationQueue.waitUntilAllOperationsAreFinished()
        XCTAssertEqual(val, numberOfOperations)
    }
}
