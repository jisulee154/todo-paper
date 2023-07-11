//
//  TodoItemRow.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation
import SwiftUI

struct TodoItemRow: View, Identifiable {
    let todoItem: TodoItem
    let id = UUID()
    
    var body: some View {
        HStack{
            Image(systemName: todoItem.isCompleted ? "square.fill" : "square")
            Text(todoItem.title)
            Spacer()
            Image(systemName: "pencil")
        }
    }
    
}
