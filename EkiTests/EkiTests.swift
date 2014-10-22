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
    
    func testBackgroundSync() {
        let expt = self.expectationWithDescription("Dispatch")

        Queue.Background.dispatchBlock({
            expt.fulfill()
        }, wait:true)
   

        self.waitForExpectationsWithTimeout(2, handler: nil)

    }
    
    func testMainASync() {
        let expt = self.expectationWithDescription("Dispatch")
        Queue.Main.dispatchBlock(){
            expt.fulfill()
        }
        self.waitForExpectationsWithTimeout(2, handler: nil)
        
    }
    

    
}
