//
//  CoreDataTodoRepository.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/21.
//

import Foundation
import CoreData
import Combine

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
    
    init() {
        self.todos = fetchTodos()
        self.oldTodos = fetchOldTodos()
        self.searchDate = setSearchDate(date: Date())
        self.datesInMonth = getDatesInThisMonth()
    }
    
    //MARK: - 캘린더 관련    
    func getDatesInThisMonth() -> [Date] {
        // 해당 월의 일자 수
        let numOfDays = Calendar.current.range(of: .day, in: .month, for: searchDate)?.count ?? 0
        if numOfDays > 0 {
            let days = (1...numOfDays).map{
                Calendar.current.date(byAdding: .day, value: $0, to: self.getThisYearAndMonth()) ?? Date()
            }
            return days
        } else {
            return []
        }
    }
    
    func setSearchDate(date: Date) -> Date {
        // 어떤 날짜이건 0시 0분으로 맞춘다.
        print(#fileID, #function, #line, "- set date: \(date)")
        return Calendar.current.startOfDay(for: date)
    }
    
    func canShowOldTodos() -> Bool {
        if self.searchDate == Calendar.current.startOfDay(for: Date()) {
            print(#fileID, #function, #line, "It is Today.")
            return true
        } else {
            print(#fileID, #function, #line, "It isn't Today.")
            return false
        }
    }
    
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
            print(modifiedTodos)
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
        
        context.insert(newItemEntity)
        
        do {
            try context.save()
            return fetchTodos()
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
            return fetchTodos()
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
}

//MARK: - Helper
extension TodoViewModel {
    /// uuid를 통해 투두 찾기
    fileprivate func findATodo(uuid: UUID) -> Item? {
        let request = Item.fetchRequest()
//        var modifiedTodos: [TodoItem] = []
        
        // uuid가 일치하는 투두 가져오기
        request.predicate = Item.searchByUUIDPredicate.withSubstitutionVariables(["uuid" : uuid])
        
        do {
            var fetchedTodos = try context.fetch(request) as [Item]
//            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid        ?? UUID(),
//                                               title: $0.title      ?? "",
//                                               duedate: $0.duedate  ?? Date(),
//                                               status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
//                                               section: $0.section  ?? "Today") }
            print(#fileID, #function, #line, "- ", uuid, " ", fetchedTodos.first?.uuid)
            return fetchedTodos.first
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return nil
        }
    }
    
    /// 지금 연도와 월의 첫날에 해당하는 날 얻기
    /// - Returns: 해당 연도와 월의 첫날에 해당하는 날짜 반환 (2023년 7월 23일 -> 2023년 7월 1일)
    /// -> 필요 없음...?
    fileprivate func getThisYearAndMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: searchDate)
        return Calendar.current.date(from: components) ?? Date()
    }
    
}
