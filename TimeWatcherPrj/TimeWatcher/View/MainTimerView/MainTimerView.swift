//
//  MainTimerView.swift
//  TimeWatcher
//
//  Created by 佐藤汰一 on 2024/09/11.
//

import SwiftUI
import TimeWatcherExternalResouce

struct MainTimerView: View {
    
    @StateObject var viewModel: MainTimerViewModel
    @EnvironmentObject var openUrlViewModel: OpenUrlViewModel
    
    // MARK: - layout property
    
    private let actionButtonTopPadding: CGFloat = 50
    private let emergencyTextTopPadding: CGFloat = 20
    private let emergencyTextHorizontalPadding: CGFloat = 30
    private let actionButtonSpacing: CGFloat = 100
    
    private let displayTextAreaHeight: CGFloat = 300
    private let actionButtonSize: CGFloat = 80
    
    private let displayTimeFontSize: CGFloat = 45
    private let emergencyTextFontSize: CGFloat = 18
    private let actionButtonTextFontSize: CGFloat = 18
    
    private let actionButtonShadowRadius: CGFloat = 5
    private let actionButtonShadowY: CGFloat = 4
    
    // MARK: - view body property
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(CustomColor.primaryBackgroundColor)
                    .ignoresSafeArea()
                VStack(spacing: .zero) {
                    createTimerDisplayView()
                    Divider()
                    Spacer()
                        .frame(height: actionButtonTopPadding)
                    createTimerActionView()
                    Spacer()
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onReceive(openUrlViewModel.$widgetUrlKey.compactMap { $0 }) { widgetUrl in
            viewModel.onOpenLiveActivityUrl(widgetUrl)
        }
    }
}

// MARK: - private method

private extension MainTimerView {
    
    func createTimerDisplayView() -> some View {
        VStack(spacing: .zero) {
            Text(viewModel.currentTimeString)
                .font(.system(size: displayTimeFontSize, weight: .bold))
                .foregroundStyle(Color(asset: CustomColor.timerTextColor))
            if viewModel.isOverMaxTime {
                Spacer()
                    .frame(height: emergencyTextTopPadding)
                Text("最大表経過時間を超過しているため、これ以上は計測できません。")
                    .font(.system(size: emergencyTextFontSize))
                    .foregroundStyle(Color(CustomColor.emergencyColor))
                    .padding(.horizontal, emergencyTextHorizontalPadding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: displayTextAreaHeight)
    }
    
    func createTimerActionView() -> some View {
        HStack(spacing: actionButtonSpacing) {
            ForEach(viewModel.timerStatus.useableActions, id: \.self) {
                createTimerActionButton($0)
            }
        }
        .animation(.spring, value: viewModel.timerStatus)
    }
    
    func createTimerActionButton(_ type: TimerActionType) -> some View {
        Button {
            viewModel.tappedTimerActionButton(type)
        } label: {
            Text(type.buttonTitle)
                .font(.system(size: actionButtonTextFontSize,
                              weight: .bold))
                .frame(width: actionButtonSize,
                       height: actionButtonSize)
        }
        .frameButtonStyle(radius: actionButtonSize / 2)
        .shadow(radius: actionButtonShadowRadius,
                y: actionButtonShadowY)
    }
}

#Preview("通常時") {
    MainTimerView(viewModel: MainTimerViewModel())
        .environmentObject(OpenUrlViewModel())
}

#Preview("最大表示可能経過時間超過時") {
    MainTimerView(viewModel: MainTimerViewModel(isOverMaxTime: true))
        .environmentObject(OpenUrlViewModel())
}
