//
//  EkiTests.swift
//  EkiTests
//
//  Created by Jérémy Marchand on 15/10/14.
//  Copyright (c) 2014 Jérémy Marchand. All rights reserved.
//

import Cocoa
import XCTest
import Eki

class EkiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAsync() {
        let expt = self.expectationWithDescription("Dispatch")

        Queue.Background <<< {
            
            } <<< {
                expt.fulfill()
        }
   
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testCustomAsync() {
        let expt = self.expectationWithDescription("CustomAsync")
        let q = Queue(name: "foo", kind: .Concurrent)
        var a = 0
        
        q <<< {
            a++
            } |<| {
                if a == 1 {
                    a++
                }
            } <<< {
                expt.fulfill()
                XCTAssertEqual(a, 2, "Block barrier have not been executed correctly")
                
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testIterate() {
        let expt = self.expectationWithDescription("Iterate")

        var c = 0
        Queue.UserInitiated.iterate(4) { i  in
            c++
            if c == 4 {
                expt.fulfill()
            }
        }
        
        
        self.waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testTaskChain() {
        let expt = self.expectationWithDescription("Operation")

        let q = Queue(name: "myqueue", kind: .Concurrent)
        var test = [0,0]
        let task =  Queue.UserInitiated + {
            test[0] = 1
        }
        
        task.async() <> {
            test = test.reverse()
            } <> Queue.Main + {
                expt.fulfill()
                XCTAssertEqual(test, [0,1], "Blocks have not been executed on a chain")
        }
        
        

        self.waitForExpectationsWithTimeout(4, handler: nil)
    }
    
    func testOnce() {
        let t = OnceToken()
        var c = 0
        for i in 0...4 {
            once(t) {
                c++
            }
        }
        
        XCTAssertEqual(c, 1, "Block have not been executed one time")
    }

    func testGroup() {
        let expt = self.expectationWithDescription("Group")

        var test = [0,0,0,0];
        let queue = Queue(name: "myqueue", kind: .Concurrent)
        let grp = Group(queue: queue)
        for i in 0..<4 {
            grp <<< {
                test[i] = i
            }
        }
        grp.notify {
            expt.fulfill()
            XCTAssertEqual(test, [0,1,2,3], "GRoup 's blocks have not been executed correctly")

        }
        
        self.waitForExpectationsWithTimeout(4, handler: nil)

    }
}
