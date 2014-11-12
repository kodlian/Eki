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
Convenient method for dispatch_once
*/
public func  dispatchOnce(inout token:DispatchOnceToken, block:() -> Void) {
    dispatch_once(&token,block)
}


public typealias  DispatchOnceToken = dispatch_once_t