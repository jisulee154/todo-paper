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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var todayTodoList: [TodoItemRow] = [
        TodoItemRow(todoItem: TodoItem(title: "아침 먹기", state: TodoState.completed)),
        TodoItemRow(todoItem: TodoItem(title: "책 사기", state: TodoState.canceled)),
        TodoItemRow(todoItem: TodoItem(title: "운동 1시간"))
    ]
    @State private var oldTodoList: [TodoItemRow] = [
        TodoItemRow(todoItem: TodoItem(title: "아침 먹기", state: TodoState.postponed)),
        TodoItemRow(todoItem: TodoItem(title: "책 사기")),
        TodoItemRow(todoItem: TodoItem(title: "운동 1시간"))
    ]
    
    //@State private var selection: String?
    
    var body: some View {
        ZStack {
            List {
                Section("Today") {
                    VStack {
                        ForEach(todayTodoList) {
                            todoItemRow in
                            todoItemRow
                            Divider()
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
                    )
                }
                .listRowInsets(EdgeInsets.init())
                
                Section("Old") {
                    VStack {
                        ForEach(oldTodoList) {
                            todoItemRow in
                            todoItemRow
                            Divider()
                        }
                        
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
                    )
                }
                .listRowInsets(EdgeInsets.init())
                
                AddTodoButton()
            }
                
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            //newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
