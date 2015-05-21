//
//  Dispatch.swift
//  Montparnasse
//
//  Created by Jérémy Marchand on 15/10/14.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
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
    public func async(block:() -> Void) -> Queue{
        dispatch_async(dispatchQueue(), block)
        return self
    }
    public func sync(block:() -> Void) -> Queue {
        dispatch_sync(dispatchQueue(), block) //TODO: prevent deadlock
        return self
    }
    public func after(delay:NSTimeInterval, doBlock block:() -> Void) -> Queue {
        dispatch_after(  dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay.nanosecondsRepresentation)
            ), dispatchQueue(), block)
        return self
    }
    public func barrierAsync(block:() -> Void) -> Queue {
        dispatch_barrier_async(dispatchQueue(), block)
        return self
    }
    public func barrierSync(block:() -> Void, wait:Bool) -> Queue {
        let q = dispatchQueue()
        if wait == true {
            dispatch_barrier_sync(q, block) //TODO: prevent deadlock
        }
        else {
            dispatch_barrier_async(q, block)
        }
        return self
    }

    //MARK: Dispatch multiple blocks
    public func async(blocks:[() -> Void]) -> Queue {
        for block in blocks {
            async(block)
        }
        return self
    }

    //MARK: Others
    public func iterate(iteration:Int, block:(i:Int) -> ()) {
        dispatch_apply(iteration, dispatchQueue(),block)
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

//MARK: Operator
func <<(q:Queue,block:() -> Void) -> Queue {
    return q.async(block)
}
func <<(q:Queue,blocks:[() -> Void]) -> Queue {
    return q.async(blocks)
}
infix operator |<< { associativity left precedence 140  }
func |<< (q:Queue,block:() -> Void) -> Queue {
    return q.barrierAsync(block)
}

//MARK: Time
extension NSTimeInterval {
    var nanosecondsRepresentation:Double {
        return self * Double(NSEC_PER_SEC)
    }
}

extension dispatch_time_t {
    init(timeInterval:NSTimeInterval?) {
        if let i = timeInterval {
            self.init(i.nanosecondsRepresentation)
        }
        else {
            self.init(DISPATCH_TIME_FOREVER)
        }
    }
}


