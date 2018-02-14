//
//  WordDropUITests.swift
//  WordDropUITests
//
//  Created by Cihan Emre Kisakurek (Company) on 13.02.18.
//  Copyright © 2018 cekisakurek. All rights reserved.
//

import XCTest

class WordDropUITests: XCTestCase {

    private var gameEndExpectation : XCTestExpectation = XCTestExpectation(description: "Game End Expectation")

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGameUI() {

        let app = XCUIApplication()
        var node = app.buttons["Drop"]

        let handler = { [unowned self] (notification: Notification) -> Void  in
            self.gameEndExpectation.fulfill()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "EndGame"), object: nil, queue: nil, using: handler)

        app.buttons["StartNode"].tap() // start game


        while(waitForDropToAppear(node)) {

            node = app.buttons["Drop"]
            let decision = Int(arc4random_uniform(UInt32(2)))
            print(decision)
            if decision > 0 {
                node.swipeRight()
            }
            else {
                node.swipeLeft()
            }
            sleep(1) // wait a bit for next round. Sometimes XCTWaiter has trouble copying node from main app.
        }
        // end test
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "EndGame"), object: nil, userInfo: ["amount": 50])
    }

    func waitForDropToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)

        let result = XCTWaiter().wait(for: [expectation], timeout: 10)
        return result == .completed
    }


}
