//
//  TimerStartIntentTest.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import ActivityKit
import Combine
import XCTest

@testable import TimeWatcher

final class TimerStartIntentTest: XCTestCase {
    
    // テスト開始時の基準の時間
    private var currentDate: Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: "20000101")!
    }
    
    private var dependencyDate: DateDependency!
    private let calendar = Calendar.current
    
    override func setUp() {
        
        dependencyDate = DateDependency(now: currentDate, isTest: true)
    }
    
    /// 正常系のTimerStartIntentの動作確認
    @MainActor
    func testNormalCase() async throws {
        
        let timeWatch = TimeWatch(currentTime: dependencyDate)
        
        // LiveActivityのupdateだけ1回呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.isInverted = true
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.isInverted = true
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [[.hour: 0]],
                                                               expectedTimeLapseMilliSec: [0],
                                                               expectedTimeLapseString: ["00:00:00"],
                                                               expectedTimerStatus: [.start])
        
        let targetIntent = TimerStartIntent(timeWatch: timeWatch,
                                            liveActivityManager: liveActivityManager,
                                            dateDependency: dependencyDate)
        
        // performメソッド実行
        let result = try await targetIntent.perform()
        
        // LiveActivityMgrの動作確認
        await fulfillment(of: [
            startLiveActivityExpectation,
            updateLiveActivityExpectation,
            endLiveActivityExpectation
        ],
                          timeout: 1)
        
        // performメソッドの結果確認
        XCTAssert(result.value == nil)
    }
    
    /// 異常系のTimerStartIntentの動作確認
    @MainActor
    func testErrorCase() async throws {
        
        let timeWatch = TimeWatch(currentTime: dependencyDate)
        
        // LiveActivityのupdateだけ1回呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.isInverted = true
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.isInverted = true
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [[.hour: 0]],
                                                               expectedTimeLapseMilliSec: [0],
                                                               expectedTimeLapseString: ["00:00:00"],
                                                               expectedTimerStatus: [.start],
                                                               needThrowUpdate: true)
        
        let targetIntent = TimerStartIntent(timeWatch: timeWatch,
                                            liveActivityManager: liveActivityManager,
                                            dateDependency: dependencyDate)
        
        do {
            
            // performメソッド実行
            let result = try await targetIntent.perform()
            XCTFail("Not throw error(\(result)).")
        }
        catch {
            
            guard let error = error as? LiveActivityRequestError else {
                
                XCTFail()
                return
            }
            
            XCTAssertEqual(error, LiveActivityRequestError.notFoundActivity)
        }
        
        // LiveActivityMgrの動作確認
        await fulfillment(of: [
            startLiveActivityExpectation,
            updateLiveActivityExpectation,
            endLiveActivityExpectation
        ],
                          timeout: 1)
    }
}

private extension TimerStartIntentTest {
    
    func setupLiveActivityManagerMock(startExpectation: XCTestExpectation,
                                      updateTimeExpectation: XCTestExpectation,
                                      endExpectation: XCTestExpectation,
                                      expectedTimeLapseComponent: [[Calendar.Component: Int]],
                                      expectedTimeLapseMilliSec: [TimeInterval],
                                      expectedTimeLapseString: [String],
                                      expectedTimerStatus: [TimerStatus],
                                      needThrowStart: Bool = false,
                                      needThrowUpdate: Bool = false,
                                      needThrowEnd: Bool = false) -> LiveActivityManagerMock {
        
        var expectedTimeLapseComponents = expectedTimeLapseComponent
        var expectedTimeLapseMilliSecs = expectedTimeLapseMilliSec
        var expectedTimeLapseStrings = expectedTimeLapseString
        var expectedTimerStatus = expectedTimerStatus
        
        return LiveActivityManagerMock { _ in
            
            startExpectation.fulfill()
            
            if needThrowStart { throw ActivityAuthorizationError.unsupported }
        } updateProc: { state in
            
            let minusMilliSec = TestUtilities.getAddingMilliSec(expectedTimeLapseMilliSecs.removeFirst(),
                                                                to: self.dependencyDate.generateNow())
            let minusTimeLapse = TestUtilities.getTimeLapse(base: minusMilliSec,
                                                            adding: expectedTimeLapseComponents.removeFirst())
            let endDate = self.calendar.date(byAdding: .hour,
                                             value: 100,
                                             to: self.dependencyDate.generateNow()) ?? self.dependencyDate.generateNow()
            let actualState: TimeWatcherWidgetAttributes.ContentState = .init(timeLapse: minusTimeLapse...endDate,
                                                                              timeLapseString: expectedTimeLapseStrings.removeFirst(),
                                                                              timerStatus: expectedTimerStatus.removeFirst())
            
            XCTAssertEqual(state.timeLapse.lowerBound.toStringDate(), actualState.timeLapse.lowerBound.toStringDate())
            XCTAssertEqual(state.timeLapse.upperBound.toStringDate(), actualState.timeLapse.upperBound.toStringDate())
            XCTAssertEqual(state.timeLapseString, actualState.timeLapseString)
            XCTAssertEqual(state.timerStatus, actualState.timerStatus)
            
            updateTimeExpectation.fulfill()
            
            if needThrowUpdate { throw LiveActivityRequestError.notFoundActivity }
        } stopProc: {
            
            endExpectation.fulfill()
            
            if needThrowEnd { throw LiveActivityRequestError.notFoundActivity }
        }
    }
}
