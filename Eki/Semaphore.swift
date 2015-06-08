//
//  Semaphore.swift
//  Eki
//
//  Created by Jeremy Marchand on 14/05/2015.
//  Copyright (c) 2015 Jérémy Marchand. All rights reserved.
//

import Foundation
/**
A wrapper for Grand Central Dispatch Semaphore
*/
public struct Semaphore {
    public enum Kind {
        case Binary
        case Barrier
        case Counting(resource:UInt16)
        
        func unitsCount() -> Int {
            switch self  {
            case Binary:
                return 1
            case Barrier:
                return 0
            case Counting(let c):
                return Int(c)
            }
        }
    }
    
    private let semaphore:dispatch_semaphore_t
    private let kind:Kind

    public init(_ kind:Kind = .Binary) {
        self.kind = kind
        let resource = kind.unitsCount()
        semaphore = dispatch_semaphore_create(resource)
    }
    
    //MARK: - Semaphore core method
    public func wait(time:NSTimeInterval? = nil) -> Bool {
        return dispatch_semaphore_wait(semaphore,dispatch_time_t(timeInterval: time)) == 0
    }
    
    public func signal() -> Bool{
        return dispatch_semaphore_signal(semaphore) > 0
    }
    
    
}

//MARK: - Convenient method to perform a block when a semaphore resource is free and immediatly release it after the block execution.
public extension Semaphore {
    public func perform(block:(Void) -> Void) {
        wait()
        block()
        signal()
    }
}

//MARK: - Edsger Dijkstra naming - Dutch
public extension Semaphore {
    public func P(time: NSTimeInterval? = nil) -> Bool {
        return self.wait(time: time)
    }
    public func V()  -> Bool {
        return self.signal()
    }
}

/**
A Mutex is essentially the same thing as a binary semaphore exept that only the block that locked the mutext is supposed to unlock it.
*/
public struct Mutex {
    private var semaphore:Semaphore

    public init(){
        semaphore = Semaphore(.Binary)
    }
    
    public func perform(block:(Void) -> Void) {
        semaphore.perform(block)
    }
    
}

/**
Convenient class to lock access to an object with an internal mutext
*/
public struct LockedObject<T:AnyObject> {
    private var object:T
    private var mutext:Mutex
    init(_ object:T){
        self.object = object
        mutext = Mutex()
    }
    func access(block:(object:T) -> Void) {
        mutext.perform { (Void) -> Void in
            block(object: self.object)
        }
    }
}

//MARK: Operator
public func <<< (semaphore:Semaphore,block:() -> Void) -> Semaphore {
    semaphore.perform(block)
    return semaphore
}
public prefix func ++ (semaphore: Semaphore) {
    semaphore.signal()
}
public prefix func -- (semaphore: Semaphore) {
    semaphore.wait()
}
