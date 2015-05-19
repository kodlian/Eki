//
//  Once.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
@abstract
A token to be initilized and stored for use with once().
*/
public final class Token {
    internal var dispatchToken = dispatch_once_t(0)
}

/**
@abstract
Convenient method for dispatch_once
*/
public func  once(token:Token, block:() -> Void) {
    dispatch_once(&token.dispatchToken,block)
}
