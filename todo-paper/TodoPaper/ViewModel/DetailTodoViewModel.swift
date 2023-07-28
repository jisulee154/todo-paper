//
//  DetailTodoViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/27.
//

import Foundation

class DetailTodoViewModel: ObservableObject {
    @Published var isDetailSheetShowing: Bool = false
    @Published var timePosition: TimePosition = .today
    
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
