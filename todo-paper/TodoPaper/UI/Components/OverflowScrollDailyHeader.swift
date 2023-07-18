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
            ScrollViewReader { proxy in
                LazyHStack {
                    ForEach(vm.array, id: \.self) { date in
                        OverflowScrollDailyCell(date: date).onAppear {
                            vm.loadMoreDatesIfNeeded(for: date)
                        }
                    }
                    .flipsForRightToLeftLayoutDirection(true)
                    .environment(\.layoutDirection, .leftToRight)
                }
            }
            .flipsForRightToLeftLayoutDirection(true)
            .environment(\.layoutDirection, .leftToRight)
        }
    }
    
    
}

struct OverflowScrollDailyHeader_Previews: PreviewProvider {
    static var previews: some View {
        OverflowScrollDailyHeader()
    }
}
