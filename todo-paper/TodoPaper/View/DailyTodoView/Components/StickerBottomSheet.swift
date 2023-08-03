//
//  StickerBottomSheet.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/03.
//

import SwiftUI

/// 스티커 선택 바텀 시트
struct StickerBottomSheet: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    @ObservedObject var stickerViewModel: StickerViewModel
    
    var body: some View {
        Color.clear
            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.setStickerBottomSheetPosition, switchablePositions: [.dynamicBottom, .relative(0.7)], headerContent: {
                Text("완료 스티커 ✅")
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
            }) {
                VStack {
                    HStack {
                        Text("투두를 모두 마무리 했어요!\n완료 스티커를 붙여 볼까요? 😄")
                        Spacer()
                        
                    }
                    
                    Divider()
                    HStack {
                        Spacer()
                        ColorPicker("배경 색상", selection: $stickerViewModel.stickerBgColor)
                            .padding(.top, 30)
                    }
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(stickerViewModel.stickerCases, id: \.self) { stickerCase in
                                // 선택할 수 있는 스티커들 목록 (횡스크롤)
                                StickerCell(detailTodoViewModel: detailTodoViewModel,
                                            stickerViewModel: stickerViewModel,
                                            stickerName: stickerCase.rawValue,
                                            date: todoViewModel.searchDate)
                            }
                        }
                    }
                    Divider()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
            .onAppear {
                stickerViewModel.stickerCases = stickerViewModel.getStickerCases()
            }
    }
}
