//
//  CoreDataTodoRepository.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/21.
//

import Foundation
import CoreData
import Combine

enum TimePosition {
    case today
    case future
    case past
    case none // Error Case
}

enum CompleteStickerStatus: Int32 {
    case none       = 0
    case sticker1   = 1
    case sticker2   = 2
}

enum ScrollDirection: Int32 {
    case prevMonth  = 0
    case nextMonth  = 1
}

protocol TodoItemProtocol {
    var todos: [TodoItem] { get }
    func fetchTodos() -> [TodoItem]
    func deleteATodo(uuid: UUID) -> [TodoItem]
    func addATodo(_ newTodo: TodoItem) -> [TodoItem]
    func updateATodo(updatingTodo: TodoItem, title: String?, status: TodoStatus?, duedate: Date?) -> [TodoItem]
    func clearAllTodos()
}

//MARK: - Core Data Stack
class TodoViewModel: ObservableObject, TodoItemProtocol {
    let container = PersistenceController.shared.container
    
    // 모든 테이블 관리자, 중재자.
    fileprivate var context: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    @Published var todos: [TodoItem] = []
    @Published var oldTodos: [TodoItem] = []
    @Published var searchDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var datesInMonth: [Date] = []
    @Published var completeSticker: CompleteStickerStatus = CompleteStickerStatus.none
    @Published var scrollTargetDate: Date = Date()
    @Published var delayedDays: Int? = 0
//    @Published var timePosition: TimePosition = .today
    
    init() {
        self.todos = fetchTodos()
        self.oldTodos = fetchOldTodos()
        self.searchDate = setSearchDate(date: Date())
        self.datesInMonth = getDatesInAMonth()
        self.completeSticker = setCompleteSticker(with: "")
        self.scrollTargetDate = setScrollTargetDate(with: Date())
        self.delayedDays = getDelayedDays(with: Calendar.current.startOfDay(for: Date()))
//        self.timePosition = getTimePosition(of: Date())
    }
    
    
    //MARK: - 완료 스티커 관련
    func setCompleteSticker(with name: String) -> CompleteStickerStatus{
        switch name {
        case "1":
            return CompleteStickerStatus.sticker1
        case "2":
            return CompleteStickerStatus.sticker2
        default:
            return CompleteStickerStatus.none
        }
    }
    
    //MARK: - 캘린더 관련
    
