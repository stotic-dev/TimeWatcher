//
//  TimeWatcherWidgetLiveActivity.swift
//  TimeWatcherWidget
//
//  Created by 佐藤汰一 on 2024/09/13.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - TimeWatcherWidgetAttributes Definition

struct TimeWatcherWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        
        /// 経過時間のフル表示
        var timeLapseString: String
        /// 経過時間の短尺表示
        var timelapseShortString: String
        /// 経過時間の1分単位の進捗
        var timeLapseProgress: Double
        /// タイマーの状態
        var timerStatus: TimerStatus
    }
}

// MARK: - TimeWatcherWidgetLiveActivity Widget Definition

struct TimeWatcherWidgetLiveActivity: Widget {
    
    // MARK: layout property
    
    private let liveActivityHorizontalPadding: CGFloat = 20
    private let actionButtonIconPadding: CGFloat = 15
    private let actionButtonSpacing: CGFloat = 10
    private let shortTimeClockPadding: CGFloat = 4
    
    private let largeTimeLapseTextFontSize: CGFloat = 24
    private let shortTimeLapseTextFontSize: CGFloat = 14
    
    private let largeTimeClockSize: CGFloat = 50
    private let shortTimeClockSize: CGFloat = 20
    private let actionButtonIconSize: CGFloat = 40
    private let shortTimeClockLineWidth: CGFloat = 2
    
    // MARK: live activity view body property
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeWatcherWidgetAttributes.self) { context in
            HStack(spacing: .zero) {
                createActionButtonView(useableActions: context.state.timerStatus.useableActions)
                Spacer()
                Text(context.state.timeLapseString)
                    .font(.system(size: largeTimeLapseTextFontSize, weight: .bold))
                    .foregroundStyle(Color(CustomColor.timerTextColor))
            }
            .padding(.horizontal, liveActivityHorizontalPadding)
            .activityBackgroundTint(Color(CustomColor.primaryBackgroundColor))
            .activitySystemActionForegroundColor(Color(CustomColor.primaryForegroundColor))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    createActionButtonView(useableActions: context.state.timerStatus.useableActions)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TimerClockAnimationView(progress: context.state.timeLapseProgress,
                                            size: largeTimeClockSize)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.timeLapseString)
                        .font(.system(size: largeTimeLapseTextFontSize, weight: .bold))
                        .foregroundStyle(Color(CustomColor.timerTextColor))
                        .frame(maxHeight: .infinity)
                }
            } compactLeading: {
                createMiniTimeClockView(context.state.timeLapseProgress)
            } compactTrailing: {
                Text(context.state.timelapseShortString)
                    .font(.system(size: shortTimeLapseTextFontSize, weight: .bold))
                    .foregroundStyle(Color(CustomColor.timerTextColor))
            } minimal: {
                createMiniTimeClockView(context.state.timeLapseProgress)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
        }
    }
}

// MARK: - private TimeWatcherWidgetLiveActivity method

private extension TimeWatcherWidgetLiveActivity {
    
    func createActionButtonView(useableActions: [TimerActionType]) -> some View {
        HStack(spacing: actionButtonSpacing) {
            ForEach(useableActions, id: \.self) { type in
                Button {
                    
                } label: {
                    Image(systemName: type.buttonIconName)
                        .resizable()
                        .padding(actionButtonIconPadding)
                        .frame(width: actionButtonIconSize,
                               height: actionButtonIconSize)
                        .accessibilityHidden(true)
                }
                .frameButtonStyle(radius: actionButtonIconSize / 2)
            }
        }
    }
    
    func createMiniTimeClockView(_ progress: Double) -> some View {
        TimerClockAnimationView(progress: progress,
                                size: shortTimeClockSize,
                                lineWidth: shortTimeClockLineWidth)
        .padding(shortTimeClockPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TimeWatcherWidgetAttributes definition for preview

extension TimeWatcherWidgetAttributes {
    
    fileprivate static var preview: TimeWatcherWidgetAttributes {
        TimeWatcherWidgetAttributes()
    }
}

extension TimeWatcherWidgetAttributes.ContentState {
    
    fileprivate static var initial: TimeWatcherWidgetAttributes.ContentState {
        TimeWatcherWidgetAttributes.ContentState(timeLapseString: "00:00:00.000",
                                                 timelapseShortString: "00:00:00",
                                                 timeLapseProgress: 0.2,
                                                 timerStatus: .initial)
     }
     
     fileprivate static var start: TimeWatcherWidgetAttributes.ContentState {
         TimeWatcherWidgetAttributes.ContentState(timeLapseString: "00:01:12.999",
                                                  timelapseShortString: "00:01:12",
                                                  timeLapseProgress: 0.5,
                                                  timerStatus: .start)
     }
    
    fileprivate static var stop: TimeWatcherWidgetAttributes.ContentState {
        TimeWatcherWidgetAttributes.ContentState(timeLapseString: "00:02:12.101",
                                                 timelapseShortString: "00:02:12",
                                                 timeLapseProgress: 1.4,
                                                 timerStatus: .stop)
    }
}

// MARK: - preview definition

#Preview("Notification", as: .content, using: TimeWatcherWidgetAttributes.preview) {
   TimeWatcherWidgetLiveActivity()
} contentStates: {
    TimeWatcherWidgetAttributes.ContentState.initial
    TimeWatcherWidgetAttributes.ContentState.start
    TimeWatcherWidgetAttributes.ContentState.stop
}

#Preview("Compact", as: .dynamicIsland(.compact), using: TimeWatcherWidgetAttributes.preview) {
    TimeWatcherWidgetLiveActivity()
} contentStates: {
    TimeWatcherWidgetAttributes.ContentState.initial
    TimeWatcherWidgetAttributes.ContentState.start
    TimeWatcherWidgetAttributes.ContentState.stop
}

#Preview("Expanded", as: .dynamicIsland(.expanded), using: TimeWatcherWidgetAttributes.preview) {
    TimeWatcherWidgetLiveActivity()
} contentStates: {
    TimeWatcherWidgetAttributes.ContentState.initial
    TimeWatcherWidgetAttributes.ContentState.start
    TimeWatcherWidgetAttributes.ContentState.stop
}

#Preview("Minimal", as: .dynamicIsland(.minimal), using: TimeWatcherWidgetAttributes.preview) {
    TimeWatcherWidgetLiveActivity()
} contentStates: {
    TimeWatcherWidgetAttributes.ContentState.initial
    TimeWatcherWidgetAttributes.ContentState.start
    TimeWatcherWidgetAttributes.ContentState.stop
}
