//
//  AddTodoButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI

struct AddTodoButton: View{
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var isSheetPresented = false
    @State var newTodo: TodoItem = TodoItem()
    @Binding var todoList: [TodoItemRow]
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
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
        //      print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        newTodo.id = UUID()
        newTodo.duedate = Date()
        newTodo.status = TodoStatus.none
        newTodo.section = "Today"
        
        todoList.append(TodoItemRow(with: newTodo))
        
        //Core Data write test
        withAnimation {
            if newTodo.title != "" {
                let newItem = Item(context: viewContext)
                newItem.id = newTodo.id
                newItem.duedate = newTodo.duedate
                newItem.section = newTodo.section
                newItem.status = newTodo.status.rawValue
                newItem.title = newTodo.title
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("CoreData addItem error \(nsError), \(nsError.userInfo)")
                }
            } else {
                print("todo title is empty.")
            }
        }
    }
    
    //    private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
    //    }
    //}
}
