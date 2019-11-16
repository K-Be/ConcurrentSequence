//
//  ConcurrentSequence.swift
//  RAVConcurrentContainters
//
//  Created by Andrew Romanov on 12.10.2019.
//  Copyright © 2019 Andrew Romanov. All rights reserved.
//

import Foundation


public struct ConcurrentSequence <Seq : Sequence> : Sequence {
       
    public typealias Element = Seq.Element
    public typealias Iterator = Seq.Iterator
    
    private var storage : Seq;
    private var qualityOfService : QualityOfService = .default
    
    public init(withSequence sequence: Seq)
    {
        storage = sequence
    }
    
    
    public init(withSequence sequence: Seq, qualityOfService:QualityOfService)
    {
        self.storage = sequence
        self.qualityOfService = qualityOfService
    }
    
    
    public __consuming func makeIterator() -> Seq.Iterator {
        let iter = self.storage.makeIterator()
        return iter
    }    
    
    
    public func forEach(_ body: @escaping (Seq.Element) -> Void) {
        let queue = OperationQueue()
        queue.qualityOfService = self.qualityOfService
        for item in self.storage {
            queue.addOperation {
                body(item)
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    public func map<T>(_ transform: @escaping (Seq.Element) -> T) -> [T] {
        var resultElements = Array<T>()
        let lock = Lock()
        self.forEach { (element) in
            let transformed = transform(element);
            lock.sync {
                resultElements.append(transformed)
            }
        }
        
        return resultElements
    }
    
    
    public func compactMap<ElementOfResult>(_ transform: @escaping (Seq.Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = Array<ElementOfResult>()
        let lock = Lock()
        self.forEach { (element:Seq.Element) in
            guard let transformedElement = transform(element) else {
                return
            }
            lock.sync {
                result.append(transformedElement)
            }
        }
        return result;
    }
    
    
    public func filter(_ isIncluded: @escaping (Self.Element) -> Bool) -> [Self.Element] {
        var resultElements = Array<Self.Element>()
        let lock = Lock()
        self.forEach { (element:Seq.Element) in
            let good = isIncluded(element)
            if good {
                lock.sync {
                    resultElements.append(element)
                }
            }
        }
        
        return resultElements
    }
    
    
    public func first(where predicate: @escaping (Self.Element) -> Bool) -> Self.Element? {
        var goodResults = Array<EnumeratedSequence<Array<Self.Element> >.Element>();
        let lock = Lock();
        self.storage.enumerated().concurrent.forEach { (numericElement) in
            let (_, element) : (Int, Self.Element) = numericElement;
            var emptyResults = true
            lock.sync {
                emptyResults = goodResults.isEmpty
            }
            if emptyResults {
                let good = predicate(element)
                if good {
                    goodResults.append(numericElement)
                }
            }
        }
        
        let result = goodResults.min { (numericElem1, numericElem2) -> Bool in
            let (index1, _) = numericElem1
            let (index2, _) = numericElem2
            let less = index1 < index2
            return less
        }
        return result?.element
    }
    
    
    
    
}


public extension Array {
    var concurrent : ConcurrentSequence<Self> {
        get {
            return ConcurrentSequence(withSequence: self)
        }
    }
}


public extension EnumeratedSequence {
    var concurrent : ConcurrentSequence<Self> {
        get {
            return ConcurrentSequence(withSequence: self);
        }
    }
}
