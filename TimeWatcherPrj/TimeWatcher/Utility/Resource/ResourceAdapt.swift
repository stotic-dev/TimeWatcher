//
//  ResourceAdapt.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import TimeWatcherExternalResouce
import SwiftUI

typealias CustomColor = Asset.Color
typealias CustomImage = Asset.Image

extension Color {
    
    init(_ custom: ColorAsset) {
        
        self.init(asset: custom)
    }
}

extension Image {
    
    init(_ custom: ImageAsset) {
        
        self.init(asset: custom)
    }
}
