//
//  AddTodoButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI

struct AddTodoButton: View{
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var isSheetPresented = false
//    @Binding var newTodo: TodoItem
//    var addItem: () -> ()
    @State var newTodo: TodoItem = TodoItem()
    
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
//                        TextField("새로운 할일을 입력해주세요.", text: $newTodo.title)
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
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.title = newTodo.title

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("CoreData addItem error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddTodoButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoButton(newTodo: TodoItem())
    }
}
