//
//  TimeWatcherWidgetLiveActivity.swift
//  TimeWatcherWidget
//
//  Created by 佐藤汰一 on 2024/09/13.
//

import ActivityKit
import AppIntents
import WidgetKit
import SwiftUI

// MARK: - TimeWatcherWidgetAttributes Definition

struct TimeWatcherWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        
        init(timeLapse: TimeInterval, currentDate: Date, timeLapseString: String, timerStatus: TimerStatus) {
            
            let minusMilliSec = Calendar.current.date(byAdding: -timeLapse.milliSec,
                                                      to: currentDate)
            let startRangeDate = Calendar.current.date(byAdding: [
                .hour: -timeLapse.hour,
                .minute: -timeLapse.minute,
                .second: -timeLapse.seconds
            ],
                                                       to: minusMilliSec)
            let endRangeDate = Calendar.current.date(byAdding: .hour,
                                                     value: AppConstants.maxDisplayTime,
                                                     to: currentDate) ?? currentDate
            
            self.timeLapse = startRangeDate...endRangeDate
            self.timeLapseString = timeLapseString
            self.timerStatus = timerStatus
        }
        
        init(timeLapse: ClosedRange<Date>, timeLapseString: String, timerStatus: TimerStatus) {
            
            self.timeLapse = timeLapse
            self.timeLapseString = timeLapseString
            self.timerStatus = timerStatus
        }
        
        /// 経過時間
        var timeLapse: ClosedRange<Date>
        /// 経過時間の文字列
        var timeLapseString: String
        /// タイマーの状態
        var timerStatus: TimerStatus
        
        var useableActions: [TimerActionType] {
            
            return timerStatus.useableActions
        }
        
        var statusIcon: String {
            
            return timerStatus.icon
        }
    }
}

// MARK: - TimeWatcherWidgetLiveActivity Widget Definition

struct TimeWatcherWidgetLiveActivity: Widget {
    
    // MARK: layout property
    
    private let liveActivityHorizontalPadding: CGFloat = 20
    private let actionButtonIconPadding: CGFloat = 15
    private let actionButtonSpacing: CGFloat = 10
    private let shortTimeClockPadding: CGFloat = 6
    
    private let largeTimeLapseTextFontSize: CGFloat = 24
    private let shortTimeLapseTextFontSize: CGFloat = 14
    
    private let largeTimeClockSize: CGFloat = 50
    private let shortTimeClockSize: CGFloat = 20
    private let actionButtonIconSize: CGFloat = 40
    private let shortTimeClockLineWidth: CGFloat = 2
    private let compactTextWidth: CGFloat = 65
    private let expandedTextWidth: CGFloat = 110
    private let contentTimerTextWidth: CGFloat = 120
    
    // MARK: live activity view body property
    
    @MainActor
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeWatcherWidgetAttributes.self) { context in
            HStack(spacing: .zero) {
                createActionButtonView(useableActions: context.state.timerStatus.useableActions,
                                       token: context.activityID)
                Spacer()
                createTimeLapseText(status: context.state.timerStatus,
                                    timeLapseString: context.state.timeLapseString,
                                    timerInterval: context.state.timeLapse,
                                    fontSize: largeTimeLapseTextFontSize,
                                    timerTextWidth: contentTimerTextWidth)
            }
            .padding(.horizontal, liveActivityHorizontalPadding)
            .activityBackgroundTint(Color(CustomColor.primaryBackgroundColor))
            .activitySystemActionForegroundColor(Color(CustomColor.primaryForegroundColor))
            .widgetURL(WidgetUrlKey.defaultLink.url)
        } dynamicIsland: { context in
            DynamicIsland { // MARK: Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    createActionButtonView(useableActions: context.state.useableActions,
                                           token: context.activityID)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: .zero) {
                        Spacer()
                        createTimeLapseText(status: context.state.timerStatus,
                                            timeLapseString: context.state.timeLapseString,
                                            timerInterval: context.state.timeLapse,
                                            fontSize: largeTimeLapseTextFontSize,
                                            timerTextWidth: expandedTextWidth)
                    }
                    .frame(maxHeight: .infinity)
                }
            } compactLeading: { // MARK: Compact View
                createMiniStatusIconView(context.state.statusIcon)
            } compactTrailing: {
                createTimeLapseText(status: context.state.timerStatus,
                                    timeLapseString: context.state.timeLapseString,
                                    timerInterval: context.state.timeLapse,
                                    fontSize: shortTimeLapseTextFontSize,
                                    timerTextWidth: compactTextWidth)
            } minimal: { // MARK: Minimal View
                createMiniStatusIconView(context.state.statusIcon)
            }
            .widgetURL(WidgetUrlKey.defaultLink.url)
        }
    }
}

