//
//  AddTodoButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI

struct AddTodoButton: View {
    @State private var isSheetPresented = false
    @State private var newTodo = TodoItem()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    isSheetPresented.toggle()
                }) {
                    Image(systemName: "square.and.pencil.circle")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.themeColor40)
                    
                }
                .sheet(isPresented: $isSheetPresented, onDismiss: didDismiss) {
                    VStack {
                        TextField("새로운 할일을 입력해주세요.", text: $newTodo.title)
                        Button("Dismiss", action: { isSheetPresented.toggle() })
                    }
                }
                Spacer()
                    .frame(width: 0, height: 10)
            }
        }
    }
    
    func didDismiss() {
        print("Adding new todo!! \(newTodo)")
    }
}

struct AddTodoButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoButton()
    }
}
