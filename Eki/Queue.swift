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
    static var currentKey = 0 //"Eki.queue"
    static var onceSpecifics = OnceDispatcher() //"Eki.queue"

    case Main
    case UserInteractive
    case UserInitiated
    case Default
    case Utility
    case Background
    case Custom(queue:dispatch_queue_t)
    
    private static let allDefaults:[Queue] = [Main, UserInteractive, UserInitiated, Default, Utility , Background]

    //MARK: type
    /**
    Customn queue type
    */
    public enum Kind {
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
    public init(name:String, kind:Kind){
        self = .Custom(queue: kind.createDispatchQueueWithName(name))
        setCurrentSpecific()
    }
    
    //MARK: Dispatch single block
    public func async(block:() -> Void) -> Queue{
        dispatch_async(dispatchQueue, block)
        return self
    }
    public func sync(block:() -> Void) -> Queue {
        if isCurrent {
            block()
        }
        else {
            dispatch_sync(dispatchQueue, block)
        }
        return self
    }
    public func after(delay:NSTimeInterval, doBlock block:() -> Void) -> Queue {
        dispatch_after(  dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay.nanosecondsRepresentation)
            ), dispatchQueue, block)
        return self
    }
    public func barrierAsync(block:() -> Void) -> Queue {
        dispatch_barrier_async(dispatchQueue, block)
        return self
    }
    public func barrierSync(block:() -> Void) -> Queue {
        if isCurrent {
            assertionFailure("You can't send a barrier on the same queue.")
        }
        else {
            dispatch_barrier_sync(dispatchQueue, block)
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
        dispatch_apply(iteration, dispatchQueue,block)
    }

    internal var dispatchQueue:dispatch_queue_t {
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
    
    //MARK: Suspend & Resume
    public func suspend() {
        switch (self) {
        case .Custom(let queue):
            dispatch_suspend(queue)
        default:
            assertionFailure("You can't suspend a global queue")
        }
    }
    
    public func resume() {
        switch (self) {
        case .Custom(let queue):
            dispatch_resume(queue)
        default:
            assertionFailure("You can't resume a global queue")
        }
    }
    
    //MARK: Current Queuess
    public static func initOnceGlobalQueueSpecifics() {
        onceSpecifics { () -> Void in
            for q in Queue.allDefaults {
                q.setCurrentSpecific()
            }
        }
    }
    
    private func setCurrentSpecific() {
        let q = dispatchQueue
        let opPtr = Unmanaged<dispatch_queue_t>.passUnretained(q).toOpaque()
        dispatch_queue_set_specific(q,
            &Queue.currentKey,  UnsafeMutablePointer<Void>(opPtr) , nil)
    }
    
    private static func getCurrentPointer() ->  UnsafeMutablePointer<Void> {
        let currentPtr = dispatch_get_specific(&Queue.currentKey)
        assert(currentPtr != nil, "Use only with custom queues initialized with Queue(name:String, kind:Queue.Custom.Kind), the Main queue and Global queues")
        return currentPtr
    }
    public var isCurrent:Bool {
        Queue.initOnceGlobalQueueSpecifics()
  
        let queuePtr = dispatch_queue_get_specific(self.dispatchQueue, &Queue.currentKey)
        return Queue.getCurrentPointer() == queuePtr
    }
    public static var current:Queue {
        initOnceGlobalQueueSpecifics()

        let currentQueue = Unmanaged<dispatch_queue_t>.fromOpaque(COpaquePointer(getCurrentPointer())).takeUnretainedValue()
        
        for q in Queue.allDefaults {
            if q.dispatchQueue == currentQueue {
                return q
            }
        }
        
        return Queue.Custom(queue: currentQueue)
    }
}

//MARK: Operator
infix operator <<< { associativity left precedence 160  }
public func <<< (q:Queue,block:() -> Void) -> Queue {
    return q.async(block)
}
public func <<< (q:Queue,blocks:[() -> Void]) -> Queue {
    return q.async(blocks)
}
infix operator |<| { associativity left precedence 160  }
public func |<| (q:Queue,block:() -> Void) -> Queue {
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

