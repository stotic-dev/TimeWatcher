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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(CustomColor.primaryBackgroundColor)
                    .ignoresSafeArea()
                VStack(spacing: .zero) {
                    createTimerDisplayView()
                    Divider()
                    Spacer()
                        .frame(height: 50)
                    createTimerActionView()
                    Spacer()
                }
            }
        }
    }
}

private extension MainTimerView {
    
    func createTimerDisplayView() -> some View {
        Text("00:00.001")
            .font(.system(size: 45, weight: .bold))
            .foregroundStyle(Color(asset: CustomColor.timerTextColor))
            .frame(maxWidth: .infinity, maxHeight: 300)
    }
    
    func createTimerActionView() -> some View {
        HStack(spacing: 100) {
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
                .font(.system(size: 18, weight: .bold))
                .frame(width: 80, height: 80)
        }
        .frameButtonStyle(radius: 40)
        .shadow(radius: 5, y: 4)
    }
}

#Preview {
    MainTimerView(viewModel: MainTimerViewModel())
}
