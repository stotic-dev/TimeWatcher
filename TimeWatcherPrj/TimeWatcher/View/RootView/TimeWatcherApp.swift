//
//  TimeWatcherApp.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

@main
@MainActor
struct TimeWatcherApp: App {
    
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
