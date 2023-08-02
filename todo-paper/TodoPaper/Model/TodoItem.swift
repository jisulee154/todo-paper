//
//  TodoItem.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation

struct TodoItem: Identifiable {
    var id: UUID {
        return uuid
    }
    var uuid = UUID()
    var title: String = ""
    var duedate = Date()
    var status = TodoStatus.none
    var completeDate: Date? = nil
//    var section: String = "Today"
//    var onToday: Bool = false
    
    init(uuid: UUID = UUID(), title: String, duedate: Date = Date(), status: TodoStatus = TodoStatus.none, completeDate: Date? = nil) {
        self.uuid = uuid
        self.title = title
        self.duedate = duedate
        self.status = status
        self.completeDate = completeDate
//        self.onToday = onToday
//        self.section = section
    }
    
//    init(newTodoItem: TodoItem) {
//        self.uuid = newTodoItem.uuid ?? UUID()
//        self.title = newTodoItem.title ?? ""
//        self.duedate = newTodoItem.duedate ?? Date()
//        self.status = newTodoItem.status ?? TodoStatus.none
//        self.section = newTodoItem.section ?? "Today"
//    }
}

enum TodoStatus: Int32 {
    case none       = 0
    case completed  = 1
    case postponed  = 2
    case canceled   = 3
}
