//
//  TodoViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/19.
//

import Foundation
import SwiftUI

class TodoViewModel: ObservableObject {
    //fetch from Core Data
    func fetchCoreData(with predicate: NSPredicate) -> FetchedResults<Item> {
        @FetchRequest(entity: Item.entity(),
                      sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
                      predicate: predicate,
                      animation: .default)
        var items: FetchedResults<Item>
        
        return items
    }
}
