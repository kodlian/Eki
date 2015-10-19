//
//  Source.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2015.
//  Copyright (c) 2015 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
A wrapper for Grand Central Dispatch Source
*/
public class Source {

    public let queue: Queue
    public let type: SourceType
    let source: dispatch_source_t

    //MARK: init
    init(type: SourceType, queue: Queue, handle: UInt = 0, mask: UInt = 0) {
        self.queue = queue
        self.type = type
        source = dispatch_source_create(type.rawValue, handle, mask, queue.dispatchQueue)
    }

    //MARK: Handler setter
    public var block: (() -> Void)?  = nil {
        didSet {
            updateHandler(dispatch_source_set_event_handler, handler: block)
        }
    }

    public var cancelHandler: (() -> Void)? = nil {
        didSet {
            updateHandler(dispatch_source_set_registration_handler, handler: cancelHandler)
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

    //MARK:
    var handle: UInt {
        return dispatch_source_get_handle(source)
    }
    var mask: UInt{
        return dispatch_source_get_mask(source)
    }
    var data: UInt {
        return dispatch_source_get_data(source)
    }
    func mergeData(value: UInt) {
        dispatch_source_merge_data(source, value)
    }
    
    //MARK: cancel
    public func stop() {
        dispatch_source_cancel(source)
    }

    public var stopped: Bool {
        return 0 != dispatch_source_testcancel(source)
    }
}

public enum SourceType {
    case DataAdd, DataOr, MachSend, MachReceive, MemoryPressure, Process, Read, Signal, Timer, Vnode, Write
    
    var rawValue: dispatch_source_type_t {
        switch self {
        case DataAdd:
            return DISPATCH_SOURCE_TYPE_DATA_ADD
        case DataOr:
            return DISPATCH_SOURCE_TYPE_DATA_OR
        case MachSend:
            return DISPATCH_SOURCE_TYPE_MACH_SEND
        case MachReceive:
            return DISPATCH_SOURCE_TYPE_MACH_RECV
        case MemoryPressure:
            return DISPATCH_SOURCE_TYPE_MEMORYPRESSURE
        case Process:
            return DISPATCH_SOURCE_TYPE_PROC
        case Read:
            return DISPATCH_SOURCE_TYPE_READ
        case Signal:
            return DISPATCH_SOURCE_TYPE_SIGNAL
        case Timer:
            return DISPATCH_SOURCE_TYPE_TIMER
        case Vnode:
            return DISPATCH_SOURCE_TYPE_VNODE
        case Write:
            return DISPATCH_SOURCE_TYPE_WRITE
        }
    }

}

enum TimerFlag {
    case Strict
    
    var rawValue: dispatch_source_timer_flags_t {
        switch self {
        case Strict:
            return DISPATCH_TIMER_STRICT
        }
    }
}

enum MemoryPressureFlag {
    case Critical, Normal, Warn
    
    var rawValue: dispatch_source_memorypressure_flags_t {
        switch self {
        case Critical:
            return DISPATCH_MEMORYPRESSURE_CRITICAL
        case Normal:
            return DISPATCH_MEMORYPRESSURE_NORMAL
        case Warn:
            return DISPATCH_MEMORYPRESSURE_WARN
        }
    }
}

enum ProcFlag {
    case Exec, Exit, Fork, Signal
    
    var rawValue: dispatch_source_proc_flags_t {
        switch self {
        case Exec:
            return DISPATCH_PROC_EXEC
        case Exit:
            return DISPATCH_PROC_EXIT
        case Fork:
            return DISPATCH_PROC_FORK
        case Signal:
            return DISPATCH_PROC_SIGNAL
        }
    }
}

enum VNodeFlag {
    case Attrib, Delete, Extend, Link, Rename, Revoke, Write
    
    var rawValue: dispatch_source_vnode_flags_t {
        switch self {
        case Attrib:
            return DISPATCH_VNODE_ATTRIB
        case Delete:
            return DISPATCH_VNODE_DELETE
        case Extend:
            return DISPATCH_VNODE_EXTEND
        case Link:
            return DISPATCH_VNODE_LINK
        case Rename:
            return DISPATCH_VNODE_RENAME
        case Revoke:
            return DISPATCH_VNODE_REVOKE
        case Write:
            return DISPATCH_VNODE_WRITE
        }
    }
}

enum MachSendFlag {
    case Dead
    
    var rawValue: dispatch_source_mach_send_flags_t {
        switch self {
        case Dead:
            return DISPATCH_MACH_SEND_DEAD
        }
    }
}

