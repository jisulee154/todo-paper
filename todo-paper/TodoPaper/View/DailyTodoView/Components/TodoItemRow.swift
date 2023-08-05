//
//  TodoItemRow.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import SwiftUI

enum TodoItemRowType {
    case today
    case old
}

struct TodoItemRow: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    @ObservedObject var stickerViewModel: StickerViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    
    //    @State var isPressed: Bool = false
    var todoItem: TodoItem
    var todoItemRowType: TodoItemRowType
    
    init(with newTodo: TodoItem,
         todoViewModel: TodoViewModel,
         todoItemRowType: TodoItemRowType = TodoItemRowType.today,
         detailTodoViewModel: DetailTodoViewModel,
         stickerViewModel: StickerViewModel,
         settingViewModel: SettingViewModel
    ) {
        self.todoItem = newTodo
        self.todoItemRowType = todoItemRowType
        self.todoViewModel = todoViewModel
        self.detailTodoViewModel = detailTodoViewModel
        self.stickerViewModel = stickerViewModel
        self.settingViewModel = settingViewModel
    }
    
    var body: some View {
        HStack {
            HStack {
                switch(todoItem.status) {
                case .none:
                    Image(systemName: "square")
                        .todoImageModifier()
                case .completed:
                    Image(systemName: "checkmark.square")
                        .todoImageModifier()
                case .postponed:
                    Image(systemName: "arrow.forward.square")
                        .todoImageModifier()
                        .foregroundColor(.gray)
                case .canceled:
                    Image(systemName: "xmark.square")
                        .todoImageModifier()
                        .foregroundColor(.gray)
                }
            }
            .onTapGesture {
                if (todoItem.status == TodoStatus.none) {
                    todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: todoItem,
                                                                    title: nil,
                                                                    status: TodoStatus.completed,
                                                                    duedate: nil,
                                                                    completeDate: todoViewModel.searchDate)
                } else {
                    todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: todoItem,
                                                                    title: nil,
                                                                    status: TodoStatus.none,
                                                                    duedate: nil,
                                                                    completeDate: nil)
                }
                
                
                todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                if settingViewModel.enableHideGaveUpTask {
                    // 포기한 일 숨기기 true일 때
                    todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
                }
                
                if todoViewModel.canShowOldTodos() {
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                    if settingViewModel.enableHideGaveUpTask {
                        // 포기한 일 숨기기 true일 때
                        todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
                    }
                }
                
                todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
                
                
                // 스티커 체크
                if todoViewModel.isActivePutSticker {
                    stickerViewModel.isTodayStickerOn = stickerViewModel.getTodayStickerOn(date: todoViewModel.searchDate)
                    
                    if stickerViewModel.isTodayStickerOn {
                        stickerViewModel.sticker = stickerViewModel.fetchSticker(on: todoViewModel.searchDate)
                    }
                } else {
                    stickerViewModel.sticker = stickerViewModel.updateASticker(updatingSticker: stickerViewModel.sticker!, date: todoViewModel.searchDate, isExist: false, stickerName: nil, stickerBgColor: nil)
                    stickerViewModel.isTodayStickerOn = false
                }
                
            }
            // TodoItemRowType에 따라 다른 형태로 보여주기
            // 현재 일자
            if todoItemRowType == TodoItemRowType.today {
                if todoItem.status == TodoStatus.canceled {
                    Text(todoItem.title)
                        .foregroundColor(.gray)
                        .strikethrough()
                } else if todoItem.status == TodoStatus.postponed {
                    Text(todoItem.title)
                        .foregroundColor(.gray)
                } else {
                    Text(todoItem.title)
                }
            } else {
                VStack {
                    // 지난 기한 표시
                    HStack {
                        if let interval = todoViewModel.getDelayedDays(with: todoItem.duedate) {
                            Text("\(interval)일 지남")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    HStack {
                        if todoItem.status == TodoStatus.canceled {
                            Text(todoItem.title)
                                .foregroundColor(.gray)
                                .strikethrough()
                        } else if todoItem.status == TodoStatus.postponed {
                            Text(todoItem.title)
                                .foregroundColor(.gray)
                        } else {
                            Text(todoItem.title)
                        }
                        Spacer()
                    }
                    
                }
            }
            
            Spacer()
            Button {
            } label: {
                Image(systemName: "ellipsis")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .onTapGesture {
                    detailTodoViewModel.timePosition = DetailTodoViewModel.getTimePosition(of: todoViewModel.searchDate)
                    detailTodoViewModel.setPickedTodo(pickedTodo: todoItem)
                    detailTodoViewModel.settingBottomSheetPosition = .relative(0.7)
                    print("상세설정 하고자 하는 투두: ", todoItem.title)
            }
            
        }
        .foregroundColor(.themeColor40)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

//struct TodoDetail: View{
//    @ObservedObject var todoViewModel: TodoViewModel
//    @State private var isShowing: Bool = false
//
//    init(todoViewModel: TodoViewModel) {
//        self.todoViewModel = todoViewModel
//    }
//
//    var body: some View {
//        HStack {
//            Button {
//
//            } label: {
//                Image(systemName: "ellipsis")
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 20)
//            .background(Color.yellow)
//            .onTapGesture {
//                todoViewModel.timePosition = todoViewModel.getTimePosition(of: todoViewModel.searchDate)
//
////                    isShowing.toggle()
//            }
//            //                .sheet(isPresented: $isShowing) {
//            //                    //pass
//            //                }
//
//
//        }
//    }
//}

