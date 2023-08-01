//
//  DetailSheetOfFuture.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import SwiftUI
import BottomSheetSwiftUI

//MARK: - 상세 설정 시트 (미래)
struct DetailSheetOfFuture: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(todoViewModel: TodoViewModel, detailTodoViewModel: DetailTodoViewModel) {
        self.todoViewModel = todoViewModel
        self.detailTodoViewModel = detailTodoViewModel
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
                    HStack (spacing: 10) {
                        Button {
                            detailTodoViewModel.settingBottomSheetPosition = .hidden
                            detailTodoViewModel.editBottomSheetPosition = .relative(0.7)
//                            detailTodoViewModel.isEditBottomSheetShowing.toggle()
                        } label: {
                            Text("수정하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                        
                        Button {
                            detailTodoViewModel.settingBottomSheetPosition = .hidden
                            detailTodoViewModel.datePickerBottomSheetPosition = .relative(0.7)
//                            detailTodoViewModel.isDetailSheetShowing.toggle()
//                            detailTodoViewModel.isDatePickerShowing.toggle()
                        } label: {
                            Text("다른날 하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                    }
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        let today = Calendar.current.startOfDay(for: Date())
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo, title: nil, status: nil, duedate: today)
                    } label: {
                        Text("오늘 하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        // 상태 업데이트 .none -> .canceled
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo, title: nil, status: .canceled, duedate: nil)
                    } label: {
                        Text("포기하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        // 선택된 투두 삭제하기
                        todoViewModel.todos = todoViewModel.deleteATodo(uuid: detailTodoViewModel.pickedTodo.uuid)
                        
                        // 삭제 토스트 메시지
                        detailTodoViewModel.showDeletedToast.toggle()
                    } label: {
                        Text("삭제")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(DeleteButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
}

