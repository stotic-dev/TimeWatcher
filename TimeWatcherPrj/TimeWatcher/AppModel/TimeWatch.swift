//
//  TimeWatch.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import Combine
import Foundation

@MainActor
class TimeWatch {
    
    static let shared = TimeWatch()
    
    /// タイマーの起動状態監視用のPublisher
    private let timerStatusPublisher = CurrentValueSubject<TimerStatus, Never>(.initial)
    
    /// 現在の時間
    private var currentTime: DateDependency
    /// タイマーを開始した時の時間
    private var startTime: Date?
    /// タイマー一時停止した時の総時間
    private var addedTime: TimeInterval?
    /// 検知した時間経過を外部に伝えるクロージャ
    private var timeLapseHandler: ((TimeInterval) -> Void)?
    /// タイマー監視のバブリッシャー
    private let timerPublisher: AnyPublisher<Date, Never>
    /// タイマー監視用のキャンセラブル
    private var timerCancellable: AnyCancellable?
    /// 現在の総経過時間
    private var currentTimeLapse: TimeInterval = .zero
    
    /// 時間計測の間隔
    private static let timeWatchInterval = 0.001
    
    /// - Parameters:
    ///    - publisher: 時間経過監視のPublisher
    ///    - currentTime: 現在の時間
    /// - Attention: publisherの引数はテスト時など時間経過監視の処理を制御する用途で設定するので、
    /// プロダクトコードでは設定しないようにする.
    /// currentTimeについてもテスト用に現在の時間を制御したい場合に設定する
    init(publisher: AnyPublisher<Date, Never>? = nil,
         currentTime: DateDependency = DateDependency()) {
        
        logger.info("[In] testPublisher: \(String(describing: publisher))")
        
        if let publisher {
            
            self.timerPublisher = publisher
        }
        else {
            
            self.timerPublisher = Timer.publish(every: Self.timeWatchInterval,
                                                on: .main,
                                                in: .common).autoconnect().eraseToAnyPublisher()
        }
        
        self.currentTime = currentTime
    }
    
    deinit {
        
        logger.info("[In]")
    }
    
    /// タイマー状態監視用のPublisherを返す
    func createTimerStatusPublisher() -> AnyPublisher<TimerStatus, Never> {
        
        return timerStatusPublisher.eraseToAnyPublisher()
    }
    
    /// timeWatchIntervalの間隔ごとに経過時間を通知するクロージャを設定する
    func setTimerHandler(timeLapseHandler: @escaping (TimeInterval) -> Void) {
        
        self.timeLapseHandler = timeLapseHandler
    }
    
    /// タイムウォッチを開始する
    func startTimer() {
        
        // 状態更新
        timerStatusPublisher.send(.start)
        
        self.startTime = currentTime.generateNow()
        
        logger.debug("startTime: \(String(describing: startTime?.toStringDate()))")
        
        // タイマー起動
        observeTime(timerPublisher)
    }
    
    /// タイムウォッチを終了する
    func stopTimer() {
        
        // 状態更新
        timerStatusPublisher.send(.stop)
        
        // 現在のタイマーを停止する
        timerCancellable?.cancel()
        
        guard let startTime else {
            
            assertionFailure("startTime is nil")
            return
        }
        
        // 現在の計測時間の総計を更新
        let totalTimeLapse = currentTime.generateNow().timeIntervalSince(startTime)
        addedTime = addedTime == nil ? totalTimeLapse : addedTime! + totalTimeLapse
        
        logger.debug("addedTime : \(String(describing: addedTime))")
    }
    
    /// タイムウォッチを終了して、経過時間を0に戻す
    func resetTimer() {
        
        // 状態更新
        timerStatusPublisher.send(.initial)
        
        // 現在のタイマーを停止する
        timerCancellable?.cancel()
        
        // 計測時間の総計をリセットする
        addedTime = nil
        
        // 外部にリセットした計測時間を送信する
        timeLapseHandler?(.zero)
    }
    
    /// 現在の経過時間総計を返す
    func getCurrentTimeLapse() -> TimeInterval {
        
        return currentTimeLapse
    }
}

// MARK: - private method

private extension TimeWatch {
    
    func observeTime(_ timePublisher: AnyPublisher<Date, Never>) {
        
        timerCancellable = timePublisher.receive(on: DispatchQueue.main).sink { [weak self] date in
            
            guard let self = self,
                  let startTime = self.startTime else { return }
            
            // 現在の総経過時間の更新
            currentTimeLapse = date.timeIntervalSince(startTime) + (addedTime ?? .zero)
            // 経過時間を外部に連携
            self.timeLapseHandler?(currentTimeLapse)
        }
    }
}
