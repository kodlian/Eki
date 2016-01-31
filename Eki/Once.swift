//
//  Once.swift
//  Eki
//
//  Created by Jeremy Marchand on 20/10/2014.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Foundation

/**
Create a block that dispatch a block once and only once.
*/
public func OnceDispatcher() -> ((() -> Void) -> Void) {
    var token = dispatch_once_t(0)

    return { block in
        dispatch_once(&token, block)
    }
}
