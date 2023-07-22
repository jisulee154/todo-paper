//
//  Persistence.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // 컨테이너: 디비자체 - 해당 디비 이름으로 생성
        container = NSPersistentContainer(name: "todo_paper")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // NSManagedObjectContext: 모든 테이블들의 중재자, 관리자
        // NSManagedObject: 디비 테이블
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
