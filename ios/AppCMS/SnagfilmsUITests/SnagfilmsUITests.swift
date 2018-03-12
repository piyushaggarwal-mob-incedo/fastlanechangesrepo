//
//  AppCMSUITests.swift
//  AppCMSUITests
//
//  Created by Deepak Sahu on 6/28/17.
//  Copyright Â© 2017 Viewlift. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func wait(for duration: TimeInterval) {
        let waitExpectation = expectation(description: "Waiting")
        
        let when = DispatchTime.now() + duration
        DispatchQueue.main.asyncAfter(deadline: when) {
            waitExpectation.fulfill()
        }
        
        // We use a buffer here to avoid flakiness with Timer on CI
        waitForExpectations(timeout: duration + 0.5)
    }
}


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
        
        // In UI tests itâ€™s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
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
    
    func fastlaneArgValueForKey(key:String, app:XCUIApplication) -> String? {
        print("App launchArguments: %@", app.launchArguments.description)
        NSLog("App launchArguments: %@", app.launchArguments.description)
        if let index = app.launchArguments.index(of:key) {
            return app.launchArguments[index+1]
        } else {
            return nil
        }
    }
    func testExample() {
        
        defaultTestExample()
    }
    
    func defaultTestExample() {
        
        let cancelButton = app.alerts["No Response Received"].buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        let tablesQuery = XCUIApplication().tables

        let tabBarsQuery = app.tabBars

        snapshot("01Home")
        let menu = tabBarsQuery.buttons["Menu"]
        
        if menu.exists {
            menu.tap()
            snapshot("02Menu")
        }
        
        let movie = tabBarsQuery.buttons["Movies"]
        if movie.exists {
            movie.tap()
            let comedyText = tablesQuery.staticTexts["COMEDY"]
            self.waitForElementToAppear(element:comedyText, timeout: 30)
            snapshot("03Movie")
        }
        
        
    }
    
    func snagFilmsTestExample() {

        let tablesQuery = XCUIApplication().tables
        
        
        let socialIssuesStaticText = tablesQuery.staticTexts["The Good Son"]
        self.waitForElementToAppear(element:socialIssuesStaticText, timeout: 30)
        snapshot("01Home")
        
        
        let tabBarsQuery = app.tabBars

        let menu = tabBarsQuery.buttons["Menu"]
        if menu.exists {
            menu.tap()
            snapshot("02Menu")
        }
        
        
        let movie = tabBarsQuery.buttons["Movies"]
        if movie.exists {
            movie.tap()
            
            let comedyText = tablesQuery.staticTexts["COMEDY"]
            self.waitForElementToAppear(element:comedyText, timeout: 30)
            snapshot("03Movie")
        }
        
        let showsButton = tabBarsQuery.buttons["Shows"]
        
        if showsButton.exists{
            showsButton.tap()
            sleep(5)
        }
        
        let iconSearchBtn = app.navigationBars["Snagfilms.PageView"].buttons["icon search"]
        
        if iconSearchBtn.exists{
            iconSearchBtn.tap()
            sleep(5)
            app.textFields["SEARCH"].typeText("co")
            sleep(5)
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["100 Years Of Comedy"]/*[[".cells.staticTexts[\"100 Years Of Comedy\"]",".staticTexts[\"100 Years Of Comedy\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            sleep(4)
            app.textFields["SEARCH"].typeText("co")
            sleep(5)
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["100 Years Of Comedy"]/*[[".cells.staticTexts[\"100 Years Of Comedy\"]",".staticTexts[\"100 Years Of Comedy\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }

        
        
        
        
//        let search = tabBarsQuery.buttons["Search"]
//        if search.exists {
//            search.tap()
//
//            let searchTextField = app.textFields["SEARCH"]
//            searchTextField.tap()
//            searchTextField.typeText("M")
//
//
//            var epicText = tablesQuery.staticTexts["100 Years Of Comedy"]
//            self.waitForElementToAppear(element:epicText, timeout: 5)
//            snapshot("04Search")
//            app.tables.staticTexts["100 Years Of Comedy"].tap()
//
//            epicText = tablesQuery.staticTexts["The Good Son"]
//            self.waitForElementToAppear(element:epicText, timeout: 5)
//            snapshot("05Search")
//        }
    }
    func agendaTVTestExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        snapshot("01Home")
        
        let app = XCUIApplication()
        
        let cancelButton = app.alerts["No Response Received"].buttons["Cancel"]
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        if cancelButton.exists {
            cancelButton.tap()
        }
        
        let tablesQuery = XCUIApplication().tables
        let socialIssuesStaticText = tablesQuery.staticTexts["NOW YOU KNOW HISTORY"]
        self.waitForElementToAppear(element:socialIssuesStaticText, timeout: 30)
        snapshot("01Home")
        
        let tabBarsQuery = app.tabBars
        let menu = tabBarsQuery.buttons["Menu"]
        if menu.exists {
            menu.tap()
            snapshot("02Menu")
        }
        
        let search = tabBarsQuery.buttons["Search"]
        if search.exists {
            search.tap()
            
            let searchTextField = app.textFields["SEARCH"]
            searchTextField.tap()
            searchTextField.typeText("A")
            
            //let app2 = app
            app.keyboards.keys["s"].tap()
            
            snapshot("04Search")
        }
    }
    func hoiChoiTestExample() {
        defaultTestExample()
    }
    func formula1TestExample() {
        defaultTestExample()
    }
}

