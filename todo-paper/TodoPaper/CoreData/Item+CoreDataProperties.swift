//
//  Item+CoreDataProperties.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/21.
//
//

import Foundation
import CoreData

extension Item {

    //fetch All
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }
    
    //delete All
    @nonobjc public class func deleteAllRequest() -> NSBatchDeleteRequest{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        return NSBatchDeleteRequest(fetchRequest: request)
    }
    
    //데이터들
    @NSManaged public var duedate: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var status: Int32
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var completeDate: Date?
//    @NSManaged public var stickerName: String?
//    @NSManaged public var section: String?
//    @NSManaged public var onToday: Bool
    

}

//MARK: - Predicate
extension Item {
    // UUID 검색 필터링
    static var searchByUUIDPredicate: NSPredicate {
        NSPredicate(format: "%K == $uuid", #keyPath(uuid))
    }
    
    // Date 검색 필터링 - 특정한 일자에 해당하는 투두
    static var searchByDatePredicate: NSPredicate {
        NSPredicate(format: "%K >= $dateToFind && %K < $nextDateToFind", #keyPath(duedate), #keyPath(duedate))
    }
    
    // Date 검색 필터링 - 특정한 일자 이전 일자에 해당하는 투두
    static var searchOldByDatePredicate: NSPredicate {
//        NSPredicate(format: "%K < $date && (%K == $status_none || %K == $status_postponed)", #keyPath(duedate), #keyPath(status), #keyPath(status))
        NSPredicate(format: "%K < $date && (%K == $status_none)", #keyPath(duedate), #keyPath(status))
    }
    
    // 오늘 완료한 old 투두 검색
    static var searchOldTodosCompletedOnTodayPredicate: NSPredicate {
        NSPredicate(format: "%K < $date && %K == $completeDate", #keyPath(duedate), #keyPath(completeDate))
    }
    
    //MARK: - CompleteRepoView 관련
    // 기한 내에 완료한 투두 가져오기
    static var searchCompletedOnTimePredicate: NSPredicate {
        NSPredicate(format: "%K == $date", #keyPath(duedate))
//        NSPredicate(format: "%K == $date && %K == $completeDate", #keyPath(duedate), #keyPath(completeDate))
//        NSPredicate(format: "%K <= $completeDate", #keyPath(completeDate))
    }

    // 기한이 지나서 완료한 투두 가져오기
    static var searchCompletedOverTimePredicate: NSPredicate {
        NSPredicate(format: "%K < $date && %K == $completeDate", #keyPath(duedate), #keyPath(completeDate))
//        NSPredicate(format: "%K > $completeDate", #keyPath(completeDate))
    }
}
