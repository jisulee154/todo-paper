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
            switch(todoItem.state) {
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
            Text(todoItem.title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .foregroundColor(.themeColor40)
        .padding(20)
        .contentShape(Rectangle())
        .onTapGesture {
            print("touched Item \(todoItem.title)")
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
