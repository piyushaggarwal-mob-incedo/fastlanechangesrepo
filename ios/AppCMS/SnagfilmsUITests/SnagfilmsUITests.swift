//
//  SnagfilmsUITests.swift
//  SnagfilmsUITests
//
//  Created by Piyush on 22/03/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import XCTest

class SnagfilmsUITests: XCTestCase {
    var app: XCUIApplication!
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testExample() {
        let tabBarsQuery = app.tabBars
        
        snapshot("01Home")
        
        if app.alerts["“ViewliftMobileApp” Would Like to Send You Notifications"].exists{
            app.alerts["“ViewliftMobileApp” Would Like to Send You Notifications"].buttons["Allow"].tap()
            app.buttons["OK"].tap()
        }
        
        snapshot("01Home")
        
        snapshot("02Menu")
        
        let movie = tabBarsQuery.buttons["Movies"]
        if movie.exists {
             snapshot("03Movie")
        }
        
//        let menu = tabBarsQuery.buttons["Menu"]
//        if menu.exists {
//            menu.tap()
//            snapshot("02Menu")
//        }
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func defaultTestExample() {
        
        let tablesQuery = XCUIApplication().tables
        let tabBarsQuery = app.tabBars
        
        //snapshot("01Home")
        let menu = tabBarsQuery.buttons["Menu"]
        
        if menu.exists {
            menu.tap()
            //snapshot("02Menu")
        }
        
        let movie = tabBarsQuery.buttons["Movies"]
        if movie.exists {
            movie.tap()
            let comedyText = tablesQuery.staticTexts["COMEDY"]
            self.waitForElementToAppear(element:comedyText, timeout: 30)
            //            snapshot("03Movie")
        }
    }
    
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: Int(line), expected: true)
            }
        }
    }
    
}
