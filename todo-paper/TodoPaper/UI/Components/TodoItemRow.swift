//
//  TodoItemRow.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation
import SwiftUI

struct TodoItemRow: View {
    var newTodo: TodoItem
    
    init(with newTodo: TodoItem) {
        self.newTodo = newTodo
    }
    
    var body: some View {
        HStack{
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
            Text(newTodo.title)
            Text("\(newTodo.duedate)")
            Spacer()
            Text("\(newTodo.section)")
            Image(systemName: "chevron.right")
        }
        .foregroundColor(.themeColor40)
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .contentShape(Rectangle())
        .onTapGesture {
            print("touched Item \(newTodo.title)")
        }
    }
}

extension Image {
    func todoImageModifier() -> some View {
        self
            .resizable()
            .frame(width: 30, height: 30)
    }
}
