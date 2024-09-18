//
//  TimeWatcherApp.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

@main
struct TimeWatcherApp: App {
    
    var body: some Scene {
        WindowGroup {
            MainTimerView(viewModel: MainTimerViewModel())
                .onOpenURL { url in
                    logger.info("URL: \(url)")
                }
        }
    }
}
