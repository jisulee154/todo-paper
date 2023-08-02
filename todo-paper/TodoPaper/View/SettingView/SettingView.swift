//
//  SettingView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/02.
//

import SwiftUI

struct SettingView: View {
    @StateObject var settingViewModel: SettingViewModel = SettingViewModel()
    @ObservedObject var todoViewModel: TodoViewModel
    
    var body: some View {
        ZStack {
            // 상단 뒤로가기 버튼
            makeGoBackButton()
                .zIndex(1)
            
            // 설정 항목 목록
            makeSettingList()
                .zIndex(0)
        }
    }
    
    private func makeGoBackButton() -> some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    todoViewModel.showSettingView.toggle()
                } label: {
                    Text("뒤로가기")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            Spacer()
        }
    }
    
    private func makeSettingList() -> some View {
        NavigationView {
            Form {
                Section("알림 설정") {
                    // 당일 할일 알림 받기
                    Toggle(isOn: $settingViewModel.isTodoNotificationOn) {
                        Text("투두 알림 받기")
                    }
                    
                    // 완료 스티커 붙이기 알림
                    Toggle(isOn: $settingViewModel.isStickerNotificationOn) {
                        Text("완료 스티커 알림 받기")
                    }
                }
                
                Section("투두 설정") {
                    // 포기한 일 숨기기
                    Toggle(isOn: $settingViewModel.isHideGaveUpTaskOn) {
                        Text("포기한 투두 숨기기")
                    }
                }
            }.navigationTitle("설정")
        }
    }
}
