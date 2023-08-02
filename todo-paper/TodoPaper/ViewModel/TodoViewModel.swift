//
//  CoreDataTodoRepository.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/21.
//

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
    case prev  = 0
    case next  = 1
}

protocol TodoItemProtocol {
    var todos: [TodoItem] { get }
    func fetchTodos() -> [TodoItem]
    func deleteATodo(uuid: UUID) -> [TodoItem]
    func addATodo(_ newTodo: TodoItem) -> [TodoItem]
    func updateATodo(updatingTodo: TodoItem, title: String?, status: TodoStatus?, duedate: Date?, completeDate: Date?) -> [TodoItem]
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
    @Published var allTodosOnToday: [TodoItem] = []
    @Published var searchDate: Date = Calendar.current.startOfDay(for: Date())
    
    let settingDatesSize: Int = 30 // 날짜 캘린더에 처음 출력되는 일자 수
    let addingDatesSize: Int = 3 // 스크롤하면 더 불러오는 일자 수
    @Published var defaultDates: [Date] = []
    //    @Published var datesInMonth: [Date] = []
    
    @Published var completeSticker: CompleteStickerStatus = CompleteStickerStatus.none
    @Published var scrollTargetDate: Date = Date()
    @Published var delayedDays: Int? = 0
    @Published var isActivePutSticker: Bool = false
    
    @Published var showSettingView: Bool = false
    @Published var showCompleteStickerView: Bool = false
    @Published var isTodosDone: Bool = false
    
    
    
    init() {
        self.todos = fetchTodos()
        self.oldTodos = fetchOldTodos()
        self.searchDate = setSearchDate(date: Date())
//        self.datesInMonth = getDatesInAMonth()
        self.defaultDates = getDefaultDates(numDates: settingDatesSize)
        self.completeSticker = setCompleteSticker(with: "")
        self.scrollTargetDate = setScrollTargetDate(with: Date())
        self.delayedDays = getDelayedDays(with: Calendar.current.startOfDay(for: Date()))
//        self.timePosition = getTimePosition(of: Date())
    }
    
    
    //MARK: - 완료 스티커 관련
    func getActivePutSticker() -> Bool {
        // 미완료한 일이 없는 날(미래 제외)에만 칭찬 스티커를 붙일 수 있다.
        let timePosition = DetailTodoViewModel.getTimePosition(of: searchDate)
        let todos = fetchTodosBySelectedDate()
        var oldTodos: [TodoItem] = []
        if timePosition == .today {
            oldTodos = fetchOldTodos()
        }
        
        isTodosDone = getTodosDone(todos: todos, oldTodos: oldTodos)
        
        if (timePosition == .today || timePosition == .past) {
            if isTodosDone {
                //미완료 투두가 없음
                if todos.isEmpty && oldTodos.isEmpty {
                    // 설정된 투두가 없어 칭찬 스티커 붙일 수 없음 안내
                    if timePosition == .past {
                        return false
                    } else {
                        return false
                    }
                } else {
                    return true
                }
            } else {
                //미완료 투두 있음
                
                // 미완료 투두 있음 토스트 메시지
                return false
            }
            
        }
        else {
            // 해당 일자(미래)엔 아직 칭찬 스티커 붙일 수 없음 안내
            return false
        }
    }
    
    func getTodosDone(todos: [TodoItem], oldTodos: [TodoItem]) -> Bool {
        for todo in todos {
            if todo.status == .none {
                return false
            }
        }
        for oldTodo in oldTodos {
            if oldTodo.status == .none {
                return false
            }
        }
        
        return true
    }
    
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
    
