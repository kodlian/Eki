//
//  Operation.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
Chainable type
*/
public protocol Chainable {
    func chain( block:() -> Void) -> Chainable
    func chainOnQueue(queue:Queue, block:() -> Void) -> Chainable
    func chain(operation:Operation) -> Chainable
}

/**
A dispatch operation is defined by a queue and a block
*/
public struct Operation:Chainable {
    public let queue:Queue
    public let block:() -> Void
    
    public init(queue:Queue = Queue.Background, block:() -> Void) {
        self.queue = queue
        self.block = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
    }
    private init(queue:Queue = Queue.Background, dispatchBlock:() -> Void) {
        self.queue = queue
        self.block = dispatchBlock
    }
    
    //MARK: - Dispatch
    public func async() {
        queue.async(block)
    }
    public func sync() {
        queue.sync(block)
    }
    public func cancel() {
        dispatch_block_cancel(block)
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
        return chainOnQueue(queue,dispatchBlock:dispatchBlock)
        
    }
    public func chain(operation:Operation) -> Chainable {
        return chainOnQueue(operation.queue, dispatchBlock:operation.block)
    }
  
}

//MARK: Operator
infix operator <> {associativity left precedence 140}
public func <> (c:Chainable, block:() -> Void) -> Chainable {
    return c.chain(block)
}
public func <> (c:Chainable, operation:Operation) -> Chainable {
    return c.chain(operation)
}