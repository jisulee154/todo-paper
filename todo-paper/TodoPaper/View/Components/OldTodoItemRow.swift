//
//  OldTodoItemRow.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/24.
//

import SwiftUI

struct OldTodoItemRow: View {
    @ObservedObject var todoViewModel: TodoViewModel
    var newTodo: TodoItem
    
    init(with newTodo: TodoItem, todoViewModel: TodoViewModel) {
        self.newTodo = newTodo
        self.todoViewModel = todoViewModel
    }
    
    var body: some View {
        // 투두 행 표시
        HStack {
            switch(newTodo.status) {
            case .none:
                Image("Button_TodoDefault")
                    .todoImageModifier()
            case .completed:
                Image("Button_TodoCompleted")
                    .todoImageModifier()
            case .postponed:
                Image("Button_TodoPostponed")
                    .todoImageModifier()
            case .canceled:
                Image("Button_TodoCanceled")
                    .todoImageModifier()
            }
            VStack {
                // 지난 기한 표시
                HStack {
                    if let interval = todoViewModel.getDelayedDays(with: newTodo.duedate) {
                        Text("\(interval)일 지남")
                            .foregroundColor(.red)
                    } else {
                        Text("계산불가")
                            .foregroundColor(.red)
                    }
                    Spacer()
                }
                HStack {
                    Text(newTodo.title)
                    Spacer()
                }
                    
            }
            Spacer()
            Image(systemName: "ellipsis")
            
        }
        .foregroundColor(.themeColor40)
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .contentShape(Rectangle())
        .onTapGesture {
            print("touched Item \(newTodo.title)")
        }
    }
}
