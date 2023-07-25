//
//  DateHeader.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI

struct DateHeader: View {
    //    @StateObject var vm = CalendarViewModel()
    //
    //    @Binding var fetchModel: FetchModel
    ////    @Binding var newDate: Date
    //
    //    var onNewDateClicked: (Date) -> Void
    @ObservedObject var todoViewModel: TodoViewModel
    
    var body: some View {
        VStack {
            //MARK: - 환경 설정 & 오늘로 이동 버튼
            HStack {
                // 오늘로 이동 버튼
                Button {
                    todoViewModel.searchDate = todoViewModel.setSearchDate(date: Date())
                    todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: Date())
                    todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                } label: {
                    Text("오늘")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 5)
                        .foregroundColor(Color.white)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color.themeColor40)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                Spacer()
                // 앱 환경 설정 버튼
                Button {
                    // action
                } label: {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.themeColor40)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                
            } //HStack
            //MARK: - Calendar Scroll
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(todoViewModel.datesInMonth, id:\.self) { date in
                            DateCell(todoViewModel: todoViewModel, date: date)
                                .id(date)
                        }
                        .onChange(of: todoViewModel.scrollTargetDate) { newTarget in
                            withAnimation {
                                proxy.scrollTo(newTarget, anchor: .center)
                            }
                        }
                        .onAppear {
                            withAnimation {
                                proxy.scrollTo(todoViewModel.scrollTargetDate, anchor: .center)
                            }
                        }
                    }
                } //ScrollView
                .onAppear{
                    todoViewModel.datesInMonth = todoViewModel.getDatesInThisMonth()
                }
                //            .flipsForRightToLeftLayoutDirection(true)
                //            .environment(\.layoutDirection, .leftToRight)
                .frame(width: 400, height: 70) // 화면 크기에 맞게 수정 필요
            } // ScrollViewReader
        }
    }
}