    /// 주어진 일자(numDates)만큼의 일자를 반환한다.
    /// - Parameters:
    ///   - direction: 기준일 이전인지 이후인지 입력
    ///   - lastDate: 기준일
    ///   - numDates: 얼마만큼의 일자를 더 가져올지 입력
    /// - Returns: 주어진 일자만큼의 일자 배열
    func getMoreDates(on direction: ScrollDirection, after lastDate: Date, numDates: Int) -> [Date] {
        var resDates: [Date] = []
        
        switch(direction) {
        case .prev:
            // 이전 N일치의 일자 반환
            for i in 1...numDates {
                let newDate = Calendar.current.date(byAdding: .day, value: -i, to: lastDate) ?? Date()
                resDates.insert(newDate, at: 0)
            }
            return resDates
            
        case .next:
            // 다음 N일치의 일자 반환
            for i in 1...numDates {
                let newDate = Calendar.current.date(byAdding: .day, value: i, to: lastDate) ?? Date()
                resDates.append(newDate)
            }
            return resDates
            
        default:
            print(#fileID, #function, #line, "- error: Getting Wrong Direction of Further Dates")
            return []
        }
    }
    
//    /// 이전달이나 다음달의 날짜를 반환한다
//    /// - Parameters:
//    ///   - direction: 이전달/다음달 중 어떤 데이터가 필요한지 입력
//    ///   - lastDate: 현재 달의 첫날/마지막 날
//    /// - Returns: 이전달/다음달에 해당하는 날짜들 반환
//    func getDatesOnNextMonth(on direction: ScrollDirection, after lastDate: Date) -> [Date] {
//        var targetDate: Date
//        switch(direction) {
//        // 이전달의 일자 반환
//        case .prev:
//            targetDate = Calendar.current.date(byAdding: .day, value: -1, to: lastDate) ?? Date()
//
//        // 다음달의 일자 반환
//        case .next:
//            targetDate = Calendar.current.date(byAdding: .day, value: +1, to: lastDate) ?? Date()
//
//        default:
//            print(#fileID, #function, #line, "- error: Getting Wrong Direction of Further Dates")
//            return []
//        }
//
//        let numOfDays = Calendar.current.range(of: .day, in: .month, for: targetDate)?.count ?? 0
//
//        if numOfDays > 0 {
//            let days = (0...numOfDays-1).map{
//                Calendar.current.date(
//                    byAdding: .day, value: $0, to: self.getAYearAndMonth(of: targetDate)
//                ) ?? Date()
//            }
//            return days
//        } else {
//            print(#fileID, #function, #line, "- error: Getting Wrong Direction of Further Dates")
//            return []
//        }
//    }
    
    func setScrollTargetDate(with date: Date) -> Date {
        print(#fileID, #function, #line, "- Set scroll target date to: ", date)
        return Calendar.current.startOfDay(for: date)
    }
    
    func getDefaultDates(numDates: Int) -> [Date] {
        var resDates : [Date] = [searchDate]
        
        for i in 1...numDates/2 {
            let newDate = Calendar.current.date(byAdding: .day, value: -i, to: searchDate) ?? Date()
            resDates.insert(newDate, at: 0)
        }
        
        for i in 1...numDates/2 {
            let newDate = Calendar.current.date(byAdding: .day, value: i, to: searchDate) ?? Date()
            resDates.append(newDate)
        }
        
        return resDates
    }
    
//    func getDatesInAMonth() -> [Date] {
//        // 해당 월의 일자 수
//        let numOfDays = Calendar.current.range(of: .day, in: .month, for: searchDate)?.count ?? 0
//        if numOfDays > 0 {
//            let days = (0...numOfDays-1).map{
//                Calendar.current.date(
//                    byAdding: .day,
//                    value: $0,
//                    to: self.getAYearAndMonth(of: self.searchDate)
//                ) ?? Date()
//            }
//            return days
//        } else {
//            return []
//        }
//    }
    
    func setSearchDate(date: Date) -> Date {
        // 어떤 날짜이건 0시 0분으로 맞춘다.
        return Calendar.current.startOfDay(for: date)
    }
    
    func canShowOldTodos() -> Bool {
        if self.searchDate == Calendar.current.startOfDay(for: Date()) {
            return true
        } else {
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
                                               completeDate: $0.completeDate) }
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
                                               completeDate: $0.completeDate) }
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
        
        modifiedTodos += fetchOldTodosOnToday()
        
        request.predicate = Item.searchOldByDatePredicate.withSubstitutionVariables(["date" : date, "status_none" : TodoStatus.none.rawValue, "status_postponed" : TodoStatus.postponed.rawValue])
        
        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos += fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                               title: $0.title ?? "",
                                               duedate: $0.duedate ?? Date(),
                                               status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                               completeDate: $0.completeDate) }
//            print(modifiedTodos)
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    /// 오늘 해야하는 투두 가져오기 (과거 미완료 투두 포함)
    /// - Returns: 오늘 해야하는 투두들
    func fetchOldTodosOnToday() -> [TodoItem] {
        let request = Item.fetchRequest()
        let date = self.searchDate
        var modifiedTodos: [TodoItem] = []
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // NSPredicate(format: "%K < $date && %K == $completeDate", #keyPath(duedate), #keyPath(completeDate))
        request.predicate = Item.searchOldTodosCompletedOnTodayPredicate.withSubstitutionVariables(["date" : today, "completeDate" : today])
        
        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                                       title: $0.title ?? "",
                                                       duedate: $0.duedate ?? Date(),
                                                       status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                                       completeDate: $0.completeDate) }
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
            return fetchTodosBySelectedDate()
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
        newItemEntity.status = newTodo.status.rawValue
        newItemEntity.completeDate = newTodo.completeDate
//        newItemEntity.section = newTodo.section
//        newItemEntity.onToday = newTodo.onToday
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
    func updateATodo(updatingTodo: TodoItem, title: String?, status: TodoStatus?, duedate: Date?, completeDate: Date?) -> [TodoItem] {
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
        targetTodo.completeDate = completeDate
        
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



