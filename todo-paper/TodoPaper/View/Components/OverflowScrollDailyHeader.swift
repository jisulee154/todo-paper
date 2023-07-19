//
//  FlowDateButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI

struct OverflowScrollDailyHeader: View {
    @StateObject var vm = CalendarViewModel()
    
    @Binding var selectedDate: Date
    @Binding var refreshTodoList: Bool
//    @State var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    selectedDate = Calendar.current.startOfDay(for: Date())
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
                Spacer()
            } //HStack
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(vm.array, id: \.self) { date in
                            OverflowScrollDailyCell(selectedDate: $selectedDate, refreshTodoList: $refreshTodoList, date: date)
                                .id(date)
                                .onChange(of: selectedDate) { newIndex in
                                    withAnimation (Animation.easeInOut(duration: 100).delay(1)) {
                                        proxy.scrollTo(newIndex, anchor: .center)
                                    }
                                }
                        }
                    }
                } //ScrollView
                .onAppear{
                    vm.loadMoreDates()
                }
            }
            //            .flipsForRightToLeftLayoutDirection(true)
            //            .environment(\.layoutDirection, .leftToRight)
            .frame(width: 400, height: 100) // 화면 크기에 맞게 수정 필요
            
        }
    }
}
