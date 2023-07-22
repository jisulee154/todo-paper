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
    @NSManaged public var uuid: UUID?
    @NSManaged public var section: String?
    @NSManaged public var status: Int32
    @NSManaged public var title: String?

}

extension Item : Identifiable {

}

//MARK: - Predicate
extension Item {
    
    // UUID 검색 필터링
    static var searchByUUIDPredicate: NSPredicate {
        NSPredicate(format: "%K == $uuid", #keyPath(uuid))
    }
}
