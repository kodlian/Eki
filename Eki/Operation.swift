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
Chainable type
*/
public protocol Chainable {
    func chain( block:() -> Void) -> Chainable
    func chainOnQueue(queue:Queue, block:() -> Void) -> Chainable
    func chainOperation(operation:Operation) -> Chainable
}

/**
@abstract
A dispatch operation is defined by a queue and a block
*/
public struct Operation:Chainable {
    public let queue:Queue
    public let block:() -> Void
    
    public init(queue:Queue,block:() -> Void) {
        self.queue = queue
        self.block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
    }
    private init(queue:Queue,dispatchBlock:() -> Void) {
        self.queue = queue
        self.block = dispatchBlock
    }
    
    //MARK: - Dispatch
    public func dispatch() {
        queue.dispatch(block)
    }
    public func dispatchByWaiting(wait:Bool) {
        queue.dispatch(block, wait:wait)
    }
    
    //MARK: - Chain
    private func chainOnQueue(queue:Queue, dispatchBlock:() -> Void) -> Chainable{
        dispatch_block_notify(self.block, queue.dispatchQueue(), dispatchBlock)
        return Operation(queue:queue,dispatchBlock: block)
    }
    public func chain( block:() -> Void) -> Chainable{
        return chainOnQueue(self.queue,block:block)
    }
    public func chainOnQueue(queue:Queue, block:() -> Void) -> Chainable{
        let dispatchBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
        return chainOnQueue(self.queue,dispatchBlock:dispatchBlock)
        
    }
    public func chainOperation(operation:Operation) -> Chainable {
        return chainOnQueue(self.queue,dispatchBlock:operation.block)
    }
  
}



