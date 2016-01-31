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

    //MARK: factory
    public class func scheduleWithInterval(interval: NSTimeInterval, onQueue queue: Queue, byRepeating shouldRepeat: Bool = false, block: () -> Void) -> Timer {
        let timer = Timer(queue: queue, interval: interval, shouldRepeat: shouldRepeat)

        timer.block = block
        timer.start()

        return timer
    }

    public class func scheduleWithDate(date: NSDate, onQueue queue: Queue,  block: () -> Void) -> Timer {
        let timer = Timer(queue: queue, date: date)

        timer.block = block
        timer.start()

        return timer
    }

    //MARK: Properties
    public let queue: Queue
    private let source: dispatch_source_t

    private let syncQueue = Queue(name: "Timer.syncQueue", kind: .Serial)
    private var suspended = false

    //MARK: Timer setter
    public var startTime: TimeConvertible = 0 {
        didSet {
            startDispatchTime = startTime.dispatchTime
            updateSourceTimer()
        }
    }
    private var startDispatchTime: dispatch_time_t = 0


    public var repeatInterval: NSTimeInterval? = nil {
        didSet {
            if repeatInterval != oldValue {
                updateSourceTimer()
            }
        }
    }
    public var tolerance: NSTimeInterval = 0.0 {
        didSet {
            if tolerance != oldValue {
                updateSourceTimer()
            }
        }
    }

    private func updateSourceTimer() {
        let deltaTime: UInt64
        if let interval = repeatInterval {
            deltaTime = UInt64(interval * NSTimeInterval(NSEC_PER_SEC))
        } else {
            deltaTime = DISPATCH_TIME_FOREVER
        }
        dispatch_source_set_timer(
            source,
            startDispatchTime,
            deltaTime,
            UInt64(tolerance * NSTimeInterval(NSEC_PER_SEC)))
    }

    //MARK: Handler setter
    public var block: (() -> Void)?  = nil {
        didSet {
            updateHandler(dispatch_source_set_event_handler, handler: block)
        }
    }

    public var cancelHandler: (() -> Void)? = nil {
        didSet {
            updateHandler(dispatch_source_set_cancel_handler, handler: cancelHandler)
        }
    }

    public var startHandler: (() -> Void)? = nil {
        didSet {
            updateHandler(dispatch_source_set_registration_handler, handler: startHandler)
        }
    }

    private func updateHandler(handlerSetMethod:(source: dispatch_source_t, handler: dispatch_block_t!) -> Void, handler someHandler:(() -> Void)?) {
        let handler = someHandler != nil ? someHandler : { () -> Void in }

        handlerSetMethod(source: source, handler: handler)
    }

    //MARK: init
    private init(queue: Queue) {
        self.queue = queue
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue.dispatchQueue)
    }

    convenience public init(queue: Queue, interval: NSTimeInterval, shouldRepeat: Bool = false) {
        self.init(queue: queue)
        startTime = interval
        if shouldRepeat {
            repeatInterval = interval
        }

        startDispatchTime = startTime.dispatchTime
        updateSourceTimer()
    }

    convenience public init(queue: Queue, interval: NSTimeInterval, repeatInterval rInterval: NSTimeInterval? = nil) {
        self.init(queue: queue)
        startTime = interval
        repeatInterval = rInterval
        startDispatchTime = startTime.dispatchTime
        updateSourceTimer()
    }

    convenience public init(queue: Queue, date: NSDate) {
        self.init(queue: queue)
        startTime = date
        startDispatchTime = startTime.dispatchTime
        updateSourceTimer()
    }

    deinit {
        block = nil
        startHandler = nil
        cancelHandler = nil

        if !stopped {
            stop()
        }
    }

    //MARK: Suspend & Resume
    public func start() {
        syncQueue.sync {
            let suspended = self.suspended
            if suspended {
                self.suspended = false
                dispatch_resume(self.source)
            }
        }
    }

    public func pause() {
        syncQueue.sync {
            let suspended = self.suspended
            if !suspended {
                self.suspended = true
                dispatch_suspend(self.source)
            }
        }
    }

    public var isRunning: Bool {
        var isSuspended = false
        syncQueue.sync {
            isSuspended = self.suspended
        }
        return !isSuspended
    }

    //MARK: cancel
    public func stop() {
        dispatch_source_cancel(source)
    }

    var stopped: Bool {
        return 0 != dispatch_source_testcancel(source)
    }
}

//MARK: Time
public protocol TimeConvertible {
    var dispatchTime: dispatch_time_t { get }
}

extension NSTimeInterval: TimeConvertible {
    public var dispatchTime: dispatch_time_t {
        let deltaTime = self * NSTimeInterval(NSEC_PER_SEC)
        return dispatch_time(DISPATCH_TIME_NOW, Int64(deltaTime))
    }
}

private extension NSTimeInterval {
    private var timeSpec: timespec {
        var seconds: NSTimeInterval = 0.0
        let nanoSeconds = modf(self, &seconds) * NSTimeInterval(NSEC_PER_SEC)
        return timespec(tv_sec: __darwin_time_t(seconds), tv_nsec: Int(nanoSeconds))
    }
}

extension NSDate: TimeConvertible {
    public var dispatchTime: dispatch_time_t {
        var walltime = self.timeIntervalSince1970.timeSpec
        return dispatch_walltime(&walltime, 0)
    }
}
