//
//  flsetupUITests.swift
//  flsetupUITests
//
//  Created by Krzysztof Rodak on 20/12/15.
//  Copyright © 2015 X8. All rights reserved.
//

import XCTest

class flsetupUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        let backButton = app.navigationBars["UIView"].childrenMatchingType(.Button).elementBoundByIndex(0)

        snapshot("00-MainScreen")
        app.buttons["Navigate to VC 1"].tap()
        snapshot("01-VC")

        backButton.tap()
        app.buttons["Navigate to VC 2"].tap()
        snapshot("02-VC")
        backButton.tap()
        app.buttons["Navigate to VC 3"].tap()
        snapshot("03-VC")
        backButton.tap()
        app.buttons["Navigate to VC 4"].tap()
        snapshot("04-VC")
        backButton.tap()

    }
    
}
