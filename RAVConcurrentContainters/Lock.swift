//
//  Lock.swift
//  RAVConcurrentContainters
//
//  Created by Andrew Romanov on 12.10.2019.
//  Copyright © 2019 Andrew Romanov. All rights reserved.
//

import Foundation


class Lock {
    func lock() {
        self.lockObj.lock()
    }
    
    func unlock() {
        self.lockObj.unlock()
    }
    
    
    func sync(_ block : ()->Void){
        self.lock()
        block()
        self.unlock()
    }
    
    private var lockObj = NSLock()
}

