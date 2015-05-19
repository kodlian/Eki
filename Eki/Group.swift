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
    public func async(block:() -> Void)  -> Group {
        asyncOnQueue(nil,block:block)
        return self
    }
    public func asyncOnQueue(queue:Queue?,block:() -> Void )  -> Group {
        dispatch_group_async(group,  queue?.dispatchQueue() ?? defaultDispatchQueue, block)
        return self
    }
    public func async(operation:Operation)  -> Group {
        asyncOnQueue(operation.queue, block:operation.block)
        return self
    }
    public func async(blocks:[() -> Void]) -> Group {
        asynchOnQueue(nil,blocks:blocks)
        return self
    }
    public func asynchOnQueue(queue:Queue?, blocks:[() -> Void]) -> Group {
        for block in blocks {
            asyncOnQueue(queue,block:block)
        }
        return self
    }
    public func async(operations:[Operation]) -> Group {
        for operation in operations {
            async(operation)
        }
        return self
    }
    
    //MARK: Others
    public func notify(block:() -> Void) -> Group {
        return notifyOnQueue(defaultQueue,block: block)
    }
    public func notifyOnQueue(queue:Queue, block:() -> Void) -> Group {
        dispatch_group_notify(group,queue.dispatchQueue(), block);
        return self
    }
    public func wait(time:NSTimeInterval? = nil) -> Group {
        dispatch_group_wait(group, dispatch_time_t(timeInterval: time));
        return self
    }
}