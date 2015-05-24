//
//  Task.swift
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
    func chain(block:() -> Void) -> Chainable
    func chain(task:Task) -> Chainable
}

/**
A task is defined by a queue and a block
*/
public class Task:Chainable {
    public let queue:Queue
    internal let dispatchBlock:dispatch_block_t
    public var block:() -> Void { return dispatchBlock }
    
    public init(queue:Queue = Queue.Background, block:() -> Void) {
        self.queue = queue
        self.dispatchBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
    }
    private init(queue:Queue = Queue.Background, dispatchBlock:dispatch_block_t) {
        self.queue = queue
        self.dispatchBlock = dispatchBlock
    }
    
    //MARK: - Dispatch
    public func async() -> Chainable {
        queue.async(dispatchBlock)
        return self
    }
    public func sync() -> Chainable{
        queue.sync(dispatchBlock)
        return self
    }
    public func cancel() {
        dispatch_block_cancel(dispatchBlock)
    }
    
    //MARK: - Chain
    private func chainOnQueue(queue:Queue, dispatchBlock block:dispatch_block_t) -> Chainable{

        dispatch_block_notify(self.dispatchBlock, queue.dispatchQueue(), block)
        return Task(queue:queue,dispatchBlock: block)
    }
    public func chain(task:Task) -> Chainable {
        return chainOnQueue(task.queue, dispatchBlock:task.dispatchBlock)
    }
    public func chain(block:() -> Void) -> Chainable {
        let dispatchBlock = dispatch_block_create(DISPATCH_BLOCK_INHERIT_QOS_CLASS, block)
        return chainOnQueue(self.queue,dispatchBlock:dispatchBlock)
    }
}

//MARK: Operator
infix operator <> {associativity left precedence 110}
public func <> (c:Chainable, block:() -> Void) -> Chainable {
    return c.chain(block)
}
public func <> (c:Chainable, task:Task) -> Chainable {
    return c.chain(task)
}

public func + (q:Queue, block:() -> Void) -> Task {
    return Task(queue: q, block: block)
}
