//
//  TodoItem.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation

struct TodoItem: Identifiable {
    let id = UUID()
    var title: String = ""
    var duedate = Date()
    var state = TodoState.none
}

enum TodoState: Int32 {
    case none       = 0
    case completed  = 1
    case postponed  = 2
    case canceled   = 3
}
