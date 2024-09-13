//
//  MainTimerViewTest.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/12.
//

import Combine
import XCTest
@testable import TimeWatcher

final class MainTimerViewTest: XCTestCase {
    
    private var currentDate: Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: "20000101")!
    }
    private let testTimerPublisher = PassthroughSubject<Date, Never>()
    private let calendar = Calendar(identifier: .gregorian)
    
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        
        cancellables.removeAll()
    }

    @MainActor
    func testTappedStartWatch() throws {
                
        let dependencyDate = DateDependency(now: currentDate)
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch)
        
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
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingHour: 99,
                                         addingMinute: 59,
                                         addingSec: 9,
                                         addingMilliSec: 999,
                                         expected: "99:59:09.999")
    }
    
    @MainActor
    func testTappedStopWatch() throws {
                
        let dependencyDate = DateDependency(now: currentDate)
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.second: 9])
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 経過時間表示文字が正しく更新されていることを確認
        let stoppedTime = getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 3])
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: stoppedTime,
                                         addingHour: 1, addingMinute: 59, addingSec: 50,
                                         expected: "00:00:09.000")
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: stoppedTime,
                                          adding: [.hour: 1, .minute: 59, .second: 50])
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
                
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingHour: 1, addingMinute: 59, addingSec: 50,
                                         expected: "01:59:59.000")
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(),
                                          adding: [.hour: 1, .minute: 59, .second: 50])
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 1])
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingHour: 99,
                                         expected: "99:59:59.999")
    }
    
    @MainActor
    func testTappedResetWatch() throws {
                
        let dependencyDate = DateDependency(now: currentDate)
        let testTimeWatch = TimeWatch(publisher: testTimerPublisher.eraseToAnyPublisher(),
                                      currentTime: dependencyDate)
        let testViewModel = MainTimerViewModel(timeWatch: testTimeWatch)
        
        // タイムウォッチ開始
        dependencyDate.now = currentDate
        testViewModel.tappedTimerActionButton(.start)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingSec: 9,
                                         expected: "00:00:09.000")
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.second: 9])
        
        // ウォッチの停止
        testViewModel.tappedTimerActionButton(.stop)
        
        // ウォッチの状態が停止状態になっていることの確認
        checkTimerState(testViewModel, expected: .stop)
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 3])
        
        // タイムウォッチリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.minute: 3])
                
        // 経過時間表示文字が正しく更新されていることを確認
        testTimerPublisher.send(dependencyDate.generateNow())
        
        // 表示経過時間に変更がないことの確認
        checkTimeStringZero(testViewModel)
        
        // 現在時間の更新
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 1])
        
        // タイムウォッチ開始
        testViewModel.tappedTimerActionButton(.start)
        
        // 経過時間表示文字が正しく更新されていることを確認
        checkDisplayStringAfterTimeLapse(testViewModel: testViewModel,
                                         currentDate: dependencyDate.generateNow(),
                                         addingHour: 1,
                                         addingMilliSec: 201,
                                         expected: "01:00:00.201")
        
        // 現在時間の更新
        dependencyDate.now = getAddingMilliSec(201, to: dependencyDate.generateNow())
        dependencyDate.now = getTimeLapse(base: dependencyDate.generateNow(), adding: [.hour: 1])
        
        // タイムウォッチリセット
        testViewModel.tappedTimerActionButton(.reset)
        
        // ウォッチの状態が開始状態になっていることの確認
        checkTimerState(testViewModel, expected: .initial)
    }
}

@MainActor
private extension MainTimerViewTest {
    
    func checkTimerState(_ viewModel: MainTimerViewModel, expected: TimerStatus) {
        
        XCTAssertEqual(viewModel.timerStatus, expected)
        
        if expected == .initial {
            
            // 状態が初期状態のときは、表示経過時間も初期化されているか確認
            checkTimeStringZero(viewModel)
        }
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
                                          currentDate: Date,
                                          addingHour: Int = .zero,
                                          addingMinute: Int = .zero,
                                          addingSec: Int = .zero,
                                          addingMilliSec: Int = .zero,
                                          expected: String = "00:00:00.000") {
        
        let expectation = XCTestExpectation(description: "checkDisplayStringAfterTimeLapse(currentDate=\(currentDate.toStringDate()), hour=\(addingHour), minute=\(addingMinute), sec=\(addingSec), millisec=\(addingMilliSec))")
        
        let addingMilliSecTime = getAddingMilliSec(TimeInterval(addingMilliSec), to: currentDate)
        let addingAllTime = getTimeLapse(base: addingMilliSecTime,
                                         adding: [
                                            .hour: addingHour,
                                            .minute: addingMinute,
                                            .second: addingSec,
                                         ]
                                        )
        
        print("current: \(currentDate.toStringDate())")
        print("addingMilliSecTime: \(addingMilliSecTime.toStringDate())")
        print("addingAllTime: \(addingAllTime.toStringDate())")
        
        testTimerPublisher.send(getTimeLapse(base: addingMilliSecTime,
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

private extension MainTimerViewTest {
    
    func getTimeLapse(base: Date, adding: [Calendar.Component: Int]) -> Date {
        
        return adding.reduce(into: base) {
            
            $0 = calendar.date(byAdding: $1.key, value: $1.value, to: $0) ?? $0
        }
    }
    
    func getAddingMilliSec(_ millisec: TimeInterval, to: Date) -> Date {
        
        let dateTime = to.timeIntervalSince1970MiliSec + millisec
        return Date(timeIntervalSince1970: dateTime / 1000)
    }
}
