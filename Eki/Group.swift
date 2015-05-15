//
//  Group.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
@abstract
A wrapper for Grand Central Dispatch Group
*/
public struct Group {
    private var group = dispatch_group_create();
    public var defaultQueue:Queue = Queue.Background {
        didSet {
            defaultDispatchQueue = defaultQueue.dispatchQueue()
        }
    }
    private var defaultDispatchQueue = Queue.Background.dispatchQueue()
    
    
    init(defaultQueue:Queue = Queue.Background) {
        self.defaultQueue = defaultQueue
    }
    

    //MARK: Dispatch
    public func dispatch(block:() -> Void)  -> Group {
        dispatchOnQueue(nil,block:block)
        return self
    }
    public func dispatchOnQueue(queue:Queue?,block:() -> Void )  -> Group {
        dispatch_group_async(group,  queue?.dispatchQueue() ?? defaultDispatchQueue, block)
        return self
    }
    public func dispatchOperation(operation:Operation)  -> Group {
        dispatchOnQueue(operation.queue, block:operation.block)
        return self
    }
    public func dispatch(blocks:[() -> Void]) -> Group {
        dispatchOnQueue(nil,blocks:blocks)
        return self
    }
    public func dispatchOnQueue(queue:Queue?, blocks:[() -> Void]) -> Group {
        for block in blocks {
            dispatchOnQueue(queue,block:block)
        }
        return self
    }
    public func dispatchOperations(operations:[Operation]) -> Group {
        for operation in operations {
            dispatchOperation(operation)
        }
        return self
    }
    
    //MARK: Others
    public func notifyCompletion(block:() -> Void) -> Group {
        return notifyCompletionOnQueue(defaultQueue,block: block)
    }
    public func notifyCompletionOnQueue(queue:Queue, block:() -> Void) -> Group {
        dispatch_group_notify(group,queue.dispatchQueue(), block);
        return self
    }
    public func wait(time:NSTimeInterval? = nil) -> Group {
        dispatch_group_wait(group, dispatch_time_t(timeInterval: time));
        return self
    }
}