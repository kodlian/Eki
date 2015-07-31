//
//  Executor.swift
//  Eki
//
//  Created by phimage on 09/06/15.
//  Copyright (c) 2015 Jérémy Marchand. All rights reserved.
//

import Foundation

public typealias Executor = ( () -> Void) -> Void

public func ImmediateExecutor(block: () -> Void)  {
    block()
}

public extension Queue {
    
    public var executor: Executor {
        return { block in
            self.async(block)
        }
    }
    
    public var syncExecutor: Executor {
        return { block in
            self.sync(block)
        }
    }

    public var barrierAsyncExecutor: Executor {
        return { block in
            self.barrierAsync(block)
        }
    }
    
    public var barrierSyncExecutor: Executor {
        return { block in
            self.barrierSync(block)
        }
    }

}

public extension Semaphore {
    
    public var executor: Executor {
        return { block in
            self.perform(block)
        }
    }
}

public extension Group {
    
    public var executor: Executor {
        return { block in
            self.async(block)
        }
    }

    public var notifyExecutor: Executor {
        return { block in
            self.notify(block)
        }
    }
}
