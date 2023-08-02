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
    
    //    @State var isPressed: Bool = false
    var todoItem: TodoItem
    var todoItemRowType: TodoItemRowType
    
    init(with newTodo: TodoItem,
         todoViewModel: TodoViewModel,
         todoItemRowType:TodoItemRowType = TodoItemRowType.today,
         detailTodoViewModel: DetailTodoViewModel
    ) {
        self.todoItem = newTodo
        self.todoItemRowType = todoItemRowType
        self.todoViewModel = todoViewModel
        self.detailTodoViewModel = detailTodoViewModel
        
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
                case .canceled:
                    Image(systemName: "xmark.square")
                        .todoImageModifier()
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
                if todoViewModel.canShowOldTodos() {
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                }
                print("완료하고자 하는 투두: ", todoItem.title)
            }
            // TodoItemRowType에 따라 다른 형태로 보여주기
            // 현재 일자
            if (todoItemRowType == TodoItemRowType.today) {
                Text(todoItem.title)
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
                        Text(todoItem.title)
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
                    detailTodoViewModel.timePosition = detailTodoViewModel.getTimePosition(of: todoViewModel.searchDate)
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

