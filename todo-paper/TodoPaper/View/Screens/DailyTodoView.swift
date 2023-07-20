//
//  DailyTodoView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI
import CoreData

struct DailyTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //MARK: - Core Data
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
    
//    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date()) ?? Date()
//    @State private var refreshTodoList: Bool = false
    @State private var refreshView: Bool = false
    
    @State private var fetchModel: FetchModel = FetchModel(currentDate: Date())
    
//    @State private var predicate: NSPredicate
//    private var request: FetchRequest<Item>
//    private var todayItems: FetchedResults<Item> { request.wrappedValue }
//
//    init() {
//        predicate = NSPredicate(format: "duedate >= %@ && duedate <= %@", selectedDate as! any CVarArg )
//        request = FetchRequest(entity: Item.entity(),
//                                    sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
//                                    predicate: predicate)
//    }
    //MARK: - View
    var body: some View {
        VStack {
            //MARK: - Overflow scroll calendar (daily)
            OverflowScrollDailyHeader(fetchModel: $fetchModel)
            
            //MARK: - Todo list
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
                            RoundedRectangle(cornerRadius: 20, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
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
                            RoundedRectangle(cornerRadius: 20, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
                        )
                    }
                    .listRowInsets(EdgeInsets.init())
                } //List
                .onChange(of: fetchModel) { _ in
                    todayItems.nsPredicate = fetchModel.predicate
                    print(todayItems.nsPredicate)
                    
                }
                AddTodoButton(todoList: $todoList)
            }
        }
    }
}


//struct DailyTodoView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyTodoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
