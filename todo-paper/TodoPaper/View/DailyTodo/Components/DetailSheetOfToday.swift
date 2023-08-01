//
//  DetailSheetOfToday.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import SwiftUI
import BottomSheetSwiftUI

//MARK: - 상세 설정 시트 (오늘)
struct DetailSheetOfToday: View {
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
                    HStack {
                        Button {
                            //                        detailTodoViewModel.isEditBottomSheetShowing.toggle()
                            detailTodoViewModel.settingBottomSheetPosition = .hidden
                            detailTodoViewModel.editBottomSheetPosition = .relative(0.7)
                        } label: {
                            Text("수정하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                        
                        Button {
                            detailTodoViewModel.settingBottomSheetPosition = .hidden
                            detailTodoViewModel.datePickerBottomSheetPosition = .relative(0.7)
                            //                        detailTodoViewModel.isDetailSheetShowing.toggle() // 기존 상세설정 bottom sheet가 밑으로 내려감.
                            //                        detailTodoViewModel.isDatePickerShowing.toggle() // Date Picker bottom sheet가 위로 올라옴.
                        } label: {
                            Text("다른날 하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                    }
                    //                .alert("날짜 변경", isPresented: $detailTodoViewModel.isDatePickerShowing) {
                    //                    Button("확인") {
                    //                        detailTodoViewModel.isDetailSheetShowing.toggle()
                    //                        print("투두의 날짜가 변경되었습니다.") //토스트 메시지!!!
                    //                    }
                    //                    Button("취소", role: .cancel) { }
                    //                } message: {
                    //
                    //                }
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
                        
                        // 상태 업데이트 .none -> .postponed
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo, title: nil, status: .postponed, duedate: nil)
                        
                        // 내일 목록에 투두 복사
                        todoViewModel.todos = todoViewModel.addATodo(
                            TodoItem(title: detailTodoViewModel.pickedTodo.title, duedate: tomorrow)
                        )
                    } label: {
                        Text("내일 하기")
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
                    } label: {
                        Text("삭제")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(DeleteButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
}

