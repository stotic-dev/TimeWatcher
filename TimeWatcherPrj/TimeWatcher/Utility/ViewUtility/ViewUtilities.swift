//
//  ViewUtilities.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/25.
//

import UIKit

struct ViewUtilities {
    
    /// 現在の画面がPortlateかどうか
    static var isPortrait: Bool {
        
        return UIDevice.current.orientation.isPortrait
    }
}
