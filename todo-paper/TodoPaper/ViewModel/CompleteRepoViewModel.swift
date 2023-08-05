//
//  CompleteRepoViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/04.
//

import Foundation
import SwiftUI
import CoreData

class CompleteRepoViewModel: ObservableObject {
    let container = PersistenceController.shared.container
    
    // 모든 테이블 관리자, 중재자.
    fileprivate var context: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    @Published var allDates: [Date] = []
    @Published var completeDates: [Date] = []
    @Published var watchingDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var todos: [TodoItem] = []
    @Published var oldTodos: [TodoItem] = []
    @Published var completePages: [CompletePage] = []
    @Published var dateFormatted: String = ""
    @Published var stickerName: String = ""
    
//    init(completeDates: [Date], watchingDate: Date, completePages: [CompletePage]) {
//        self.completeDates = getCompleteDates(allDates: allDates)
//        self.watchingDate = watchingDate
//        self.completePages = getCompletePages()
//    }
//
    func setAllDates(allDates: [Date]) {
        self.allDates = allDates
    }
    
    func fetchAllDates() -> [Date] {
        // Fetch All data in "Sticker" Entity
        let request: NSFetchRequest<Sticker> = Sticker.fetchRequest()
        var resultDates: [Date] = []
        do {
            let fetchedStickers = try context.fetch(request) as [Sticker]
            print(fetchedStickers)
            resultDates = fetchedStickers.map{ $0.date ?? Calendar.current.startOfDay(for: Date()) }
            
            return Array(Set(resultDates))
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    //MARK: - Helper
    /// 완료 스티커가 첨부된 날짜들을 반환한다
    func getCompleteDates(allDates: [Date]) -> [Date] {
        let request = Sticker.fetchRequest()
        var result: [Date] = []
        var modifiedResult: StickerItem?
        
        for date in allDates {
            request.predicate = Sticker.searchByDatePredicate.withSubstitutionVariables(["search_date" : date])
            
            do {
                let fetchResult = try context.fetch(request) as [Sticker]
                modifiedResult = fetchResult.map {
                    StickerItem(uuid: $0.uuid ?? UUID(),
                                date: $0.date ?? Date(),
                                isExist: $0.isExist,
                                stickerName: $0.stickerName,
                                stickerBgColor: $0.stickerBgColor)
                }.first ?? nil
                
                if let safeModifiedResult = modifiedResult {
                    if safeModifiedResult.isExist {
                        // 설정된 스티커가 있는 날짜만 추가한다
                        result.append(date)
                    }
                }
                
            } catch {
                print(#fileID, #function, #line, "- error: \(error)")
            }
        }
        return result
    }
    
    /// 작성일 당일에 완료한 투두 가져오기
    func getTodos(on date: Date) -> [TodoItem] {
        let request = Item.fetchRequest()
        var modifiedTodos: [TodoItem] = []
        
        request.predicate = Item.searchCompletedOnTimePredicate.withSubstitutionVariables(["date" : date, "completeDate" : date])

        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                                       title: $0.title ?? "",
                                                       duedate: $0.duedate ?? Date(),
                                                       status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                                       completeDate: $0.completeDate) }
//            print(#fileID, #function, #line, "-------작성일 당일에 완료한 투두")
//            print(date)
//            print(modifiedTodos)
            
            // 정렬
            modifiedTodos.sort { $0.status.rawValue < $1.status.rawValue }
            
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    ///작성일 이후에 완료한 투두 가져오기
    func getOldTodos(on date: Date) -> [TodoItem] {
        let request = Item.fetchRequest()
        var modifiedTodos: [TodoItem] = []
        
        request.predicate = Item.searchCompletedOverTimePredicate.withSubstitutionVariables(["date" : date, "completeDate" : date])

        do {
            let fetchedTodos = try context.fetch(request) as [Item]
            modifiedTodos = fetchedTodos.map{ TodoItem(uuid: $0.uuid ?? UUID(),
                                                       title: $0.title ?? "",
                                                       duedate: $0.duedate ?? Date(),
                                                       status: TodoStatus(rawValue: $0.status) ?? TodoStatus.none,
                                                       completeDate: $0.completeDate) }
//            print(#fileID, #function, #line, "----------작성일 이후에 완료한 투두")
//            print(date)
//            print(modifiedTodos)
            
            // 정렬
            modifiedTodos.sort { $0.status.rawValue < $1.status.rawValue }
            
            return modifiedTodos
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return []
        }
    }
    
    func getStickerName(on date: Date) -> String {
        let request = Sticker.fetchRequest()
        
        request.predicate = Sticker.searchByDatePredicate.withSubstitutionVariables(["search_date" : date])

        do {
            let fetchResult = try context.fetch(request) as [Sticker]
            for res in fetchResult {
                if res.isExist && (res.stickerName != nil) {
                    return res.stickerName ?? ""
                }
            }
            return ""
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return ""
        }
    }
    
    func getCompletePages() -> [CompletePage] {
        var result: [CompletePage] = []
        
        for date in completeDates {
            todos = getTodos(on: date)
            oldTodos = getOldTodos(on: date)
            dateFormatted = getDateFormatted(on: date)
            stickerName = getStickerName(on: date)
            
            result.append(CompletePage(date: date,
                                       todos: todos,
                                       oldTodos: oldTodos,
                                       dateFormatted: dateFormatted,
                                       stickerName: stickerName))
        }
        
        // 정렬
        result.sort { $0.date > $1.date }
        return result
    }
    
    func getDateFormatted(on date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd EEEE"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        return dateFormatter.string(from: date)
    }
//    func fetchSticker(on date: Date) -> StickerItem? {
//        let request = Sticker.fetchRequest()
//        var modifiedResult: StickerItem?
//        request.predicate = Sticker.searchByDatePredicate.withSubstitutionVariables(["search_date" : date])
//
//        do {
//            let fetchResult = try context.fetch(request) as [Sticker]
//            modifiedResult = fetchResult.map {
//                StickerItem(uuid: $0.uuid ?? UUID(),
//                            date: $0.date ?? Date(),
//                            isExist: $0.isExist,
//                            stickerName: $0.stickerName,
//                            stickerBgColor: $0.stickerBgColor)
//            }.first ?? nil
//
//            return modifiedResult
//        } catch {
//            print(#fileID, #function, #line, "- error: \(error)")
//            return nil
//        }
//    }
//
//    func addSticker(_ newSticker: StickerItem) -> StickerItem? {
//        let newStickerEntity = Sticker(context: context)
//
////        newStickerEntity.id = newSticker.id
//        newStickerEntity.uuid = newSticker.uuid
//        newStickerEntity.date = newSticker.date
//        newStickerEntity.isExist = newSticker.isExist
//        newStickerEntity.stickerName = newSticker.stickerName
//        newStickerEntity.stickerBgColor = newSticker.stickerBgColor
//
//        context.insert(newStickerEntity)
//
//        do {
//            try context.save()
//            return fetchSticker(on: newSticker.date)
//        } catch {
//            print(#fileID, #function, #line, "-error: \(error)")
//            return nil
//        }
//    }
//
//    func updateASticker(updatingSticker: StickerItem,
//                     date: Date?,
//                     isExist:Bool?,
//                     stickerName: String?,
//                     stickerBgColor: String?) -> StickerItem? {
//
//        guard let targetSticker = findASticker(uuid: updatingSticker.uuid) else { return nil }
//
//        if let safeDate = date {
//            targetSticker.date = safeDate
//        }
//        if let safeIsExist = isExist {
//            targetSticker.isExist = safeIsExist
//        }
//        targetSticker.stickerName = stickerName
//        targetSticker.stickerBgColor = stickerBgColor
////        if let safeStickerName = stickerName {
////            targetSticker.stickerName = safeStickerName
////        }
////        if let safeStickerBgColor = stickerName {
////            targetSticker.stickerBgColor = safeStickerBgColor
////        }
//
//        do {
//            try context.save()
//            return fetchSticker(on: updatingSticker.date)
//        } catch {
//            print(#fileID, #function, #line, "-error: \(error)")
//            return nil
//        }
//    }
//
////    func getTodayStickerOn(date: Date) -> Bool {
////        if let stickerItem = fetchSticker(on: date) {
////            return true
////        } else {
////            return false
////        }
////    }
//    func getTodayStickerOn(date: Date) -> Bool {
//        var fetchResult = fetchSticker(on: date)
//
//        if let safeFetchResult = fetchResult {
//            if safeFetchResult.isExist {
//                return true
//            }
//            else {
//                return false
//            }
//        } else {
//            return false
//        }
//    }
    
}

//MARK: - Helper
extension CompleteRepoView {
    
    
}
