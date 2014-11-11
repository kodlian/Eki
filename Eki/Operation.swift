//
//  Operation.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
@abstract
Define a dispatch operation
*/
public struct Operation {
    public var queue:Queue
    public var block:() -> Void
    
    public func dispatch() {
        queue.dispatchBlock(block)
    }
    public func dispatchByWaiting(wait:Bool) {
        queue.dispatchBlock(block, wait:wait)
    }
}

