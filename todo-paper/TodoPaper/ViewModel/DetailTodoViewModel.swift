//
//  DetailTodoViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/27.
//

import Foundation
import BottomSheetSwiftUI

class DetailTodoViewModel: ObservableObject {
    @Published var isDetailSheetShowing: Bool = false
    @Published var isDatePickerShowing: Bool = false
    @Published var isEditBottomSheetShowing: Bool = false
    
    @Published var timePosition: TimePosition = .today
    @Published var changedDate: Date = Date()
    @Published var pickedTodo: TodoItem = TodoItem(title: "")
    @Published var bottomSheetPosition: BottomSheetPosition = .relative(0.7)
    
    init(isDetailSheetShowing: Bool = false,
         isDatePickerShowing: Bool = false,
         isEditBottomSheetShowing: Bool = false,
         timePosition: TimePosition = .today,
         changedDate: Date = Date(),
         pickedTodo: TodoItem = TodoItem(title: "")) {
        self.isDetailSheetShowing = isDetailSheetShowing
        self.timePosition = timePosition
        self.isDatePickerShowing = isDatePickerShowing
        self.isEditBottomSheetShowing = isEditBottomSheetShowing
        self.changedDate = changedDate
        self.pickedTodo = pickedTodo
    }
    
    func setPickedTodo(pickedTodo: TodoItem) {
        self.pickedTodo = pickedTodo
    }
    
    func getTimePosition(of date: Date) -> TimePosition {
        let startOfToday = Calendar.current.startOfDay(for: Date()) ?? Date()
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
        
        if date < startOfToday {
            return .past
        } else if date >= startOfTomorrow {
            return .future
        } else if (date >= startOfToday) && (date < startOfTomorrow) {
            return .today
        } else {
            print(#fileID, #function, #line, "- Error: Can not calculate a time position(past/today/future).")
            return .none
        }
    }
}
