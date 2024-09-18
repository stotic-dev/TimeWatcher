//
//  MainTimerViewTest.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/12.
//

import Combine
import XCTest
@testable import TimeWatcher
import ActivityKit

final class MainTimerViewTest: XCTestCase {
    
    // テスト開始時の基準の時間
    private var currentDate: Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: "20000101")!
    }
    
    private var dependencyDate: DateDependency!
    private let testTimerPublisher = PassthroughSubject<Date, Never>()
    private let calendar = Calendar(identifier: .gregorian)
    
    private var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        
        dependencyDate = DateDependency(now: currentDate, isTest: true)
    }
    
    override func tearDown() {
        
        cancellables.removeAll()
    }
    
    /// 開始ボタンの押下時の動作確認
    ///
    /// ## 確認ポイント
    /// - 初回の経過時間の文字列が00:00:00.000となっていること
    /// - 開始ボタン押下で時間計測が開始され経過時間の文字列が更新されること
    /// - 開始ボタン押下前に時間経過しても、経過時間の文字列が更新されないこと
    @MainActor
    func testTappedStartWatch() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        
        let liveActivityManager = LiveActivityManagerMock(startProc: { _ in },
                                                          updateProc: { _ in },
                                                          stopProc: {})
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 1秒経過
        guard let oneSecLapseTime = calendar.date(byAdding: .second, value: 1, to: currentDate) else {
            
            XCTFail("oneSecLapseTime is nil.")
            return
        }
        dependencyDate.now = oneSecLapseTime
        testTimerPublisher.send(dependencyDate.generateNow())
        
        // タイマー開始前に時間経過しても、画面表示する経過時間の文言に変化していないことを確認
        checkTimeStringZero(testViewModel)
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 99,
                                         addingMinute: 59,
                                         addingSec: 9,
                                         addingMilliSec: 999,
                                         expected: "99:59:09.999")
    }
    
    /// 停止ボタンの押下時の動作確認
    ///
    /// ## 確認ポイント
    /// - 停止中に時間経過しても表示時間に更新がないこと
    /// - 停止後再度開始したら前回停止した時間から時間計測が始まること
    /// - 最大表示可能経過時間が99:59:59.999までであること
    @MainActor
    func testTappedStopWatch() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        let liveActivityManager = LiveActivityManagerMock(startProc: { _ in },
                                                          updateProc: { _ in },
                                                          stopProc: {})
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 経過時間表示文字が正しく更新されていることを確認
        dependencyDate.now = TestUtilities.getTimeLapse(base: dependencyDate.generateNow(),
                                                        adding: [.hour: 3])
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 1, addingMinute: 59, addingSec: 50,
                                         expected: "00:00:09.000")
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 1, addingMinute: 59, addingSec: 50,
                                         expected: "01:59:59.000")
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 現在時間の更新
        dependencyDate.now = TestUtilities.getTimeLapse(base: dependencyDate.generateNow(),
                                                        adding: [.hour: 1])
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 99,
                                         expected: "99:59:59.999")
    }
    
    /// リセットボタンの押下時の動作確認
    ///
    /// ## 確認ポイント
    /// - 開始ボタン押下 -> 停止ボタン投下 -> リセットボタン押下で経過時間が00:00:00.000となること
    /// - リセット後再度開始したら00:00:00.000から時間計測が行われること
    /// - リセット後に時間経過しても表示時間に更新がないこと
    @MainActor
    func testTappedResetWatch() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        let liveActivityManager = LiveActivityManagerMock(startProc: { _ in },
                                                          updateProc: { _ in },
                                                          stopProc: {})
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 現在時間の更新
        dependencyDate.now = TestUtilities.getTimeLapse(base: dependencyDate.generateNow(),
                                                        adding: [.hour: 3])
        
        // タイムウォッチリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 現在時間の更新
        dependencyDate.now = TestUtilities.getTimeLapse(base: dependencyDate.generateNow(),
                                                        adding: [.minute: 3])
        
        // 経過時間表示文字が正しく更新されていることを確認
        testTimerPublisher.send(dependencyDate.generateNow())
        
        // 表示経過時間に変更がないことの確認
        checkTimeStringZero(testViewModel)
        
        // 現在時間の更新
        dependencyDate.now = TestUtilities.getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 1])
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 1,
                                         addingMilliSec: 201,
                                         expected: "01:00:00.201")
        
        // タイムウォッチリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
    }
    
    /// LiveActivityの正常系動作確認
    ///
    /// ## 確認ポイント
    /// - ウォッチ開始時にLiveActivityのリクエストが行われること
    /// - 開始中に時間経過でLiviActivityの更新リクエストが行われること、リクエスト内容が正しいこと
    /// - ウォッチ停止時にLiveActivityの更新リクエストが行われること、リクエスト内容が正しいこと
    /// - ウォッチリセット時にLiveActivityの終了リクエストが行われること、リクエスト内容が正しいこと
    @MainActor
    func testLiveActivityNormalCase() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        
        // LiveActivityのstart - endまで1回ずつ呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateStopLiveActivityExpectation = XCTestExpectation(description: "updateStopLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.expectedFulfillmentCount = 1
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               updateStopExpectation: updateStopLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [
                                                                [
                                                                    .hour: -99,
                                                                    .minute: -59,
                                                                    .second: -9
                                                                ],
                                                                [
                                                                    .hour: -99,
                                                                    .minute: -59,
                                                                    .second: -9
                                                                ]
                                                               ],
                                                               expectedTimeLapseMilliSec: [-999, -999],
                                                               expectedTimeLapseString: [
                                                                "99:59:09",
                                                                "99:59:09"
                                                               ])
        
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 1秒経過
        guard let oneSecLapseTime = calendar.date(byAdding: .second, value: 1, to: currentDate) else {
            
            XCTFail("oneSecLapseTime is nil.")
            return
        }
        testTimerPublisher.send(oneSecLapseTime)
        
        // タイマー開始前に時間経過しても、画面表示する経過時間の文言に変化していないことを確認
        checkTimeStringZero(testViewModel)
        
        // タイムウォッチ開始
        dependencyDate.now = oneSecLapseTime
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        wait(for: [startLiveActivityExpectation], timeout: 1)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 99,
                                         addingMinute: 59,
                                         addingSec: 9,
                                         addingMilliSec: 999,
                                         expected: "99:59:09.999")
        
        wait(for: [updateLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチを停止
        testViewModel.tappedTimerActionButton(.stop)
        
        wait(for: [updateStopLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチをリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態がリセット状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        wait(for: [endLiveActivityExpectation], timeout: 1)
    }
    
    /// LiveActivity異常系動作確認
    ///
    /// ## 確認ポイント
    /// - ウォッチ開始時にLiveActivityのリクエストでエラーが発生すること
    /// - 開始中に時間経過でLiviActivityの更新リクエストがトークンがないため失敗すること
    /// - ウォッチ停止時にLiveActivityの更新リクエストがトークンがないため失敗すること
    /// - ウォッチリセット時にLiveActivityの終了リクエストがトークンがないため失敗すること
    @MainActor
    func testLiveActivityErrorStartCase() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        
        
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.expectedFulfillmentCount = 1
        
        // 以下expectationはfullFillされないことを期待する
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.isInverted = true
        let updateStopLiveActivityExpectation = XCTestExpectation(description: "updateStopLiveActivityExpectation")
        updateStopLiveActivityExpectation.isInverted = true
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.isInverted = true
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               updateStopExpectation: updateStopLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [],
                                                               expectedTimeLapseMilliSec: [],
                                                               expectedTimeLapseString: [],
                                                               needThrowStart: true)
        
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 1秒経過
        guard let oneSecLapseTime = calendar.date(byAdding: .second, value: 1, to: currentDate) else {
            
            XCTFail("oneSecLapseTime is nil.")
            return
        }
        testTimerPublisher.send(oneSecLapseTime)
        
        // タイマー開始前に時間経過しても、画面表示する経過時間の文言に変化していないことを確認
        checkTimeStringZero(testViewModel)
        
        // タイムウォッチ開始
        dependencyDate.now = oneSecLapseTime
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        wait(for: [startLiveActivityExpectation], timeout: 1)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 99,
                                         addingMinute: 59,
                                         addingSec: 9,
                                         addingMilliSec: 999,
                                         expected: "99:59:09.999")
        
        wait(for: [updateLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチを停止
        testViewModel.tappedTimerActionButton(.stop)
        
        wait(for: [updateStopLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチをリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態がリセット状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        wait(for: [endLiveActivityExpectation], timeout: 1)
    }
    
    /// LiveActivity異常系動作確認
    ///
    /// ## 確認ポイント
    /// - ウォッチ開始時にLiveActivityのリクエストでエラーが発生しないこと
    /// - 開始中に時間経過でLiviActivityの更新リクエストがActivityがないため失敗すること
    /// - ウォッチ停止時にLiveActivityの更新リクエストがActivityがないため失敗すること
    /// - ウォッチリセット時にLiveActivityの終了リクエストがActivityがないため失敗すること
    @MainActor
    func testLiveActivityErrorUpdateAndEndCase() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        
        // LiveActivityのstart - endまで1回ずつ呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateStopLiveActivityExpectation = XCTestExpectation(description: "updateStopLiveActivityExpectation")
        updateStopLiveActivityExpectation.expectedFulfillmentCount = 1
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.expectedFulfillmentCount = 1
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               updateStopExpectation: updateStopLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [
                                                                [
                                                                    .hour: -99,
                                                                    .minute: -59,
                                                                    .second: -9
                                                                ],
                                                                [
                                                                    .hour: -99,
                                                                    .minute: -59,
                                                                    .second: -9
                                                                ]
                                                               ],
                                                               expectedTimeLapseMilliSec: [-999, -999],
                                                               expectedTimeLapseString: ["99:59:09", "99:59:09"],
                                                               needThrowUpdate: true,
                                                               needThrowEnd: true)
        
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 1秒経過
        guard let oneSecLapseTime = calendar.date(byAdding: .second, value: 1, to: currentDate) else {
            
            XCTFail("oneSecLapseTime is nil.")
            return
        }
        testTimerPublisher.send(oneSecLapseTime)
        
        // タイマー開始前に時間経過しても、画面表示する経過時間の文言に変化していないことを確認
        checkTimeStringZero(testViewModel)
        
        // タイムウォッチ開始
        dependencyDate.now = oneSecLapseTime
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        wait(for: [startLiveActivityExpectation], timeout: 1)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingHour: 99,
                                         addingMinute: 59,
                                         addingSec: 9,
                                         addingMilliSec: 999,
                                         expected: "99:59:09.999")
        
        wait(for: [updateLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチを停止
        testViewModel.tappedTimerActionButton(.stop)
        
        wait(for: [updateStopLiveActivityExpectation], timeout: 1)
        
        // タイムウォッチをリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態がリセット状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        wait(for: [endLiveActivityExpectation], timeout: 1)
    }
    
    /// Start中のLiveActivityのリセットボタン押下時の動作確認
    ///
    /// ## 確認ポイント
    /// - タイマー開始中にLiveActivityのリセットを謳歌するとリセット処理が行われること
    @MainActor
    func testTimerResetFromWidgetUrlOnStart() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        // LiveActivityのstart - endまで1回ずつ呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateStopLiveActivityExpectation = XCTestExpectation(description: "updateStopLiveActivityExpectation")
        updateStopLiveActivityExpectation.isInverted = true
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.expectedFulfillmentCount = 1
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               updateStopExpectation: updateStopLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [
                                                                [.second: -9],
                                                               ],
                                                               expectedTimeLapseMilliSec: [0],
                                                               expectedTimeLapseString: [
                                                                "00:00:09"
                                                               ])
        
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        wait(for: [startLiveActivityExpectation], timeout: 1)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        wait(for: [updateLiveActivityExpectation], timeout: 1)
        
        // リセットのURLでアプリが開かれたことを検知
        testViewModel.onOpenLiveActivityUrl(.timerResetLink)
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        wait(for: [endLiveActivityExpectation, updateStopLiveActivityExpectation], timeout: 1)
    }
    
    /// Stop中のLiveActivityのリセットボタン押下時の動作確認
    ///
    /// ## 確認ポイント
    /// - タイマー停止中にLiveActivityのリセットを謳歌するとリセット処理が行われること
    @MainActor
    func testTimerResetFromWidgetUrlOnStop() throws {
        
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        // LiveActivityのstart - endまで1回ずつ呼び出されること
        let startLiveActivityExpectation = XCTestExpectation(description: "startLiveActivityExpectation")
        startLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateLiveActivityExpectation = XCTestExpectation(description: "updateLiveActivityExpectation")
        updateLiveActivityExpectation.expectedFulfillmentCount = 1
        let updateStopLiveActivityExpectation = XCTestExpectation(description: "updateStopLiveActivityExpectation")
        updateStopLiveActivityExpectation.expectedFulfillmentCount = 1
        let endLiveActivityExpectation = XCTestExpectation(description: "endLiveActivityExpectation")
        endLiveActivityExpectation.expectedFulfillmentCount = 1
        
        let liveActivityManager = setupLiveActivityManagerMock(startExpectation: startLiveActivityExpectation,
                                                               updateTimeExpectation: updateLiveActivityExpectation,
                                                               updateStopExpectation: updateStopLiveActivityExpectation,
                                                               endExpectation: endLiveActivityExpectation,
                                                               expectedTimeLapseComponent: [
                                                                [.second: -9],
                                                                [.second: -9]
                                                               ],
                                                               expectedTimeLapseMilliSec: [0, 0],
                                                               expectedTimeLapseString: [
                                                                "00:00:09",
                                                                "00:00:09"
                                                               ])
        
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch,
                                               liveActivityMgr: liveActivityManager,
                                               dateDependency: dependencyDate)
        
        // 画面表示
        testViewModel.onAppear()
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        wait(for: [startLiveActivityExpectation], timeout: 1)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        wait(for: [updateLiveActivityExpectation], timeout: 1)
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        wait(for: [updateStopLiveActivityExpectation], timeout: 1)
        
        // リセットのURLでアプリが開かれたことを検知
        testViewModel.onOpenLiveActivityUrl(.timerResetLink)
        
        // ウォッチの状態が初期状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        wait(for: [endLiveActivityExpectation], timeout: 1)
    }
}

