//
//  FrameButtonStyle.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI

struct FrameButtonStyle: ButtonStyle {
    
    let foregroundColor: Color
    let backgroundColor: Color
    let pressedBackgroundColor: Color
    let frameWidth: CGFloat
    let radius: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foregroundColor)
            .background(configuration.isPressed ? pressedBackgroundColor : backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .overlay {
                RoundedRectangle(cornerRadius: radius).stroke(lineWidth: frameWidth)
            }
    }
}

extension Button {
    
    func frameButtonStyle(foregroundColor: Color = Color(CustomColor.timerActionForegroundColor),
                          backgroundColor: Color = Color(CustomColor.timerActionBackgroundColor),
                          pressedBackgroundColor: Color = Color(CustomColor.pressedBackgroundColor),
                          frameWidth: CGFloat = .zero,
                          radius: CGFloat = 8) -> some View {
        return self.buttonStyle(FrameButtonStyle(foregroundColor: foregroundColor,
                                                 backgroundColor: backgroundColor,
                                                 pressedBackgroundColor: pressedBackgroundColor,
                                                 frameWidth: frameWidth, radius: radius))
    }
}
