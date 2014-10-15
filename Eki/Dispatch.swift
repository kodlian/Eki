//
//  Dispatch.swift
//  Montparnasse
//
//  Created by Jérémy Marchand on 15/10/14.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/// Grand Central Dispatch Queue wrapper
public class DispatchQueue {
    /// Dispatch Priority
    public enum Priority {
        case Background, Default, High, Low
        
        func queue() -> dispatch_queue_t {
            
            var priority:Int = 0
            
            switch (self) {
            case .Background:
                priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            case .Default:
                priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            case .High:
                priority = DISPATCH_QUEUE_PRIORITY_HIGH
            case .Low:
                priority = DISPATCH_QUEUE_PRIORITY_LOW
                
            }
            return dispatch_get_global_queue(priority, 0)
        }
        
    }
    public typealias Delay = dispatch_time_t

    private(set) var queue:dispatch_queue_t
    
    //MARK: Convenient queue
    public class var mainQueue:DispatchQueue {
        return DispatchQueue(queue: dispatch_get_main_queue())
    }

    //MARK: Initializers
    public init( queue q:dispatch_queue_t) {
        queue = q
    }
    public init( priority:Priority) {
        queue = priority.queue()
    }
    public init( backgroundQueueName:String) {
        queue = dispatch_queue_create(backgroundQueueName, nil)
    }

    //MARK: Dispatch function
    public func asyncBlock(block:() -> ()) {
        dispatch_async(queue, block)
    }
    public func syncBlock(block:() -> ()) {
        dispatch_sync(queue, block)
    }
    public func after(delay:Delay,  block:() -> ()) {
        dispatch_after(delay, queue, block)
    }
}

//MARK: Dispatch convenient func
public func once(block:() -> ()) {
    var token : dispatch_once_t = 0
    dispatch_once(&token,block)
}
public func async(block:() -> ()) {
    DispatchQueue.mainQueue.asyncBlock(block)
}
public func sync(block:() -> ()) {
    DispatchQueue.mainQueue.syncBlock(block)
}
public func after(delay:DispatchQueue.Delay,  block:() -> ()) {
    DispatchQueue.mainQueue.after(delay, block:block)
}



