//
//  ConcurrentSequence.swift
//  RAVConcurrentContainers
//
//  Created by Andrew Romanov on 12.10.2019.
//  Copyright © 2019 Andrew Romanov. All rights reserved.
//

import Foundation


public struct ConcurrentSequence <Seq : Sequence> : ConcurrentSequenceP, Enumerated, ConcurrentEnumerators {
    
    public typealias Element = Seq.Element
    public typealias Iterator = Seq.Iterator
    
    private var storage : Seq;
    private var queue : OperationQueue
    
    public init(withSequence sequence: Seq, onQueue queue: OperationQueue = OperationQueue())
    {
        self.storage = sequence
        self.queue = queue
    }
    
    public __consuming func makeIterator() -> Seq.Iterator {
        let iterator = self.storage.makeIterator()
        return iterator
    }
    
    public func forEach(_ body: @escaping (Seq.Element) -> Void) {
        for item in self.storage {
            queue.addOperation {
                body(item)
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    public func forEach(_ body: @escaping (_ element:Seq.Element, _ stop: inout Bool) -> Void) {
        var stop = false;
        for item in self.storage {
            queue.addOperation {
                var localStop = false;
                if !stop {
                    body(item, &localStop);
                }
                
                if localStop && !stop
                {
                    stop = localStop;
                    self.queue.cancelAllOperations();
                }
            }
            if stop {
                break;
            }
        }
        queue.waitUntilAllOperationsAreFinished()
    }
    
    public func forEach<OtherSequence>(withOther other: OtherSequence, _ body: @escaping (_ selfElement: Seq.Element?, _ otherElement: OtherSequence.Element?, _ stop: inout Bool) -> Void) -> Void where OtherSequence : Sequence {
        var stop = false
        let lock = Lock()
        
        var selfIterator = self.makeIterator()
        var otherIterator = other.makeIterator()
        
        var selfItem = selfIterator.next()
        var otherItem = otherIterator.next()
        while  (selfItem != nil || otherItem != nil) && !stop  {
            queue.addOperation {
                var localStop = false;
                if !stop {
                    body(selfItem, otherItem, &localStop);
                }
                
                if localStop && !stop {
                    lock.sync {
                        stop = localStop
                        self.queue.cancelAllOperations()
                    }
                }
            }
            
            selfItem = selfIterator.next()
            otherItem = otherIterator.next()
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    public func enumerated() -> EnumeratedSequence <Seq> {
        return self.storage.enumerated()
    }
}


public extension Sequence {
    var concurrent : ConcurrentSequence<Self> {
        get {
            return ConcurrentSequence(withSequence: self)
        }
    }
    
    func concurrent(onQueue queue: OperationQueue) -> ConcurrentSequence<Self> {
        return ConcurrentSequence(withSequence: self, onQueue: queue)
    }
}
