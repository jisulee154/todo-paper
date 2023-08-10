//
//  DetailSheetOfToday.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import SwiftUI
import BottomSheet

//MARK: - 상세 설정 시트 (오늘)
struct DetailSheetOfToday: View {
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
                        
                        let today = Calendar.current.startOfDay(for: Date())
                        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
                        
                        // 상태와 duedate 업데이트 Status -> .postponed
//                        print(detailTodoViewModel.pickedTodo)
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo,
                                                                                                    title: nil,
                                                                                                    status: .postponed,
                                                                                                    duedate: nil,
                                                                                                    completeDate: today,
                                                                                                    enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                        
//                        if detailTodoViewModel.pickedTodo.duedate < today {
//                            todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo,
//                                                                            title: nil,
//                                                                            status: .postponed,
//                                                                            duedate: nil,
//                                                                            completeDate: today,
//                                                                            enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
//                        } else {
//                            todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo,
//                                                                            title: nil,
//                                                                            status: .postponed,
//                                                                            duedate: nil,
//                                                                            completeDate: today,
//                                                                            enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
//                        }
//                        if settingViewModel.enableHideGaveUpTask {
//                            // 포기한 일 숨기기 true일 때
//                            todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
//                        }
                        
                        todoViewModel.oldTodos = todoViewModel.fetchOldTodos(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
//                        if settingViewModel.enableHideGaveUpTask {
//                            // 포기한 일 숨기기 true일 때
//                            todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
//                        }
                        
                        // 내일 목록에 투두 복사
                        _ = todoViewModel.addATodo(
                            TodoItem(title: detailTodoViewModel.pickedTodo.title, duedate: tomorrow, completeDate: nil),
                            enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                        )
                        
                        // 실행 완료 토스트 메시지
                        detailTodoViewModel.showPostponedToast.toggle()
                        
                        // 완료 스티커 붙이기 활성화 업데이트
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                    } label: {
                        Text("내일 하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        let today = Calendar.current.startOfDay(for: Date())
                        
                        // 상태 업데이트 Status -> .canceled
                        todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: detailTodoViewModel.pickedTodo, title: nil, status: .canceled, duedate: nil, completeDate: today, enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                        
                        todoViewModel.oldTodos = todoViewModel.fetchOldTodos(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                        
//                        todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
//                        if settingViewModel.enableHideGaveUpTask {
//                            // 포기한 일 숨기기 true일 때
//                            todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
//                        }
//                        if settingViewModel.enableHideGaveUpTask {
//                            // 포기한 일 숨기기 true일 때
//                            todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
//                        }
                        
                        
                        // 완료 스티커 붙이기 활성화 업데이트
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                    } label: {
                        Text("포기하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.settingBottomSheetPosition = .hidden
                        
                        // 선택된 투두 삭제하기
                        todoViewModel.todos = todoViewModel.deleteATodo(uuid: detailTodoViewModel.pickedTodo.uuid, enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                        todoViewModel.oldTodos = todoViewModel.fetchOldTodos(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                        
                        // 삭제 토스트 메시지
                        detailTodoViewModel.showDeletedToast.toggle()
                        
                        // 완료 스티커 붙이기 활성화 업데이트
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
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

