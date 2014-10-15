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
public enum DispatchQueue {
    /**
    The serial queue associated with the application’s main thread
    */
    case Main
    
    /**
    A system-defined global concurrent queue with a User Interactive quality of service class.
    */
    case UserInteractive
    
    /**
    A system-defined global concurrent queue with a User Initiated quality of service class.
    */
    case UserInitiated
    
    /**
    A system-defined global concurrent queue with a Default quality of service class.
    */
    case Default
    
    /**
    A system-defined global concurrent queue with a Utility quality of service class.
    */
    case Utility
    
    /**
    A system-defined global concurrent queue with a Background quality of service class.
    */
    case Background

    case Concurrent(name:String)
    case Serial(name:String)
    case Custom(queue:dispatch_queue_t)

    
    /**
   
    */
    func queue() -> dispatch_queue_t {
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
        case .Concurrent(let name):
            return dispatch_queue_create(name,DISPATCH_QUEUE_CONCURRENT)
        case .Serial(let name):
            return dispatch_queue_create(name,DISPATCH_QUEUE_SERIAL)
        case .Custom(let queue):
            return queue
        }
        
    }

    //MARK: Dispatch function
    public func asyncBlock(block:() -> ()) {
        dispatch_async(queue(), block)
    }
    public func syncBlock(block:() -> ()) {
        dispatch_sync(queue(), block)
    }
    public func after(delay:NSTimeInterval,  block:() -> ()) {
        dispatch_after(dispatch_time_t(delay) * dispatch_time_t(NSEC_PER_SEC), queue(), block)
    }
}

//MARK: Dispatch convenient func
public func once(block:() -> ()) {
    var token : dispatch_once_t = 0
    dispatch_once(&token,block)
}
public func async(block:() -> ()) {
    DispatchQueue.Main.asyncBlock(block)
}
public func sync(block:() -> ()) {
    DispatchQueue.Main.syncBlock(block)
}
public func after(delay:NSTimeInterval,  block:() -> ()) {
    DispatchQueue.Main.after(delay, block:block)
}



