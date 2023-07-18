//
//  DateFormat.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/17.
//

import Foundation
import SwiftUI

struct DateFormat {
    @Binding private var sampleDate: Date
    @Binding private var convertDateStr: String
    
    private func transfer() {
        var dateFormatter: DateFormatter
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        convertDateStr = dateFormatter.string(from: sampleDate)
    }
}
