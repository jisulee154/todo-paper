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
    
//    @Binding var todoList: [TodoItemRow]
    
    
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
        //Binding - test
//        todoList.append(TodoItemRow(todoItem: TodoItem(title: newTodo.title)))
        
        //Core Data write test
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.id = UUID()
//            newItem.title = newTodo.title
//            newItem.duedate = Date()
//            newItem.status = TodoState.none.rawValue
//
//            do {
//                try viewContext.save()
//            } catch {
//                let nsError = error as NSError
//                fatalError("CoreData addItem error \(nsError), \(nsError.userInfo)")
//            }
//            print(newTodo)
//
//            //refresh todo list
//
//        }
        
    }
}

//struct AddTodoButton_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTodoButton(todoList: <#Binding<[TodoItemRow]>#>)
//    }
//}
