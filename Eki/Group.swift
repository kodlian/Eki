//
//  Group.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
A wrapper for Grand Central Dispatch Group
*/
public struct Group {
    private var group = dispatch_group_create()
    public var queue:Queue = Queue.UserInitiated {
        didSet {
            defaultDispatchQueue = queue.dispatchQueue()
        }
    }
    private var defaultDispatchQueue = Queue.Background.dispatchQueue()
  
    init(queue:Queue = Queue.Background) {
        self.queue = queue
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
    public func async(task:Task)  -> Group {
        asyncOnQueue(task.queue, block:task.block)
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
    public func async(tasks:[Task]) -> Group {
        for task in tasks {
            async(task)
        }
        return self
    }
    
    //MARK: Others
    public func notify(block:() -> Void) -> Group {
        return notifyOnQueue(queue, dispatchBlock: block)
    }
    public func notify(task:Task) -> Group {
        return notifyOnQueue(queue,dispatchBlock: task.block)
    }
    public func notifyOnQueue(queue:Queue, block:() -> Void) -> Group {
        return notifyOnQueue(queue, dispatchBlock: block)
    }
    private func notifyOnQueue(queue:Queue, dispatchBlock:dispatch_block_t) -> Group {
        dispatch_group_notify(group,queue.dispatchQueue(), dispatchBlock)
        return self
    }
    public func wait(time:NSTimeInterval? = nil) -> Group {
        dispatch_group_wait(group, dispatch_time_t(timeInterval: time))
        return self
    }
}

//MARK: Operator
public func <<< (g:Group,block:() -> Void) -> Group {
    return g.async(block)
}
public func <<< (g:Group,task:Task) -> Group {
    return g.async(task)
}
public func <<< (g:Group,blocks:[() -> Void]) -> Group {
    return g.async(blocks)
}
public func <<< (g:Group,tasks:[Task]) -> Group {
    return g.async(tasks)
}