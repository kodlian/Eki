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
    internal var group = dispatch_group_create();
    
    //MARK: Dispatch blocks
    public func dispatchOnQueue(queue:Queue, block:() -> ())  -> Group {
        dispatch_group_async(group,queue.dispatchQueue(), block)
        return self
    }
    public func dispatchOperation(operation:Operation)  -> Group {
        dispatchOnQueue(operation.queue, block:operation.block)
        return self
    }
    func dispatchOperations(operations:[Operation]) -> Group {
        for operation in operations {
            dispatchOperation(operation)
        }
        return self
    }
    
    //MARK: Others
    public func notifyCompletionOnQueue(queue:Queue,  andBlock block:() -> ()) -> Group {
        dispatch_group_notify(group,queue.dispatchQueue(), block);
        
        return self
    }
    
    public func wait() {
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
}