    /// 이전달이나 다음달의 날짜를 반환한다
    /// - Parameters:
    ///   - direction: 이전달/다음달 중 어떤 데이터가 필요한지 입력
    ///   - lastDate: 현재 달의 첫날/마지막 날
    /// - Returns: 이전달/다음달에 해당하는 날짜들 반환
    func getDatesOnNextMonth(on direction: ScrollDirection, after lastDate: Date) -> [Date] {
        var targetDate: Date
        switch(direction) {
        // 이전달의 일자 반환
        case .prevMonth:
            targetDate = Calendar.current.date(byAdding: .day, value: -1, to: lastDate) ?? Date()
            
        // 다음달의 일자 반환
        case .nextMonth:
            targetDate = Calendar.current.date(byAdding: .day, value: +1, to: lastDate) ?? Date()
            
        default:
            print(#fileID, #function, #line, "- error: Getting Wrong Direction of Further Dates")
            return []
        }
        print(#fileID, #function, #line, "- targetDate:", targetDate)
        let numOfDays = Calendar.current.range(of: .day, in: .month, for: targetDate)?.count ?? 0
        
        if numOfDays > 0 {
            let days = (0...numOfDays-1).map{
                Calendar.current.date(
                    byAdding: .day, value: $0, to: self.getAYearAndMonth(of: targetDate)
                ) ?? Date()
            }
            return days
        } else {
            print(#fileID, #function, #line, "- error: Getting Wrong Direction of Further Dates")
            return []
        }
    }
    
    func setScrollTargetDate(with date: Date) -> Date {
        print(#fileID, #function, #line, "- Set scroll target date to: ", date)
        return Calendar.current.startOfDay(for: date)
    }
    
//    func toggleDateBtnPressed() -> Bool {
//        return didDateBtnPressed ? false : true
//    }
    
    func getDatesInAMonth() -> [Date] {
        // 해당 월의 일자 수
        let numOfDays = Calendar.current.range(of: .day, in: .month, for: searchDate)?.count ?? 0
        if numOfDays > 0 {
            let days = (0...numOfDays-1).map{
                Calendar.current.date(
                    byAdding: .day,
                    value: $0,
                    to: self.getAYearAndMonth(of: self.searchDate)
                ) ?? Date()
            }
            return days
        } else {
            return []
        }
    }
    
    func setSearchDate(date: Date) -> Date {
        // 어떤 날짜이건 0시 0분으로 맞춘다.
//        print(#fileID, #function, #line, "- set date: \(date)")
        return Calendar.current.startOfDay(for: date)
    }
    
    func canShowOldTodos() -> Bool {
        if self.searchDate == Calendar.current.startOfDay(for: Date()) {
//            print(#fileID, #function, #line, "It is Today.")
            return true
        } else {
//            print(#fileID, #function, #line, "It isn't Today.")
            return false
        }
    }
    
//    func getTimePosition(of date: Date) -> TimePosition {
//        let startOfToday = Calendar.current.startOfDay(for: Date()) ?? Date()
//        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
//
//        if date < startOfToday {
//            return .past
//        } else if date >= startOfTomorrow {
//            return .future
//        } else if (date >= startOfToday) && (date < startOfTomorrow) {
//            return .today
//        } else {
//            print(#fileID, #function, #line, "- Error: Can not calculate a time position(past/today/future).")
//            return .none
//        }
//    }
    
    //MARK: - Core Data 관련
    func fetchTodos() -> [TodoItem] {
        // Fetch All Data in "Item" Entity
        // 전부 다 가져옴
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        var modifiedTodos: [TodoItem] = []
        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                               title: $0.title ?? "",
                                               duedate: $0.duedate ?? Date(),
                                               status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                               section: $0.section ?? "Today") }
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    /// duedate가 특정 일자에 해당하는 투두 가져오기
    /// - Parameter date: 찾고자 하는 일자
    /// - Returns: 특정 일자에 해당하는 투두 목록
    func fetchTodosBySelectedDate() -> [TodoItem] {
        let request = Item.fetchRequest()
        let date = self.searchDate
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        var modifiedTodos: [TodoItem] = []
        
        request.predicate = Item.searchByDatePredicate.withSubstitutionVariables(["dateToFind" : date, "nextDateToFind" : nextDate])
        
//        print(request.predicate)
        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                               title: $0.title ?? "",
                                               duedate: $0.duedate ?? Date(),
                                               status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                               section: $0.section ?? "Today") }
//            print(modifiedTodos)
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    func fetchOldTodos() -> [TodoItem] {
        let request = Item.fetchRequest()
        let date = self.searchDate
        var modifiedTodos: [TodoItem] = []
        
        request.predicate = Item.searchOldByDatePredicate.withSubstitutionVariables(["date" : date, "status" : TodoStatus.none.rawValue])
        
        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                               title: $0.title ?? "",
                                               duedate: $0.duedate ?? Date(),
                                               status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                               section: $0.section ?? "Today") }
//            print(modifiedTodos)
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    /// uuid로 찾은 투두 삭제
    /// - Parameter uuid: 삭제할 투두 uuid
    /// - Returns: 삭제 후 업데이트 된 투두 목록
    func deleteATodo(uuid: UUID) -> [TodoItem] {
        guard let foundItemEntity = findATodo(uuid: uuid) else { return [] }
        
        context.delete(foundItemEntity)
        do {
            try context.save()
            return fetchTodos()
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    
    /// 새로운 투두 추가하기
    /// - Parameter newTodo: 추가할 투두
    /// - Returns: 새로운 투두가 추가된 투두 목록
    func addATodo(_ newTodo: TodoItem) -> [TodoItem] {
        let newItemEntity = Item(context: context)
        
        newItemEntity.id = newTodo.id
        newItemEntity.uuid = newTodo.uuid
        newItemEntity.title = newTodo.title
        newItemEntity.duedate = newTodo.duedate
        newItemEntity.section = newTodo.section
        newItemEntity.status = newTodo.status.rawValue
        print(#fileID, #function, #line, "-추가하려는 투두: \(newItemEntity)")
        
        context.insert(newItemEntity)
        
        do {
            try context.save()
            return fetchTodosBySelectedDate()
        } catch {
            print(#fileID, #function, #line, "-error: \(error)")
            return []
        }
    }
    
    /// 특정 투두 수정하기
    /// - Parameters:
    ///   - updatingTodo: 수정할 투두
    ///   - title: 수정될 투두 제목 (옵셔널)
    ///   - status: 수정될 투두 상태 (옵셔널)
    ///   - duedate: 수정될 투두 기한 (옵셔널)
    /// - Returns: 특정 투두가 수정된 투두 목록
    func updateATodo(updatingTodo: TodoItem, title: String?, status: TodoStatus?, duedate: Date?) -> [TodoItem] {
        guard let targetTodo = findATodo(uuid: updatingTodo.uuid) else { return [] }
        
        if let safeTitle = title {
            targetTodo.title = safeTitle
        }
        if let safetStatus = status {
            targetTodo.status = safetStatus.rawValue
        }
        if let safeDuedate = duedate {
            targetTodo.duedate = safeDuedate
        }
        
        do {
            try context.save()
            return fetchTodosBySelectedDate()
        } catch {
            print(#fileID, #function, #line, "-error: \(error)")
            return []
        }
    }
    
    /// 저장되어 있던 모든 투두 삭제하기
    func clearAllTodos() {
        do {
            try context.execute(Item.deleteAllRequest())
            //try context.save()
            print("data all deleted.")
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
        }
    }
    
    func getDelayedDays(with duedate: Date) -> Int? {
        var numberOfDays: DateComponents? = Calendar.current.dateComponents([.day], from: Date(), to: duedate)
        if let numberOfDays = numberOfDays {
            return -numberOfDays.day!
        } else {
            return nil
        }
    }
}

//MARK: - Helper
extension TodoViewModel {
    /// uuid를 통해 투두 찾기
    /// - Parameter uuid: 찾을 투두의 uuid
    /// - Returns: 찾은 투두
    fileprivate func findATodo(uuid: UUID) -> Item? {
        let request = Item.fetchRequest()
        
        // uuid가 일치하는 투두 가져오기
        request.predicate = Item.searchByUUIDPredicate.withSubstitutionVariables(["uuid" : uuid])
        
        do {
            var fetchedTodos = try context.fetch(request) as [Item]
            return fetchedTodos.first
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return nil
        }
    }
    
    /// 지금 연도와 월의 첫날에 해당하는 날 얻기
    /// - Returns: 해당 연도와 월의 첫날에 해당하는 날짜 반환 (2023년 7월 23일 -> 2023년 7월 1일)
    fileprivate func getAYearAndMonth(of date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components) ?? Date()
    }
}



