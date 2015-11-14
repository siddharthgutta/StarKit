//
//  StarKitTests.swift
//  StarKitTests
//
//  Created by Jesse Tipton on 11/12/15.
//  Copyright © 2015 Entree. All rights reserved.
//

import XCTest
import StarKit

class StarKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrinting() {
        var waiting = true
        
        print("Searching for printers...")
        Printer.searchForLANPrintersWithCompletionHandler { printers in
            if let printer = printers.first {
                print("At least one printer found!")
                let dictionary = ["{{printerName}}": printer.name, "{{printerStatus}}": printer.status.rawValue]
                let filePath = NSBundle(forClass: self.classForCoder).pathForResource("test_template", ofType: "xml")!
                let printData = PrintData(dictionary: dictionary, filePath: filePath)
                printer.printData(printData) {
                    print("Print data sent!")
                    waiting = false
                }
            }
        }
        
        while waiting {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1))
        }
    }
    
}
