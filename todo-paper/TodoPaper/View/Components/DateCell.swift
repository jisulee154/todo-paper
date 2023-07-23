//
//  DateCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation
import SwiftUI

struct DateCell: View {
//    @Binding var fetchModel: FetchModel
//    var date: Date
//
//    var onNewDateClicked: (Date) -> Void

    @ObservedObject var todoViewModel: TodoViewModel
    private var date: Date
    
    init(todoViewModel: TodoViewModel, date: Date) {
        self.todoViewModel = todoViewModel
        self.date = date
    }
    
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
                todoViewModel.searchDate = todoViewModel.setSearchDate(date: date)
                todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()

                print(#fileID, #function, #line, "set new searchDate: \(todoViewModel.searchDate)")
            }

        }
    }
}
