//
//  ConcurrentSequenceP.swift
//  RAVConcurrentContainers
//
//  Created by Andrew Romanov on 12.01.2020.
//  Copyright © 2020 Andrew Romanov. All rights reserved.
//

import Foundation


public protocol  ConcurrentSequenceP : Sequence {
    func forEach(_ body: @escaping (Element) -> Void)
    func map<T>(_ transform: @escaping (Element) -> T) -> [T]
    func compactMap<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult?) -> [ElementOfResult]
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element]
    func first(where predicate: @escaping (Element) -> Bool) -> Element?
    func contains(where predicate: @escaping (Element) -> Bool) -> Bool
    /// Returns a Boolean value indicating whether every element of a sequence
    /// satisfies a given predicate.
    func allSatisfy(_ predicate: @escaping (Element) -> Bool) -> Bool
}


public extension ConcurrentSequenceP where Self.Element : Equatable {
    func elementsEqual<OtherSequence>(_ other: OtherSequence,	by areEquivalent: @escaping (Element, OtherSequence.Element) -> Bool) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return false
    }
}

public protocol ElementBasedType {
    associatedtype Element
}

public protocol ConcurrentEnumerators : ElementBasedType {
    func forEach(_ body: @escaping (Element) -> Void)
    func forEach(_ body: @escaping (_ element:Element, _ stop: inout Bool) -> Void)
    func forEach<OtherSequence>(withOther other: OtherSequence, _ body: @escaping (_ selfElement: Element?, _ otherElement: OtherSequence.Element?, _ stop: inout Bool) -> Void) -> Void where OtherSequence : Sequence
}


public extension ConcurrentSequenceP where Self.Element : Equatable, Self : ConcurrentEnumerators {
    func elementsEqual<OtherSequence>(_ other: OtherSequence,	by areEquivalent: @escaping (Element, OtherSequence.Element) -> Bool) -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        
        var equal = true
        
        self.forEach(withOther: other) { (selfElement, otherElement, stop) in
            if let selfElement = selfElement, let otherElement = otherElement {
                equal = selfElement == otherElement
                if !equal {
                    equal = false
                    stop = true
                }
            }
            else {
                equal = false
                stop = true
            }
        }
        
        return equal;
    }
}


public extension ConcurrentSequenceP where Self : ConcurrentEnumerators {
    
    func map<T>(_ transform: @escaping (Element) -> T) -> [T] {
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
    
    
    func compactMap<ElementOfResult>(_ transform: @escaping (Element) -> ElementOfResult?) -> [ElementOfResult] {
        var result = Array<ElementOfResult>()
        let lock = Lock()
        self.forEach { (element:Element) in
            guard let transformedElement = transform(element) else {
                return
            }
            lock.sync {
                result.append(transformedElement)
            }
        }
        return result;
    }
    
    
    func filter(_ isIncluded: @escaping (Element) -> Bool) -> [Element] {
        var resultElements = Array<Self.Element>()
        let lock = Lock()
        self.forEach { (element:Element) in
            let good = isIncluded(element)
            if good {
                lock.sync {
                    resultElements.append(element)
                }
            }
        }
        
        return resultElements
    }
    
    
    func contains(where predicate: @escaping (Element) -> Bool) -> Bool {
        var contain = false
        let lock = Lock()
        self.forEach { (element:Element, stop: inout Bool) in
            guard !contain else {
                stop = true
                return
            }
            
            let satisfying = predicate(element);
            lock.sync {
                if !contain {
                    contain = satisfying
                }
            }
        }
        
        return contain
    }
    
    /// Returns a Boolean value indicating whether every element of a sequence
    /// satisfies a given predicate.
    func allSatisfy(_ predicate: @escaping (Element) -> Bool) -> Bool {
        let someNotSatisfy = self.contains { (element) -> Bool in
            let notSat = !predicate(element)
            return notSat
        }
        let allSatisfy = !someNotSatisfy
        return allSatisfy
    }
}



public protocol Enumerated: Sequence {
    func enumerated() -> EnumeratedSequence<Self>
}


public extension ConcurrentSequenceP where Self:Enumerated {
    func first(where predicate: @escaping (Self.Element) -> Bool) -> Self.Element? {
        var goodResults = Array<EnumeratedSequence<Array<Self.Element> >.Element>();
        let lock = Lock();
        self.enumerated().concurrent.forEach { (numericElement, stop: inout Bool) in
            let (_, element) : (Int, Self.Element) = numericElement;
            let good = predicate(element)
            if good {
                lock.sync {
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


