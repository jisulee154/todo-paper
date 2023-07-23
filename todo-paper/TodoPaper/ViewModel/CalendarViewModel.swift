//
//  CalendarViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation

class CalendarViewModel: ObservableObject {
//    let container = PersistenceController.shared.container
//
//    @Published var searchDate: Date = Calendar.current.startOfDay(for: Date())
//    
//    init {
//        self.searchDate = setSearchDate(date: Date())
//    }
//
//    // 모든 테이블 관리자, 중재자.
//    fileprivate var context: NSManagedObjectContext {
//        return self.container.viewContext
//    }
    
    @Published private(set) var array = [Date()]
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
    
//MARK: - Scroll
    func printID<T>(of id: T) {
        print(id)
    }
    
}
