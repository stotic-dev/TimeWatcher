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
    func testExample() throws {
        
        let app = XCUIApplication()
        
        // portraitにする
        XCUIDevice.shared.orientation = .portrait
        
        snapshot("launch", timeWaitingForIdle: 1)
        
        app.buttons["ActionButton_Start"].tap()
        snapshot("Start Timer", timeWaitingForIdle: 1)
        
        app.buttons["ActionButton_Stop"].tap()
        snapshot("Stop Timer", timeWaitingForIdle: 1)
    }
}
