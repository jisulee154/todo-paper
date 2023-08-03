//
//  Header.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI
import Introspect


struct Header: View {
    //    var onNewDateClicked: (Date) -> Void
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var stickerViewModel: StickerViewModel
    @StateObject var scrollViewModel: ScrollViewModel
    
    init(todoViewModel: TodoViewModel, stickerViewModel: StickerViewModel) {
        self._scrollViewModel = StateObject.init(
            wrappedValue: ScrollViewModel(lthreshold: -10, rthreshold: 0)
        )
        self.todoViewModel = todoViewModel
        self.stickerViewModel = stickerViewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                // 오늘로 이동 버튼
                makeGoToTodayButton()
                Spacer()
                // 앱 환경 설정 버튼
                makeSettingButton()
            }
            
            // 캘린더 스크롤
            makeScrollCalendar()
        }
    }
    
    //MARK: - 오늘로 이동 버튼
    private func makeGoToTodayButton() -> some View {
        Button {
            todoViewModel.searchDate = todoViewModel.setSearchDate(date: Date())
//                    todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: Date())
            todoViewModel.scrollTargetDate = Calendar.current.date(byAdding: .second, value: 1, to: todoViewModel.searchDate) ?? Date() // 더 좋은 방법 없을까..?
            todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
        } label: {
            Text("오늘")
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .overlay {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.themeColor40, lineWidth: 2)
                }
                
        }
        .buttonStyle(PressableButtonStyle())
        .padding(.horizontal, 20)
        .padding(.vertical, 1)
        
    }
    
    //MARK: - 환경 설정 버튼
    private func makeSettingButton() -> some View {
        Button {
            todoViewModel.showSettingView.toggle()
        } label: {
            Image(systemName: "gearshape")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.themeColor40)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 5)
        .fullScreenCover(isPresented: $todoViewModel.showSettingView) {
            SettingView(todoViewModel: todoViewModel)
        }
    
        
    }
    
    //MARK: - 캘린더 스크롤
    private func makeScrollCalendar() -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
//                    ForEach(todoViewModel.datesInMonth, id:\.self) { date in
//                        DateCell(todoViewModel: todoViewModel, date: date)
//                            .id(date)
//                    }
                    ForEach(todoViewModel.defaultDates, id:\.self) { date in
                        DateCell(todoViewModel: todoViewModel, stickerViewModel: stickerViewModel, date: date)
                            .id(date)
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(todoViewModel.scrollTargetDate, anchor: .center)
                        }
                    }
                    .onChange(of: scrollViewModel.isLeadingValue) { isLeading in
                        if isLeading {
                            let anchorDate = todoViewModel.defaultDates.first!
                            todoViewModel.defaultDates.insert(
                                contentsOf: todoViewModel.getMoreDates(on: .prev, after: anchorDate, numDates: todoViewModel.addingDatesSize)
                                ,at: 0)
//                            scrollViewModel.isLeadingValue = false
                        }
                    }
                    .onChange(of: scrollViewModel.isTrailingValue) { isTrailing in
                        if isTrailing {
                            let anchorDate = todoViewModel.defaultDates.last!
                            todoViewModel.defaultDates.append(
                                contentsOf: todoViewModel.getMoreDates(on: .next, after: anchorDate, numDates: todoViewModel.addingDatesSize))
                        }
                    }
//                    .onChange(of: scrollViewModel.isLeadingValue) { isLeading in
//                        if isLeading {
//                            todoViewModel.datesInMonth.insert(
//                                contentsOf: todoViewModel.getDatesOnNextMonth(
//                                    on: .prev,
//                                    after: todoViewModel.datesInMonth.first!
//                                )
//                                ,at: 0)
//                        }
//                    }
//                    .onChange(of: scrollViewModel.isTrailingValue) { isTrailing in
//                        if isTrailing {
//                            let anchorDate: Date = todoViewModel.datesInMonth.last!
//                            todoViewModel.datesInMonth.append(
//                                contentsOf: todoViewModel.getDatesOnNextMonth(
//                                    on: .next,
//                                    after: todoViewModel.datesInMonth.last!
//                                ))
//                            todoViewModel.scrollTargetDate = todoViewModel.searchDate
//                        }
//                    }
                }
                .onChange(of: todoViewModel.scrollTargetDate) { newTarget in
                    print("바뀐 스크롤 타겟: ", newTarget)
                    todoViewModel.scrollTargetDate = Calendar.current.startOfDay(for: todoViewModel.scrollTargetDate)
                    // 더 좋은 방법 없을까..?
                    withAnimation {
                        proxy.scrollTo(newTarget, anchor: .center)
                    }
                }
            } //ScrollView
            .introspectScrollView(customize: { customScrollView in
                customScrollView.delegate = scrollViewModel
            })
            .frame(maxWidth: 1000, minHeight: 60, maxHeight: 70) // 화면 크기에 맞게 수정 필요
        } // ScrollViewReader
    }
}
