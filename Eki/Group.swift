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
public struct Group{
    private var group = dispatch_group_create();
    public var defaultQueue:Queue = Queue.Background {
        didSet {
            defaultDispatchQueue = defaultQueue.dispatchQueue()
        }
    }
    private var defaultDispatchQueue = Queue.Background.dispatchQueue()
    
    
    init(defaultQueue:Queue ) {
        self.defaultQueue = defaultQueue
    }
    

    //MARK: Dispatch blocks
    public func dispatch(block:() -> Void, onQueue queue:Queue? = nil)  -> Group {
        dispatch_group_async(group,queue?.dispatchQueue() ?? defaultDispatchQueue, block)
        return self
    }
    public func dispatchOperation(operation:Operation)  -> Group {
        dispatch(operation.block, onQueue:operation.queue)
        return self
    }
    public func dispatch(blocks:[() -> Void], onQueue queue:Queue? = nil) -> Group {
        for block in blocks {
            dispatch(block,onQueue:queue)
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
    public func notifyCompletionOnBlock(block:() -> Void, queue:Queue? = nil) -> Group {
        dispatch_group_notify(group,queue?.dispatchQueue() ?? defaultDispatchQueue, block);
        
        return self
    }
    
    public func wait() {
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
}
func test() {
   
    let g = Group(defaultQueue:Queue.Main).dispatch{ () -> Void in
        
    }
    
}