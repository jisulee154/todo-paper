//
//  DetailTodoViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/27.
//

import BottomSheetSwiftUI
import AlertToast

class DetailTodoViewModel: ObservableObject {
    @Published var timePosition: TimePosition = .today
    @Published var updatingDate: Date = Date()
    @Published var pickedTodo: TodoItem = TodoItem(title: "")
    
    @Published var addTodoBottomSheetPosition: BottomSheetPosition = .hidden
    @Published var settingBottomSheetPosition: BottomSheetPosition = .hidden
    @Published var datePickerBottomSheetPosition: BottomSheetPosition = .hidden
    @Published var editBottomSheetPosition: BottomSheetPosition = .hidden
    @Published var setStickerBottomSheetPosition: BottomSheetPosition = .hidden
    
    @Published var editingTitle: String = "" // 투두 수정하기 텍스트필드 입력값
    
    @Published var showPostponedToast: Bool = false
//    @Published var showOldTodoPostponedToast: Bool = false
    @Published var showDeletedToast: Bool = false
    @Published var showChangedAsTodayToast: Bool = false
    @Published var showAnotherDayToast: Bool = false
    @Published var showUnfinishedTodosToast: Bool = false
    @Published var showCantPutStickerYet: Bool = false
    @Published var showCantPutStickerNone: Bool = false
    @Published var showCantPutStickerNonePast: Bool = false
    
    init(
        timePosition: TimePosition = .today,
        updatingDate: Date = Date(),
        pickedTodo: TodoItem = TodoItem(title: ""),
        addTodoBottomSheetPosition: BottomSheetPosition = .hidden,
        settingBottomSheetPosition: BottomSheetPosition = .hidden,
        datePickerBottomSheetPosition: BottomSheetPosition = .hidden,
        editBottomSheetPosition: BottomSheetPosition = .hidden
    ) {
        self.timePosition = timePosition
        self.updatingDate = updatingDate // Date Picker에서 선택한 날짜
        self.pickedTodo = pickedTodo
        
        self.addTodoBottomSheetPosition = addTodoBottomSheetPosition
        self.settingBottomSheetPosition = settingBottomSheetPosition
        self.datePickerBottomSheetPosition = datePickerBottomSheetPosition
        self.editBottomSheetPosition = editBottomSheetPosition
    }
    
    func setPickedTodo(pickedTodo: TodoItem) {
        self.pickedTodo = pickedTodo
    }
    
    func getTimePosition(of date: Date) -> TimePosition {
        let startOfToday = Calendar.current.startOfDay(for: Date()) ?? Date()
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday) ?? Date()
        
        if date < startOfToday {
            return .past
        } else if date >= startOfTomorrow {
            return .future
        } else if (date >= startOfToday) && (date < startOfTomorrow) {
            return .today
        } else {
            print(#fileID, #function, #line, "- Error: Can not calculate a time position(past/today/future).")
            return .none
        }
    }
}
