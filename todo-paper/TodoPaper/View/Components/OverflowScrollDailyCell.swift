//
//  OverflowScrollDailyCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation
import SwiftUI

struct OverflowScrollDailyCell: View {
//    @Binding var selectedDate: Date
    @Binding var fetchModel: FetchModel
//    @Binding var refreshTodoList: Bool
    var date: Date
    
    var title: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "EEE"
        return df.string(from: Calendar.current.startOfDay(for: date))
    }
    
    var subtitle: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M/d"
        return df.string(from: Calendar.current.startOfDay(for: date))
    }
    
    var body: some View {
        Button {
            //pass
        } label: {
            VStack(alignment: .center) {
                Text(title)
                Text(subtitle)
            }
            .frame(width: 60, height: 73)
            .foregroundColor(Color.themeColor40)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.themeColor40, lineWidth: 1)
            )
            .onTapGesture {
                fetchModel.currentDate = Calendar.current.startOfDay(for: date)
                print("currentDate: ", fetchModel.currentDate)
//                refreshTodoList.toggle()
            }
            
        }
    }
}
