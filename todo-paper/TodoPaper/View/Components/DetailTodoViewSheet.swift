//
//  DetailTodoViewSheet.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/27.
//

import Foundation
import SwiftUI

struct DetailTodoViewSheet<Content: View>: View {
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    var maxHeight: CGFloat
    
    var offset: CGFloat {
        detailTodoViewModel.isDetailSheetShowing ? 0 : self.maxHeight
    }
    
    let content: Content
    
    init(detailTodoViewModel: DetailTodoViewModel,
         maxHeight: CGFloat,
         @ViewBuilder content: () -> Content) {
        self.detailTodoViewModel = detailTodoViewModel
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    var body: some View {
//        GeometryReader { proxy in
//            VStack() {
//                self.content
//            }
//            .offset(y: self.offset)
//            .frame(width: UIScreen.main.bounds.size.width ,height: 200, alignment: .bottom)
//            .cornerRadius(30)
//            .animation(.default, value: detailTodoViewModel.isDetailSheetShowing)
//        }
        GeometryReader { geometry in
            VStack() {
                withAnimation {
                    self.content
                }
            }
            .frame(width: geometry.size.width,
                   height: self.maxHeight)
            .background(Color.themeColor10)
            .cornerRadius(35)
            .overlay {
                RoundedRectangle(cornerRadius: 35)
                    .stroke(Color.themeColor40, lineWidth: 1)
            }
            //정녕 이 방법밖에 없는 걸까...?
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: self.offset)
            .animation(.easeOut, value: detailTodoViewModel.isDetailSheetShowing)
        }
    }
}

