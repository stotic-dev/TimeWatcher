//
//  TimeWatcherUITests.swift
//  TimeWatcherUITests
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import XCTest

final class TimeWatcherUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    @MainActor
    override func setUp() {
        
        super.setUp()
        
        continueAfterFailure = false
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    @MainActor
    func testExsample() throws {
        
        let app = XCUIApplication()
        snapshot("launch")
        
        app.buttons["ActionButton_Start"].tap()
        snapshot("Start Timer")
        
        app.buttons["ActionButton_Stop"].tap()
        snapshot("Stop Timer")
        
        // ホームボタン押下
        XCUIDevice.shared.press(XCUIDevice.Button.home)
        snapshot("Home Screen on LiveActivity")
        
        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        snapshot("Lock Screen on LiveActivity")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
