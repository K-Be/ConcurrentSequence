//
//  RAVConcurrentContainersTests.swift
//  RAVConcurrentContainersTests
//
//  Created by Andrew Romanov on 12.10.2019.
//  Copyright © 2019 Andrew Romanov. All rights reserved.
//

import XCTest
@testable import RAVConcurrentContainers

class RAVConcurrentContainersTests: XCTestCase {
    //	func forEach(_ body: @escaping (Element) -> Void)
    //		func map<T>(_ transform: @escaping (Element) -> T) -> [T]
    //		func compactMap<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult?) -> [ElementOfResult]
    //		func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element]
    //		func first(where predicate: @escaping (Element) -> Bool) -> Element?
    //		func contains(where predicate: @escaping (Element) -> Bool) -> Bool
    //		 /// Returns a Boolean value indicating whether every element of a sequence
    //		 /// satisfies a given predicate.
    //		func allSatisfy(_ predicate: @escaping (Element) -> Bool) -> Bool
    //	}
    //
    //
    //	public extension ConcurrentSequenceP where Self.Element : Equatable {
    //		func elementsEqual<OtherSequence>(_ other: OtherSequence,	by areEquivalent: @escaping (Element, OtherSequence.Element) -> Bool) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element
    func checkForEach<T: ConcurrentSequenceP>(_ concurrentSequence: T, onQueue queue: OperationQueue) -> Bool  where T.Element : Any {
        let lock = Lock()
        var concurrentCounter = 0;
        concurrentSequence.forEach { (_ : Any) in
            XCTAssertEqual(OperationQueue.current, queue)
            Thread.sleep(forTimeInterval: 0.01)
            lock.sync {
                concurrentCounter += 1
            }
        }
        
        let array = Array(concurrentSequence);
        let normalCounter = array.count;
        
        XCTAssert(normalCounter == concurrentCounter)
        return normalCounter == concurrentCounter
    }
    
    
    func testForEachArray() {
        var values = Array<DataItem>()
        let count = 1000
        values.reserveCapacity(count)
        for i in 0..<count {
            values.append(DataItem(value: i))
        }
        let queue = OperationQueue()
        let concurrentContainer = values.concurrent(onQueue: queue)
        XCTAssert(checkForEach(concurrentContainer, onQueue: queue))
    }
    
    func testForEachSet() {
        let count = 1000
        let values = Set<DataItem>((0..<count).map({ (i) -> DataItem in
            return DataItem(value:i)
        }))
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        let concurrentContainer = values.concurrent(onQueue: queue)
        XCTAssert(checkForEach(concurrentContainer, onQueue: queue))
    }
    
    
    func testForEachDict() {
        let count = 1000
        let values = Dictionary<Int, DataItem>(uniqueKeysWithValues: (0..<count).map({ (i) -> (Int, DataItem) in
            return (i, DataItem(value: i))
        }))
        let lock = Lock()
        var countIterated = 0
        values.concurrent.forEach { (item) in
            let (_, _) = item
            Thread.sleep(forTimeInterval: 0.01);
            lock.sync {
                countIterated += 1
            }
        }
        XCTAssert(countIterated == count)
    }
    
    
    func testForEachString() {
        let string = "qwertyuiopasdfghjklzxcvbnm,."
        let queue = OperationQueue()
        XCTAssert(checkForEach(string.concurrent(onQueue: queue), onQueue: queue))
    }
}
