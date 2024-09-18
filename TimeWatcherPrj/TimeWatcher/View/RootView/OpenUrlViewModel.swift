//
//  OpenUrlViewModel.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/18.
//

import Foundation

@MainActor
class OpenUrlViewModel: ObservableObject {
    
    /// LiveActivityから開かれた際のURL
    @Published var widgetUrlKey: WidgetUrlKey?
    
    /// 開かれたURLの設定
    func setUrl(_ url: URL) {
                
        guard let widgetURL = WidgetUrlKey.allCases.first(where: { $0.url == url }) else {
            
            logger.debug("Not found widget url: \(url).")
            return
        }
        
        logger.info("Did open widget url: \(widgetURL).")
        widgetUrlKey = widgetURL
    }
}
