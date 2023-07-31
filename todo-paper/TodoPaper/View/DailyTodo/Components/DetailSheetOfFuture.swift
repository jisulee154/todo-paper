//
//  DetailSheetOfFuture.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import Foundation
import SwiftUI
import BottomSheetSwiftUI

//MARK: - 상세 설정 시트 (미래)
struct DetailSheetOfFuture: View {
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(_ detailTodoViewModel: DetailTodoViewModel) {
        self.detailTodoViewModel = detailTodoViewModel
    }
    
    var body: some View {
        Color.clear
            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.bottomSheetPosition,
                         switchablePositions:[.dynamicBottom,.relative(0.6)],
                         headerContent: {
                Text("상세 설정")
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
            }) {
                VStack (spacing: 10) {
                    HStack (spacing: 10) {
                        Button {
                            detailTodoViewModel.isEditBottomSheetShowing.toggle()
                        } label: {
                            Text("수정하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                        
                        Button {
                            detailTodoViewModel.isDetailSheetShowing.toggle()
                            detailTodoViewModel.isDatePickerShowing.toggle()
                        } label: {
                            Text("다른날 하기")
                                .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                    }
                    
                    Button {
                        //action
                    } label: {
                        Text("오늘 하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        //action
                    } label: {
                        Text("포기하기")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        //action
                    } label: {
                        Text("삭제")
                            .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(DeleteButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
}

