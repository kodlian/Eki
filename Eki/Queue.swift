//
//  Dispatch.swift
//  Montparnasse
//
//  Created by Jérémy Marchand on 15/10/14.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
@abstract
A wrapper for Grand Central Dispatch Queue
*/
public enum Queue {
    
    
    //MARK: cases
    case Main
    case UserInteractive
    case UserInitiated
    case Default
    case Utility
    case Background
    case Custom(queue:dispatch_queue_t)
    
    //MARK: type
    /**
    @abstract
    Customn queue type
    */
    public enum CustomType {
        case Concurrent, Serial
        
        func createDispatchQueueWithName(name:String) -> dispatch_queue_t {
            var type:dispatch_queue_attr_t!
            
            switch self {
            case .Concurrent:
                type = DISPATCH_QUEUE_CONCURRENT
            case .Serial:
                type = DISPATCH_QUEUE_SERIAL
            }
            
           return dispatch_queue_create(name,type)
        }
    }
    

    //MARK: init
    public init(name:String, type:CustomType){
         self = .Custom(queue: type.createDispatchQueueWithName(name))
    }
    
    //MARK: Dispatch single block
    public func dispatchBlock(block:() -> ()) -> Queue{
        dispatch_async(dispatchQueue(), block)
        return self
    }
    
    public func dispatchBlock(block:() -> (), wait:Bool) -> Queue {
        let q = dispatchQueue()
        if wait == true {
            dispatch_sync(q, block) // prevent deadlock
        }
        else {
            dispatch_async(q, block)
        }
        return self
    }
    public func dispatchAfter(delay:NSTimeInterval, block:() -> ()) -> Queue {
        dispatch_after(dispatch_time_t(delay) * dispatch_time_t(NSEC_PER_SEC), dispatchQueue(), block)
        return self
    }

    public func dispatchWithBarrierBlock(block:() -> (), wait:Bool = false) -> Queue {
        let q = dispatchQueue()
        if wait == true {
            dispatch_barrier_sync(q, block) // prevent deadlock
        }
        else {
            dispatch_barrier_async(q, block)
        }
        return self
    }

    
    //MARK: Dispatch multiple blocks
    public func dispatchBlocks(blocks:[() -> ()])  {
        dispatchBlocks(blocks, wait:false)
    }
    
    public func dispatchBlocks(blocks:[() -> ()], wait:Bool){
        let group = Group();
        assert(blocks.count > 0,"Must have somnething to perform")

        for block in blocks {
            group.dispatchOnQueue(self, block:  block)
        }
        if wait == true {
            group.wait()
        }
    }


    //MARK: Others
    public func applyIteration(iteration:UInt, toBlock block:(i:UInt) -> ()) {
        dispatch_apply(iteration, dispatchQueue(),block);
    }

    internal func dispatchQueue() -> dispatch_queue_t {
        switch (self) {
        case .Main:
            return dispatch_get_main_queue()
        case .UserInteractive:
            return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0)
        case .UserInitiated:
            return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)
        case .Default:
            return dispatch_get_global_queue(Int(QOS_CLASS_DEFAULT.value), 0)
        case .Utility:
            return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.value), 0)
        case .Background:
            return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.value), 0)
        case .Custom(let queue):
            return queue
        }
        
    }
    
}








