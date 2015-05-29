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
    public func chain(task:Task) -> Chainable {
        dispatch_block_notify(self.dispatchBlock, task.queue.dispatchQueue, task.dispatchBlock)
        return task
    }
    public func chain(block:() -> Void) -> Chainable {
        let task = Task(queue: queue, block: block)
        return chain(task)
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
