//
//  RAVConcurrentContainersMapTests.swift
//  RAVConcurrentContaintersTests
//
//  Created by Andrew Romanov on 19.01.2020.
//  Copyright © 2020 Andrew Romanov. All rights reserved.
//

import XCTest
@testable import RAVConcurrentContainters

class RAVConcurrentContainersMapTests: XCTestCase {

	func checkMap<T: ConcurrentSequenceP, S: Collection>(on collection:T, withSource source: S) -> Bool where T.Element == Int, S.Element == T.Element {
		
		let transformed = collection.map { (i:Int) -> Int in
			return i + 1
		}
		
		let minVal = source.min()!
		let transformedMinVal = transformed.min()!
		
		XCTAssert(transformed.count == source.count)
		XCTAssert(minVal == transformedMinVal - 1)
		
		return transformed.count == source.count
	}
	
	func testArray() {
		let values = Array<Int>(0..<1000)
		XCTAssertTrue(checkMap(on: values.concurrent, withSource: values))
	}
	
	func testSet() {
		let values = Set<Int>(0..<1000)
		XCTAssertTrue(checkMap(on: values.concurrent, withSource: values))
	}
	
	func testDict() {
		let dict = Dictionary<Int, DataItem>(uniqueKeysWithValues: (0..<1000).map({ (i) -> (Int, DataItem) in
			return (i, DataItem(value:i))
		}))
		
		let transformed = dict.map { (item) -> Int in
			let (key, _) = item;
			return key + 1
		}
		let transformedConcurrent = dict.concurrent.map { (item) -> Int in
			let (key, _) = item;
			return key + 1
		}
		
		transformed.forEach { (value) in
			XCTAssert(transformedConcurrent.contains(value))
		}
	}

}