// MARK: - private TimeWatcherWidgetLiveActivity method

@MainActor
private extension TimeWatcherWidgetLiveActivity {
    
    func createActionButtonView(useableActions: [TimerActionType], token: String) -> some View {
        HStack(spacing: actionButtonSpacing) {
            ForEach(useableActions, id: \.self) { type in
                if type == .reset {
                    Link(destination: WidgetUrlKey.timerResetLink.url) {
                        Image(systemName: type.buttonIconName)
                            .resizable()
                            .padding(actionButtonIconPadding)
                            .frame(width: actionButtonIconSize,
                                   height: actionButtonIconSize)
                            .accessibilityHidden(true)
                            .foregroundStyle(Color(CustomColor.timerActionForegroundColor))
                            .background(Color(CustomColor.timerActionBackgroundColor))
                            .clipShape(Circle())
                    }
                }
                else {
                    Button(intent: type.getIntent()) {
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
    }
    
    func createMiniStatusIconView(_ icon: String) -> some View {
        Image(systemName: icon)
            .resizable()
            .padding(shortTimeClockPadding)
            .frame(width: shortTimeClockSize, height: shortTimeClockSize)
            .foregroundStyle(Color(CustomColor.timerActionForegroundColor))
            .background(Color(CustomColor.timerActionBackgroundColor))
            .clipShape(Circle())
    }
    
    func createTimeLapseText(status: TimerStatus,
                             timeLapseString: String,
                             timerInterval: ClosedRange<Date>,
                             fontSize: CGFloat,
                             timerTextWidth: CGFloat) -> some View {
        Group {
            if status == .stop {
                Text(timeLapseString)
                    .fixedSize(horizontal: true, vertical: false)
            }
            else {
                Text(timerInterval: timerInterval,
                     countsDown: false,
                     showsHours: true)
                .monospacedDigit()
                .frame(width: timerTextWidth)
            }
        }
        .font(.system(size: fontSize, weight: .bold))
        .foregroundStyle(Color(CustomColor.timerTextColor))
    }
}

fileprivate extension TimerActionType {
    
    @MainActor
    func getIntent() -> any AppIntent {
        
        let result: (any AppIntent)? = switch self {
            
        case .start:
            TimerStartIntent()
            
        case .stop:
            TimerStopIntent()
            
        case .reset: nil
        }
        
        guard let result else {
            
            assertionFailure("Invalid type: \(self)")
            return TimerStopIntent()
        }
        
        return result
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
        return TimeWatcherWidgetAttributes.ContentState(timeLapse: Calendar.current.date(byAdding: .hour, value: -99, to: Date.now)!...Calendar.current.date(byAdding: .hour, value: 100, to: Date.now)!,
                                                        timeLapseString: "01:12:12",
                                                        timerStatus: .initial)
    }
     
     fileprivate static var start: TimeWatcherWidgetAttributes.ContentState {
         TimeWatcherWidgetAttributes.ContentState(timeLapse: Calendar.current.date(byAdding: .minute, value: -12, to: Date.now)!...Calendar.current.date(byAdding: .hour, value: 100, to: Date.now)!,
                                                  timeLapseString: "01:12:12",
                                                  timerStatus: .start)
     }
    
    fileprivate static var stop: TimeWatcherWidgetAttributes.ContentState {
        TimeWatcherWidgetAttributes.ContentState(timeLapse: Calendar.current.date(byAdding: .second, value: -10, to: Date.now)!...Calendar.current.date(byAdding: .hour, value: 100, to: Date.now)!,
                                                 timeLapseString: "01:12:12",
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
