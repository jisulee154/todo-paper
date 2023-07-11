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
    var isCompleted = false
    var isPostpone = false
    var isCanceled = false    
}
