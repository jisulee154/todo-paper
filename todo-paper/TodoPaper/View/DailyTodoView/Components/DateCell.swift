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
    @ObservedObject var settingViewModel: SettingViewModel
    
    private var date: Date
    
    init(todoViewModel: TodoViewModel, stickerViewModel: StickerViewModel, settingViewModel: SettingViewModel, date: Date) {
        self.todoViewModel = todoViewModel
        self.stickerViewModel = stickerViewModel
        self.settingViewModel = settingViewModel
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
                if settingViewModel.enableHideGaveUpTask {
                    // 포기한 일 숨기기 true일 때
                    todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
                }
                
                if todoViewModel.canShowOldTodos() {
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                    if settingViewModel.enableHideGaveUpTask {
                        // 포기한 일 숨기기 true일 때
                        todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
                    }
                }
                else {
                    todoViewModel.oldTodos = []
                }
                
                // 스티커 체크
                todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
                
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

