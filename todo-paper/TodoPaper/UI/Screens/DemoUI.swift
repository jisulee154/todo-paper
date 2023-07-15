//
//  demoUI.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/14.
//

import SwiftUI

struct DemoUI: View {
    
    @State private var isSheetPresented = false
    @State private var newTodo = TodoItem()
    
    var body: some View {
        VStack {
            Button(action: {
                isSheetPresented.toggle()
            }) {
                Text("Show License Agreement")
            }
            .sheet(isPresented: $isSheetPresented, onDismiss: didDismiss) {
                VStack {
                    TextField("새로운 할일을 입력해주세요.", text: $newTodo.title)
                    Button("Dismiss", action: { isSheetPresented.toggle() })

                    
                }
            }
            Text("\(isSheetPresented ? "T" : "F")")
            Text("\(newTodo.title == "" ? "none" : newTodo.title)")
            
        }
    }
    func didDismiss() {
        print(newTodo)
    }
    
}


struct demoUI_Previews: PreviewProvider {
    static var previews: some View {
        DemoUI()
    }
}
