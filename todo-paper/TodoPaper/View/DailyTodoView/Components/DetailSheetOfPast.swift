//
//  DetailSheetOfPast.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import SwiftUI
import BottomSheet

//MARK: - 상세 설정 시트 (과거)
struct DetailSheetOfPast: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    
    init(todoViewModel: TodoViewModel, detailTodoViewModel: DetailTodoViewModel, settingViewModel: SettingViewModel) {
        self.todoViewModel = todoViewModel
        self.detailTodoViewModel = detailTodoViewModel
        self.settingViewModel = settingViewModel
    }
    
    var body: some View {
        Color.clear
            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.settingBottomSheetPosition,
                         switchablePositions:[.dynamicBottom,.relative(0.7)],
                         headerContent: {
                Text("상세 설정")
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
            }) {
                VStack (spacing: 10) {
                    Button {
//                        detailTodoViewModel.isDetailSheetShowing.toggle()
//                        detailTodoViewModel.isDatePickerShowing.toggle()
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        detailTodoViewModel.datePickerBottomSheetPosition = .relative(0.7)
                    } label: {
                        Text("다른날 하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        let today = Calendar.current.startOfDay(for: Date())
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo,
                                                                        title: nil,
                                                                        status: nil,
                                                                        duedate: today,
                                                                        completeDate: nil,
                                                                        enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
//                        if settingViewModel.enableHideGaveUpTask {
//                            // 포기한 일 숨기기 true일 때
//                            todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
//                        }
                        
                        // 변경 토스트 메시지 띄우기
                        detailTodoViewModel.showChangedAsTodayToast.toggle()
                        
                        // 완료 스티커 붙이기 활성화 업데이트
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                    } label: {
                        Text("오늘 하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .customBackground(
                LinearGradient(gradient: Gradient(colors: [.themeColor10, .themeColor20]), startPoint: .bottomLeading, endPoint: .topTrailing)
                    .foregroundColor(.themeColor40)
            )
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
       
}
