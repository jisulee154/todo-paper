//
//  OverflowScrollDailyCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation
import SwiftUI

struct OverflowScrollDailyCell: View {
    
    var date: Date
    
    var title: String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: date)
    }
    
    var subtitle: String {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
            Text(subtitle)
        }
    }
}
