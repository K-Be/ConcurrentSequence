//
//  RAVConcurrentContaintersTests.swift
//  RAVConcurrentContaintersTests
//
//  Created by Andrew Romanov on 12.10.2019.
//  Copyright © 2019 Andrew Romanov. All rights reserved.
//

import XCTest
@testable import RAVConcurrentContainters

class RAVConcurrentContaintersTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForEach() {
        let values = Array<Int>(0...1000)
        
        values.concurrent.forEach { (val:Int) in
            print("val: \(val)")
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
