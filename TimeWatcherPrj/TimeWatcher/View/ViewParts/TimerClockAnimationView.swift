//
//  TimerClockAnimationView.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/14.
//

import SwiftUI

struct TimerClockAnimationView: View {
    
    // MARK: - layout static property
    
    private let initialPointDegrees: CGFloat = -90
    private let unProgressAreaOpacity: CGFloat = 0.2
    private let progressRotationAngle: CGFloat = 720
        
    // MARK: - input parameter
    
    private let progress: Double
    @State private var postProgress: Double = .zero
    @State private var progressAngle: CGFloat = .zero
    
    private let size: CGFloat
    private let lineWidth: CGFloat
    private let progressColor: Color
    
    // MARK: - computedProperty
    
    private var startPoint: Double {
        
        return progressPoint >= 0.5 ? 0.5 : .zero
    }
    
    private var progressPoint: Double {
        
        return progress >= 1 ? progress.truncatingRemainder(dividingBy: 1) : progress
    }
        
    init(progress: Double,
         size: CGFloat,
         lineWidth: CGFloat = 10,
         progressColor: Color = Color(CustomColor.timerActionBackgroundColor)) {
        
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.progressColor = progressColor
    }
    
    // MARK: - view body property
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: .zero, to: 1)
                .stroke(lineWidth: lineWidth)
                .rotation(.degrees(initialPointDegrees))
                .foregroundStyle(progressColor.opacity(unProgressAreaOpacity))
                .frame(maxWidth: size, maxHeight: size)
            Circle()
                .trim(from: startPoint, to: progressPoint)
                .stroke(lineWidth: lineWidth)
                .rotation(.degrees(initialPointDegrees))
                .foregroundStyle(progressColor)
                .frame(maxWidth: size, maxHeight: size)
                .animation(.spring, value: progress)
        }
        .rotationEffect(.degrees(progressAngle))
        .onChange(of: progress) { _, newValue in
            if floor(postProgress) != floor(newValue) {
                withAnimation(.spring) {
//                    print("withAnimation oldValue=\(postProgress), newValue=\(newValue)")
                    progressAngle += progressRotationAngle
                }
            }
            else {
//                print("oldValue=\(postProgress), newValue=\(newValue)")
                progressAngle = .zero
            }
            postProgress = newValue
        }
    }
}

// MARK: - preview

#Preview {
        
    struct PreviewTimerClockAnimationView: View {
        
        @State private var progress: Double = .zero
        
        var body: some View {
            VStack {
                TimerClockAnimationView(progress: progress,
                                        size: 300)
                Spacer()
                    .frame(height: 20)
                HStack {
                    Button {
                        progress += 0.99
                    } label: {
                        Text("+ 0.99")
                    }
                    Button {
                        progress += 0.1
                    } label: {
                        Text("+ 0.1")
                    }
                    Button {
                        progress += 0.001
                    } label: {
                        Text("+ 0.001")
                    }
                }
            }
        }
    }
    
    return PreviewTimerClockAnimationView()
}
