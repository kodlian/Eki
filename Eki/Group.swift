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
public class Group {
    private var group = dispatch_group_create()
    public var queue:Queue = Queue.UserInitiated
  
    public init(queue:Queue = Queue.Background) {
        self.queue = queue
    }

    public convenience init(tasks:[Task]) {
        self.init()
        async(tasks)
    }
    
    //MARK: Dispatch
    public func async(block:() -> Void)  -> Group {
        return async(queue + block)
    }
    public func async(task:Task)  -> Group {
        dispatch_group_async(group,  task.queue.dispatchQueue, task.dispatchBlock)
        return self
    }
  
    public func async(blocks:[() -> Void]) -> Group {
        async(blocks.map{ self.queue + $0 })
        return self
    }
    public func async(tasks:[Task]) -> Group {
        for task in tasks {
            async(task)
        }
        return self
    }
    
    //MARK: - Manually
    public func enter() {
        dispatch_group_enter(group)
    }
    public func leave() {
        dispatch_group_leave(group)
    }
    
    //MARK: Others
    public func notify(block:() -> Void) -> Group {
        return notify(queue + block)
    }
    public func notify(task:Task) -> Group {
        dispatch_group_notify(group,task.queue.dispatchQueue, task.dispatchBlock)
        return self
    }

    public func wait(time:NSTimeInterval? = nil) -> Bool {
        return dispatch_group_wait(group, dispatch_time_t(timeInterval: time)) == 0
    }
    
    
}

// MARK: Equatable
extension Group: Equatable { }
public func ==(lhs: Group, rhs: Group) -> Bool {
    return lhs.group == rhs.group
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
public postfix func ++ (group: Group) {
    group.enter()
}
public postfix func -- (group: Group) {
    group.leave()
}
