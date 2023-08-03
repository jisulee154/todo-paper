//
//  StickerViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/03.
//

import Combine
import Foundation
import SwiftUI
import CoreData

class StickerViewModel: ObservableObject {
    let container = PersistenceController.shared.container
    
    // 모든 테이블 관리자, 중재자.
    fileprivate var context: NSManagedObjectContext {
        return self.container.viewContext
    }
    
    //fileprivate var request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sticker")
    
    @Published var sticker: StickerItem? = nil
    @Published var stickerCases: [StickerCase] = []
    @Published var stickerName: String?
    @Published var stickerBgColor: Color
    @Published var isTodayStickerOn : Bool
//    @Published var showSticker: Bool
//    @Published var pickedSticker: StickerItem
//    @Published var stickers: [StickerItem]
    
    init(stickerName:String? = nil,
         stickerBgColor: Color = Color.white,
         isTodayStickerOn: Bool = false) {
        self.stickerBgColor = stickerBgColor
        self.stickerName = stickerName
        self.isTodayStickerOn = isTodayStickerOn
//        self.showSticker = showSticker
    }
    
    func getStickerCases() -> [StickerCase] {
        var result: [StickerCase] = []
        for st in StickerCase.allCases {
            result.append(st)
        }
        return result
    }
    
    func fetchSticker(on date: Date) -> StickerItem? {
        let request = Sticker.fetchRequest()
        var modifiedResult: StickerItem
        request.predicate = Sticker.searchByDatePredicate.withSubstitutionVariables(["search_date" : date])
        
        do {
            let fetchResult = try context.fetch(request) as [Sticker]
            modifiedResult = fetchResult.map {
                StickerItem(uuid: $0.uuid ?? UUID(),
                            date: $0.date ?? Date(),
                            isExist: $0.isExist,
                            stickerName: $0.stickerName,
                            stickerBgColor: $0.stickerBgColor)
            }.first!
            
            return modifiedResult
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return nil
        }
    }
    
    func addSticker(_ newSticker: StickerItem) -> StickerItem? {
        let newStickerEntity = Sticker(context: context)
        
//        newStickerEntity.id = newSticker.id
        newStickerEntity.uuid = newSticker.uuid
        newStickerEntity.date = newSticker.date
        newStickerEntity.isExist = newSticker.isExist
        newStickerEntity.stickerName = newSticker.stickerName
        newStickerEntity.stickerBgColor = newSticker.stickerBgColor
        
        context.insert(newStickerEntity)
        
        do {
            try context.save()
            return fetchSticker(on: newSticker.date)
        } catch {
            print(#fileID, #function, #line, "-error: \(error)")
            return nil
        }
    }
    
    func updateASticker(updatingSticker: StickerItem,
                     date: Date?,
                     isExist:Bool?,
                     stickerName: String?,
                     stickerBgColor: String?) -> StickerItem? {
        
        guard let targetSticker = findASticker(uuid: updatingSticker.uuid) else { return nil }
        
        if let safeDate = date {
            targetSticker.date = safeDate
        }
        if let safeIsExist = isExist {
            targetSticker.isExist = safeIsExist
        }
        targetSticker.stickerName = stickerName
        targetSticker.stickerBgColor = stickerBgColor
//        if let safeStickerName = stickerName {
//            targetSticker.stickerName = safeStickerName
//        }
//        if let safeStickerBgColor = stickerName {
//            targetSticker.stickerBgColor = safeStickerBgColor
//        }
        
        do {
            try context.save()
            return fetchSticker(on: updatingSticker.date)
        } catch {
            print(#fileID, #function, #line, "-error: \(error)")
            return nil
        }
    }
    
    func getTodayStickerOn(date: Date) -> Bool {
        if let stickerItem = fetchSticker(on: date) {
            return true
        } else {
            return false
        }
    }
}

extension StickerViewModel {
    fileprivate func findASticker(uuid: UUID) -> Sticker? {
        let request = Sticker.fetchRequest()
        
        // date가 일치하는 결과 가져오기
        request.predicate = Sticker.searchByUUIDPredicate.withSubstitutionVariables(["search_uuid" : uuid])
        
        do {
            var fetchedResult = try context.fetch(request) as [Sticker]
            return fetchedResult.first
        } catch {
            print(#fileID, #function, #line, "- error: \(error)")
            return nil
        }
    }
}
