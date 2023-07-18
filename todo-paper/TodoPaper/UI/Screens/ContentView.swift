//
//  ContentView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Item.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
                  predicate: NSPredicate(format: "duedate >= %@ && duedate <= %@", Calendar.current.startOfDay(for: Date()) as CVarArg, Calendar.current.startOfDay(for: Date() + 86400) as CVarArg),
                  animation: .default)
    private var todayItems: FetchedResults<Item>
    
    
    
    //MARK: - Shared Data
    @State private var todoList: [TodoItemRow] = []
    @State private var newTodo: TodoItem = TodoItem()
    
    var body: some View {
        ZStack {
            List {
                Section("Today") {
                    VStack {
                        ForEach(todayItems) { item in
                            TodoItemRow(with: TodoItem(id: UUID(), title: item.title ?? "", duedate: item.duedate!, status: TodoStatus(rawValue: item.status)!))
                            Divider()
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
                    )
                }
                .listRowInsets(EdgeInsets.init())
            }
            AddTodoButton(todoList: $todoList)
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
