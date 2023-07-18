//
//  TodoItem.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation

struct TodoItem: Identifiable {
    var id = UUID()
    var title: String = ""
    var duedate = Date()
    var status = TodoStatus.none
    var section: String = "Today"
    
//    lazy var section: String = {
//        if Calendar.current.isDateInToday(duedate) {
//            return "Today"
//        }
//        else {
//            return "Old"
//        }
//    }()
}

enum TodoStatus: Int32 {
    case none       = 0
    case completed  = 1
    case postponed  = 2
    case canceled   = 3
}
