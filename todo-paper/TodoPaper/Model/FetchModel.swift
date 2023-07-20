//
//  FetchModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/20.
//

import Foundation
import SwiftUI

struct FetchModel: Equatable {
    var currentDate: Date?
    var predicate: NSPredicate? {
        guard let currentDate = currentDate else { return nil }
        return NSPredicate(format: "duedate >= %@ && duedate <= %@",
                           currentDate as CVarArg,
                           Calendar.current.startOfDay(for: currentDate + 86400) as CVarArg)
    }
}
