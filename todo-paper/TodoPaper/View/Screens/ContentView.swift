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
    
    @FetchRequest(entity: Item.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
                  predicate: NSPredicate(format: "(duedate < %@) && (status == 0)", Calendar.current.startOfDay(for: Date()) as CVarArg),
                  animation: .default)
    private var oldItems: FetchedResults<Item>

    
    //MARK: - Shared Data
    @State private var todoList: [TodoItemRow] = []
    @State private var newTodo: TodoItem = TodoItem()
    
    //MARK: - View
    var body: some View {
        VStack {
            //MARK: - Overflow scroll calendar (daily)
            OverflowScrollDailyHeader()
            ZStack {
                List {
                    Section("today") {
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
                    Section("old") {
                        VStack {
                            ForEach(oldItems) { item in
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
