//
//  DetailSheetOfToday.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/31.
//

import Foundation
import SwiftUI
import BottomSheetSwiftUI

//MARK: - 상세 설정 시트 (오늘)
struct DetailSheetOfToday: View {
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
                    Button {
                        detailTodoViewModel.isEditBottomSheetShowing.toggle()
                    } label: {
                        Text("수정하기")
                            .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    
                    Button {
                        detailTodoViewModel.isDetailSheetShowing.toggle() // 기존 상세설정 bottom sheet가 밑으로 내려감.
                        detailTodoViewModel.isDatePickerShowing.toggle() // Date Picker bottom sheet가 위로 올라옴.
                    } label: {
                        Text("다른날 하기")
                            .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                    //                .alert("날짜 변경", isPresented: $detailTodoViewModel.isDatePickerShowing) {
                    //                    Button("확인") {
                    //                        detailTodoViewModel.isDetailSheetShowing.toggle()
                    //                        print("투두의 날짜가 변경되었습니다.") //토스트 메시지!!!
                    //                    }
                    //                    Button("취소", role: .cancel) { }
                    //                } message: {
                    //
                    //                }
                    
                    Button {
                        //action
                    } label: {
                        Text("내일 하기")
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

