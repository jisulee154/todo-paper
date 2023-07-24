//
//  FloatingFooter.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI

struct FloatingFooter: View{
//    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        entity: Item.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @State var newTodo: TodoItem = TodoItem(title: "")
    @State var newTitle: String = ""
    @State var isSheetPresented = false
    @ObservedObject var todoViewModel: TodoViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack (spacing: 10) {
                Spacer()
                Button {
                    //action
                } label: {
                    Image("CompleteSticker_PlaceHolder")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 20)
                }
                Button(action: {
                    isSheetPresented.toggle()
                }) {
                    Image("Button_TodoAdd")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                        .foregroundColor(.themeColor40)
                    
                }
                .sheet(isPresented: $isSheetPresented, onDismiss: didDismiss) {
                    VStack {
                        TextField("새로운 할일을 입력해주세요.", text: $newTitle)
                        Button("Dismiss", action: { isSheetPresented.toggle() })
                    }
                }
                Spacer()
                    .frame(width: 0, height: 10)
            }
        }
    }
    
    func didDismiss() {
        newTodo.uuid = UUID()
        newTodo.duedate = Date()
        newTodo.status = TodoStatus.none
        newTodo.section = "Today"
        if newTitle != "" {
            todoViewModel.todos = todoViewModel.addATodo(TodoItem(title: newTitle))
        }
        
        newTitle = ""
    }
}
