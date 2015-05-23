//
//  Once.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
A token to be initilized and stored for use with once().
*/
public final class OnceToken {
    internal var dispatchToken = dispatch_once_t(0)
    public init() {
        
    }
}

/**
Execute a block once and only once.
*/
public func once(token:OnceToken, block:() -> Void) {
    dispatch_once(&token.dispatchToken,block)
}
