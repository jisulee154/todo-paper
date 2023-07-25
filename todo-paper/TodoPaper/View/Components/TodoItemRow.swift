//
//  TodoItemRow.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation
import SwiftUI

enum TodoItemRowType {
    case today
    case old
}

struct TodoItemRow: View {
    @ObservedObject var todoViewModel: TodoViewModel
//    @State var isPressed: Bool = false
    var todoItem: TodoItem
    var todoItemRowType: TodoItemRowType
    
    init(with newTodo: TodoItem, todoViewModel: TodoViewModel, todoItemRowType:TodoItemRowType = TodoItemRowType.today) {
        self.todoItem = newTodo
        self.todoItemRowType = todoItemRowType
        self.todoViewModel = todoViewModel
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
                                                                    title: todoItem.title,
                                                                    status: TodoStatus.completed,
                                                                    duedate: todoItem.duedate)
                } else {
                    todoViewModel.todos = todoViewModel.updateATodo(updatingTodo: todoItem,
                                                                    title: todoItem.title,
                                                                    status: TodoStatus.none,
                                                                    duedate: todoItem.duedate)
                }
                
                todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                if todoViewModel.canShowOldTodos() {
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                }
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
            Image(systemName: "ellipsis")
            
        }
        .foregroundColor(.themeColor40)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            print("touched Item \(todoItem.title)")
        }
    }
}
