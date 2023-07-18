//
//  OverflowScrollDailyCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/18.
//

import Foundation
import SwiftUI

struct OverflowScrollDailyCell: View {
    
    var date: Date
    
    var title: String {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        return df.string(from: date)
    }
    
    var subtitle: String {
        let df = DateFormatter()
        df.dateFormat = "M/d"
        return df.string(from: date)
    }
    
    var body: some View {
        Button {
            //pass
        } label: {
            VStack(alignment: .center) {
                Text(title)
                Text(subtitle)
            }
            .padding(EdgeInsets(top: 10, leading: 7, bottom: 10, trailing: 7))
            .foregroundColor(Color.themeColor40)
            .background(Color.white)
//            .cornerRadius(15)
//            .border(Color.themeColor40, width: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.themeColor40, lineWidth: 1)
            )
            
        }

//        VStack(alignment: .center) {
//            Text(title)
//            Text(subtitle)
//        }
//        .padding(EdgeInsets(top: 5, leading: 2, bottom: 5, trailing: 2))
    }
}
