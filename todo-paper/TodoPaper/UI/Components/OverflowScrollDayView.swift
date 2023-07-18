//
//  FlowDateButton.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import SwiftUI

struct OverflowScrollDayView: View {
    var body: some View {
        HStack {
            ForEach (1..<30) {
                Text("Item \($0)")
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                    .foregroundColor(Color.white)
                    .background(Color.themeColor40)
                    .cornerRadius(15)
                Spacer()
                
            }
        } //HStack

    }
}

struct OverflowScrollDayView_Previews: PreviewProvider {
    static var previews: some View {
        OverflowScrollDayView()
    }
}
