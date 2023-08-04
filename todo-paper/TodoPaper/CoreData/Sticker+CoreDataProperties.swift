//
//  Sticker+CoreDataProperties.swift
//  
//
//  Created by 이지수 on 2023/08/04.
//
//

import Foundation
import CoreData


extension Sticker {
    //fetch All
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sticker> {
        return NSFetchRequest<Sticker>(entityName: "Sticker")
    }
    
    //delete All
    @nonobjc public class func deleteAllRequest() -> NSBatchDeleteRequest{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Sticker")
        return NSBatchDeleteRequest(fetchRequest: request)
    }
    
    @NSManaged public var date: Date?
    @NSManaged public var isExist: Bool
    @NSManaged public var stickerBgColor: String?
    @NSManaged public var stickerName: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var id: UUID?
}

//MARK: - Predicate
extension Sticker {
    // Date 검색 필터링
    static var searchByDatePredicate: NSPredicate {
        NSPredicate(format: "%K == $search_date", #keyPath(date))
    }
    
    // uuid 검색 필터링
    static var searchByUUIDPredicate: NSPredicate {
        NSPredicate(format: "%K == $search_uuid", #keyPath(uuid))
    }
}
