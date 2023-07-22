//
//  DailyTodoView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI
import CoreData
import Combine

struct DailyTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //    @StateObject var todayTodoViewModel: TodoViewModel = TodoViewModel()
    //    @StateObject var previousTodoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()
    
    
    //    @FetchRequest(entity: Item.entity(),
    //                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
    //                  predicate: NSPredicate(format: "duedate >= %@ && duedate <= %@", Calendar.current.startOfDay(for: Date()) as CVarArg, Calendar.current.startOfDay(for: Date() + 86400) as CVarArg),
    //                  animation: .default)
    //    private var todayItems: FetchedResults<Item>
    
    
    //    @FetchRequest(entity: Item.entity(),
    //                  sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
    //                  predicate: NSPredicate(format: "(duedate < %@) && (status == 0)", Calendar.current.startOfDay(for: Date()) as CVarArg),
    //                  animation: .default)
    //    private var oldItems: FetchedResults<Item>
    
    
    //MARK: - Shared Data
//    @State private var todoList: [TodoItemRow] = []
//    @State private var newTodo: TodoItem = TodoItem()
//
//    @State private var refreshView: Bool = false
//
//    @State private var fetchModel: FetchModel = FetchModel(currentDate: Date())
//    @State private var newDate: Date = Date()
    
    //MARK: - View
    var body: some View {
        ZStack {
            List {
                Section("today") {
                    VStack {
                        ForEach(todoViewModel.todos) { todo in
                            TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                                       title: todo.title,
                                                       duedate: todo.duedate,
                                                       status: todo.status,
                                                       section: todo.section))
                        }
                    }
                }
            }
            
            //MARK: - Adding Todo Button
            AddTodoButton(todoViewModel: todoViewModel)
        }
    }
//        VStack {
//            //MARK: - Overflow scroll calendar (daily)
////            OverflowScrollDailyHeader(fetchModel: $fetchModel) { clickedDate in
////                self.newDate = clickedDate
////            }
//
//            //MARK: - Todo list
//            ZStack {
//                List {
//                    Section("today") {
//                        VStack {
//                            ForEach(todoViewModel.todos) { todo in
//                                TodoItemRow(with: TodoItem(uuid: todo.uuid,
//                                                           title: todo.title ?? "",
//                                                           duedate: todo.duedate,
//                                                           status: todo.status.rawValue))
//                                Divider()
//                            }
//                            //                            ForEach(todos) { item in
//                            //                                TodoItemRow(with: TodoItem(id: UUID(),
//                            //                                                           title: item.title ?? "",
//                            //                                                           duedate: item.duedate!,
//                            //                                                           status: TodoStatus(rawValue: item.status)!))
//                            //                                Divider()
//                            //                            }
//                        }
////                        .overlay(
////                            RoundedRectangle(cornerRadius: 20, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
////                        )
//                    }
//                    .listRowInsets(EdgeInsets.init())
//                    //                    Section("old") {
//                    //                        VStack {
//                    //                            ForEach(previousTodoViewModel.todoItems   ) { item in
//                    //                                TodoItemRow(with: TodoItem(id: UUID(), title: item.title ?? "", duedate: item.duedate!, status: TodoStatus(rawValue: item.status)!))
//                    //                                Divider()
//                    //                            }
//                    //                        }
//                    //                        .overlay(
//                    //                            RoundedRectangle(cornerRadius: 20, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
//                    //                        )
//                    //                    }
//                    .listRowInsets(EdgeInsets.init())
//                } //List
//                .onAppear {
//                }
//                //                .onChange(of: newDate) { changedDate in
//                //                    fetchModel = FetchModel(currentDate: changedDate)
//                //                    todayItems.nsPredicate = fetchModel.predicate
//                //                    print("\n\n [DailyTodoView] ==Todo View is reloaded!!==")
//                //                    print("todayItems.nsPredicate: ", todayItems.nsPredicate)
//                //                    print(todayItems)
//                //
//                //                }
//            }
//        }
}


//struct DailyTodoView_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyTodoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
