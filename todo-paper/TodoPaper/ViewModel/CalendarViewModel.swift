//
//  CalendarViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation

class CalendarViewModel: ObservableObject {
    @Published private(set) var array = [Date()]
//    var batchSize: Int = 10
    var batchSize: Int = Date().daysThisMonth() ?? 0

//MARK: - Calendar
    func loadMoreDates() {
        let today = Calendar.current.startOfDay(for: Date())
        let startDate = Calendar.current.startOfDay(for: array.first ?? today)
        for i in 1...batchSize {
            let date = Calendar.current.date(byAdding: .day, value: i, to: startDate)!
            array.append(date)
            //            array.insert(date, at: 0)
        }
    }
    
    func getAfter10days(of day: Date) -> Date? {
        var resDate = Calendar.current.date(byAdding: .day, value: 10, to: Calendar.current.startOfDay(for: day))
        return resDate
    }
    
//MARK: - Scroll
    func printID<T>(of id: T) {
        print(id)
    }
    
}
