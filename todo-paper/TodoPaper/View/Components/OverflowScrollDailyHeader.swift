//
//  FlowDateButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI

struct OverflowScrollDailyHeader: View {
    @StateObject var vm = CalendarViewModel()
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(vm.array, id: \.self) { date in
                    OverflowScrollDailyCell(date: date)
                        .onAppear {
                            vm.loadMoreDates()
                        }
                }
                .flipsForRightToLeftLayoutDirection(true)
                .environment(\.layoutDirection, .leftToRight)
            }
        }
        .flipsForRightToLeftLayoutDirection(true)
        .environment(\.layoutDirection, .leftToRight)
        .frame(width: .infinity, height: 80) // 화면 크기에 맞게 수정 필요
    }
}

struct OverflowScrollDailyHeader_Previews: PreviewProvider {
    static var previews: some View {
        OverflowScrollDailyHeader()
    }
}
