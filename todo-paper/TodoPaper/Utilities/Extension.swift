//
//  Extension.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation
import SwiftUI

extension Color {
    static let themeColor10 = Color("ThemeColor10")
    static let themeColor20 = Color("ThemeColor20")
    static let themeColor30 = Color("ThemeColor30")
    static let themeColor40 = Color("ThemeColor40")
}

extension Date {
    func daysThisMonth() -> Int? {
//        // 2023-06-30 지난달 마지막 날
//        let components = Calendar.current.dateComponents([.year, .month], from: self)
//        let lastDate = DateComponents(year: components.year, month:components.month)
//
//        // 2023-07-31 이번달 마지막 날
//        let lastDateThisMonth = Calendar.current.date(byAdding: .month, value: +1, to: Calendar.current.date(from: lastDate)!)
//        lastDateThisMonth.
//        let lastDateComponents = Calendar.current.dateComponents([.day, .year, .month], from: lastDateThisMonth!)
//        let days = lastDateComponents.day!
//        return days
        
        return Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
        
    }
}

extension Image {
    func todoImageModifier() -> some View {
        self
            .resizable()
            .frame(width: 30, height: 30)
    }
}
