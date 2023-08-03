//
//  DateCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI

struct DateCell: View {
//    @Binding var fetchModel: FetchModel
//    var date: Date
//
//    var onNewDateClicked: (Date) -> Void

    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var stickerViewModel: StickerViewModel
    
    private var date: Date
    
    init(todoViewModel: TodoViewModel, stickerViewModel: StickerViewModel, date: Date) {
        self.todoViewModel = todoViewModel
        self.stickerViewModel = stickerViewModel
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
        VStack{
            Button {
                todoViewModel.searchDate = todoViewModel.setSearchDate(date: date)
                todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: date)
                todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                
                if todoViewModel.canShowOldTodos() {
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                }
                else {
                    todoViewModel.oldTodos = []
                }
                
                todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
                
                // 스티커 체크
                stickerViewModel.isTodayStickerOn = stickerViewModel.getTodayStickerOn(date: todoViewModel.searchDate)
                
                if stickerViewModel.isTodayStickerOn {
                    stickerViewModel.sticker = stickerViewModel.fetchSticker(on: todoViewModel.searchDate)
                }
//                print(#fileID, #function, #line, "set new searchDate: \(todoViewModel.searchDate)")
            } label: {
                VStack(alignment: .center) {
                    Text(title)
                    Text(subtitle)
                }
                .frame(width: 60, height: 65)
                .foregroundColor((date == todoViewModel.searchDate) ? Color.white : Color.themeColor40)
                .background((date == todoViewModel.searchDate) ? Color.themeColor40 : Color.white)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.themeColor40, lineWidth: 1)
                )
            }
        }
    }
}

