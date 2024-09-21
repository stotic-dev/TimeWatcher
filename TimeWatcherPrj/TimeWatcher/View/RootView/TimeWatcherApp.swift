//
//  TimeWatcherApp.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        logger.info("[In]")
        
        let liveActivityManager = LiveActivityManager()
        liveActivityManager.terminate()
    }
}

@main
@MainActor
struct TimeWatcherApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Deep Linkで開かれた際の情報を持つViewModel
    private var openUrlViewModel = OpenUrlViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTimerView(viewModel: MainTimerViewModel())
                .environmentObject(openUrlViewModel)
                .onOpenURL { url in
                    logger.info("URL: \(url)")
                    openUrlViewModel.setUrl(url)
                }
        }
    }
}
