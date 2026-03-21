//
//  TimerStopIntentTest.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/17.
//

import Combine
import XCTest
import TimeWatcherCore
import TimeWatcherTestSupport

final class TimerStopIntentTest: XCTestCase {

    // テスト開始時の基準の時間
    private var currentDate: Date {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: "20000101")!
    }

    private var dependencyDate: DateDependency!

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
                                                               expectedTimeLapseStrings: ["00:00:00"],
                                                               expectedTimerStatuses: [.stop])

        let targetIntent = TimerStopIntent(timeWatch: timeWatch,
                                           liveActivityManager: liveActivityManager,
                                           dateDependency: dependencyDate)

        // タイマー開始中にする(StopのIntentを実行する際は、タイマーが開始している時しかないため)
        timeWatch.startTimer()

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
                                                               expectedTimeLapseStrings: ["00:00:00"],
                                                               expectedTimerStatuses: [.stop],
                                                               needThrowUpdate: true)

        let targetIntent = TimerStopIntent(timeWatch: timeWatch,
                                           liveActivityManager: liveActivityManager,
                                           dateDependency: dependencyDate)

        // タイマー開始中にする(StopのIntentを実行する際は、タイマーが開始している時しかないため)
        timeWatch.startTimer()

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

private extension TimerStopIntentTest {

    func setupLiveActivityManagerMock(startExpectation: XCTestExpectation,
                                      updateTimeExpectation: XCTestExpectation,
                                      endExpectation: XCTestExpectation,
                                      expectedTimeLapseStrings: [String],
                                      expectedTimerStatuses: [TimerStatus],
                                      needThrowStart: Bool = false,
                                      needThrowUpdate: Bool = false,
                                      needThrowEnd: Bool = false) -> LiveActivityManagerMock {

        var expectedStrings = expectedTimeLapseStrings
        var expectedStatuses = expectedTimerStatuses

        return LiveActivityManagerMock { _ in

            startExpectation.fulfill()

            if needThrowStart { throw LiveActivityRequestError.notFoundActivity }
        } updateProc: { state in

            XCTAssertEqual(state.timeLapseString, expectedStrings.removeFirst())
            XCTAssertEqual(state.timerStatus, expectedStatuses.removeFirst())

            updateTimeExpectation.fulfill()

            if needThrowUpdate { throw LiveActivityRequestError.notFoundActivity }
        } stopProc: {

            endExpectation.fulfill()

            if needThrowEnd { throw LiveActivityRequestError.notFoundActivity }
        }
    }
}
