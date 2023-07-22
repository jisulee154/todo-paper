//
//  todo_paperApp.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI

@main
struct todo_paperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                DailyTodoView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("List", systemImage: "list.bullet")
                    }
//                HistoryView()
//                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                    .tabItem {
//                        Label("History", systemImage: "doc.plaintext")
//
//                    }
            }
        }
    }
}