// MARK: - セットアップ機能

private extension MainTimerViewTest {
    
    func setupLiveActivityManagerMock(startExpectation: XCTestExpectation,
                                      updateTimeExpectation: XCTestExpectation,
                                      updateStopExpectation: XCTestExpectation,
                                      endExpectation: XCTestExpectation,
                                      expectedTimeLapseComponent: [[Calendar.Component: Int]],
                                      expectedTimeLapseMilliSec: [TimeInterval],
                                      expectedTimeLapseString: [String],
                                      needThrowStart: Bool = false,
                                      needThrowUpdate: Bool = false,
                                      needThrowEnd: Bool = false) -> LiveActivityManagerMock {
        
        var expectedTimeLapseComponents = expectedTimeLapseComponent
        var expectedTimeLapseMilliSecs = expectedTimeLapseMilliSec
        var expectedTimeLapseStrings = expectedTimeLapseString
        
        return LiveActivityManagerMock { _ in
            
            startExpectation.fulfill()
            
            if needThrowStart { throw ActivityAuthorizationError.unsupported }
        } updateProc: { state in
            
            if state.timerStatus == .start {
                
                updateTimeExpectation.fulfill()
            }
            else if state.timerStatus == .stop {
                
                updateStopExpectation.fulfill()
            }
            
            let minusMilliSec = TestUtilities.getAddingMilliSec(expectedTimeLapseMilliSecs.removeFirst(), to: self.dependencyDate.generateNow())
            let minusTimeLapse = TestUtilities.getTimeLapse(base: minusMilliSec,
                                                            adding: expectedTimeLapseComponents.removeFirst())
            let endDate = self.calendar.date(byAdding: .hour,
                                             value: 100,
                                             to: self.dependencyDate.generateNow()) ?? self.dependencyDate.generateNow()
            let actualState: TimeWatcherWidgetAttributes.ContentState = .init(timeLapse: minusTimeLapse...endDate,
                                                                              timeLapseString: expectedTimeLapseStrings.removeFirst(),
                                                                              timerStatus: state.timerStatus)
            XCTAssertEqual(state.timeLapse.lowerBound.toStringDate(), actualState.timeLapse.lowerBound.toStringDate())
            XCTAssertEqual(state.timeLapse.upperBound.toStringDate(), actualState.timeLapse.upperBound.toStringDate())
            XCTAssertEqual(state.timeLapseString, actualState.timeLapseString)
            XCTAssertEqual(state.timerStatus, actualState.timerStatus)
            
            if needThrowUpdate { throw LiveActivityRequestError.notFoundActivity }
        } stopProc: {
            
            endExpectation.fulfill()
            
            if needThrowEnd { throw LiveActivityRequestError.notFoundActivity }
        }
    }
}

