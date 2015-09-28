//
//  Timer.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
A wrapper for Grand Central Dispatch Source Type Timer
*/
public final class Timer {
    
    public let queue: Queue
    private let source: dispatch_source_t

    private let barrierQueue: Queue
    private var isSuspended: Bool
    
    public typealias Handler = (timer: Timer) -> Void
    private static let DEFAULT_LEEWAY = 0.0
 
    //MARK: init
    public init(queue: Queue) {
        self.queue = queue
        self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.dispatchQueue)

        self.barrierQueue = Queue(name: "Timer.barrierQueue", kind: .Concurrent)
        self.isSuspended = true
    }

    deinit {
        self.setEventHandler { (_) -> Void in }
        self.setCancelHandler { (_) -> Void in }
        self.setRegistrationHandler { (_) -> Void in }

        self.resume()
        self.cancel()
    }

    //MARK: factory
    public class func schedule(queue: Queue, interval: NSTimeInterval, eventHandler: Handler) -> Timer {
        return schedule(queue, interval: interval, suspended: false, eventHandler: eventHandler)
    }
    
    public class func schedule(queue: Queue, interval: NSTimeInterval, suspended: Bool, eventHandler: Handler) -> Timer {
        let timer = Timer(queue: queue)
        timer.setTimer(interval)
        timer.setEventHandler(eventHandler)
        if !suspended {
            timer.resume()
        }
        return timer
    }

    //MARK: Suspend & Resume
    public func resume() {
        var isSuspended = false
        barrierQueue.sync {
            isSuspended = self.isSuspended
            if isSuspended {
                self.isSuspended = false
            }
        }

        if isSuspended {
            dispatch_resume(self.source)
        }
    }

    public func suspend() {
        var isSuspended = false
        barrierQueue.sync {
            isSuspended = self.isSuspended
            if !isSuspended {
                self.isSuspended = true
            }
        }
        
        if !isSuspended {
            dispatch_suspend(self.source)
        }
    }

    public var isRunning: Bool {
        var isSuspended = false
        barrierQueue.sync {
            isSuspended = self.isSuspended
        }
        return !isSuspended
    }

    //MARK: cancel
    public func cancel() {
        dispatch_source_cancel(source)
    }

    public func testCancel() -> Bool {
        return 0 != dispatch_source_testcancel(source)
    }

    //MARK: Timer setter
    public func setTimer(interval: NSTimeInterval) {
        self.setTimer(interval, leeway: Timer.DEFAULT_LEEWAY)
    }

    public func setTimer(interval: NSTimeInterval, leeway: NSTimeInterval) {
        let deltaTime = interval * NSTimeInterval(NSEC_PER_SEC)
        dispatch_source_set_timer(
            self.source,
            dispatch_time(DISPATCH_TIME_NOW, Int64(deltaTime)),
            UInt64(deltaTime),
            UInt64(leeway * NSTimeInterval(NSEC_PER_SEC)))
    }

    public func setWallTimer(startDate startDate: NSDate, interval: NSTimeInterval){
        self.setWallTimer(startDate: startDate, interval: interval, leeway: Timer.DEFAULT_LEEWAY)
    }

    public func setWallTimer(startDate startDate: NSDate, interval: NSTimeInterval, leeway: NSTimeInterval){
        var walltime = startDate.timeIntervalSince1970.toTimeSpec()
        let deltaTime = interval * NSTimeInterval(NSEC_PER_SEC)
        dispatch_source_set_timer(
            self.source,
            dispatch_walltime(&walltime, Int64(deltaTime)),
            UInt64(deltaTime),
            UInt64(leeway * NSTimeInterval(NSEC_PER_SEC)))
    }

    //MARK: Handler setter
    public func setEventHandler(handler: Handler) {
        dispatch_source_set_event_handler(self.source) { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            autoreleasepool {
                handler(timer: strongSelf)
            }
        }
    }

    public func setCancelHandler(handler: Handler) {
        dispatch_source_set_cancel_handler(self.source) { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            autoreleasepool {
                handler(timer: strongSelf)
            }
        }
    }

    public func setRegistrationHandler(handler: Handler) {
        dispatch_source_set_registration_handler(self.source) { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            autoreleasepool {
                handler(timer: strongSelf)
            }
        }
    }

}

//MARK: Time
private extension NSTimeInterval {
    
    private func toTimeSpec() -> timespec {
        var seconds: NSTimeInterval = 0.0
        let nanoSeconds = modf(self, &seconds) * NSTimeInterval(NSEC_PER_SEC)
        return timespec(tv_sec: __darwin_time_t(seconds), tv_nsec: Int(nanoSeconds))
    }
}