// MARK: - チェック機能

@MainActor
private extension MainTimerViewTest {
    
    func checkTimerState(_ viewModel: MainTimerViewModel, expected: TimerStatus) {
        
        let expectation = XCTestExpectation(description: "timer status")
        
        let cancellable = viewModel.$timerStatus.dropFirst().sink { [weak self] status in
            
            guard let self else { return }
            
            XCTAssertEqual(status, expected)
            
            if expected == .initial {
                
                // 状態が初期状態のときは、表示経過時間も初期化されているか確認
                self.checkTimeStringZero(viewModel)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        cancellable.cancel()
    }
    
    func checkTimeStringZero(_ viewModel: MainTimerViewModel) {
        
        // 1秒後にも表示経過時間が初期のまま変わらないこと
        wait(1)
        XCTAssertEqual(viewModel.currentTimeString, "00:00:00.000")
    }
    
    func checkOverMaxTimeFlg(_ viewModel: MainTimerViewModel) {
        
        XCTAssertEqual(viewModel.isOverMaxTime, viewModel.currentTimeString == "99:59:59.999")
    }
    
    func checkDisplayStringAfterTimeLapse(testViewModel: MainTimerViewModel,
                                          addingHour: Int = .zero,
                                          addingMinute: Int = .zero,
                                          addingSec: Int = .zero,
                                          addingMilliSec: Int = .zero,
                                          expected: String = "00:00:00.000") {
        
        let expectation = XCTestExpectation(description: "checkDisplayStringAfterTimeLapse(currentDate=\(dependencyDate.generateNow().toStringDate()), hour=\(addingHour), minute=\(addingMinute), sec=\(addingSec), millisec=\(addingMilliSec))")
        
        print("current date before: \(dependencyDate.generateNow().toStringDate())")
        
        let addingMilliSecTime = TestUtilities.getAddingMilliSec(TimeInterval(addingMilliSec),
                                                                 to: dependencyDate.generateNow())
        let addingAllTime = TestUtilities.getTimeLapse(base: addingMilliSecTime,
                                                       adding: [
                                                        .hour: addingHour,
                                                        .minute: addingMinute,
                                                        .second: addingSec,
                                                       ]
        )
        
        // 経過時間を更新
        dependencyDate.now = addingAllTime
        
        print("current date after: \(dependencyDate.generateNow().toStringDate())")
        print("addingMilliSecTime: \(addingMilliSecTime.toStringDate())")
        print("addingAllTime: \(addingAllTime.toStringDate())")
        
        testTimerPublisher.send(TestUtilities.getTimeLapse(base: addingMilliSecTime,
                                                           adding: [
                                                            .hour: addingHour,
                                                            .minute: addingMinute,
                                                            .second: addingSec,
                                                           ]
                                                          )
        )
        
        waitUpdateDate(testViewModel, expectation: expectation, expected: expected)
        
        // 表示経過時間更新後の最大表示フラグの確認
        checkOverMaxTimeFlg(testViewModel)
        
        print("Success checkDisplayStringAfterTimeLapse.")
    }
    
    func waitUpdateDate(_ viewModel: MainTimerViewModel, expectation: XCTestExpectation, expected: String) {
        
        viewModel.$currentTimeString.sink { dateString in
            
            print("dateString: \(dateString), \(expected)")
            if dateString == expected {
                
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        cancellables.removeAll()
    }
    
    func wait(_ waitTime: TimeInterval) {
        
        let expectation = XCTestExpectation(description: "waiter")
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            
            print("wait time \(waitTime) sec.")
            expectation.fulfill()
        }
        XCTWaiter().wait(for: [expectation], timeout: waitTime + 1)
    }
}
