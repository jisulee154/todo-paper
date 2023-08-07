//
//  StickerCell.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/03.
//

import SwiftUI

struct StickerCell: View {
    @ObservedObject var stickerViewModel: StickerViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    private var stickerName: String
    private var stickerBgColor: Color
    private var isExist: Bool
    private var date: Date
//    private var stickerCase: StickerCase
    
    init(detailTodoViewModel: DetailTodoViewModel,
         stickerViewModel: StickerViewModel,
         stickerName: String,
         stickerBgColor: Color = Color.white,
         date: Date,
         isExist: Bool = false) {
        
        self.detailTodoViewModel = detailTodoViewModel
        self.stickerViewModel = stickerViewModel
        self.stickerName = stickerName
        self.stickerBgColor = stickerBgColor
        self.date = date
        self.isExist = isExist
    }
    
    var body: some View {
        Button {
            detailTodoViewModel.setStickerBottomSheetPosition = .hidden
            
            
            // CoreData
            // 스티커 add
            if stickerViewModel.getTodayStickerOn(date: date) {
                let targetStickerItem = stickerViewModel.fetchSticker(on: date)!
                stickerViewModel.sticker = stickerViewModel.fetchSticker(on: date)
                stickerViewModel.sticker = stickerViewModel.updateASticker(
                    updatingSticker: targetStickerItem, date: date, isExist: true, stickerName: stickerName, stickerBgColor: stickerBgColor.description)
                
            } else {
                if let targetStickerItem = stickerViewModel.fetchSticker(on: date) {
                    stickerViewModel.sticker = stickerViewModel.updateASticker(
                        updatingSticker: targetStickerItem, date: date, isExist: true, stickerName: stickerName, stickerBgColor: stickerBgColor.description)
                } else {
                    stickerViewModel.sticker
                    = stickerViewModel.addSticker(StickerItem(uuid: UUID(),
                                                              date: date,
                                                              isExist: true,
                                                              stickerName: stickerName,
                                                              stickerBgColor: stickerBgColor.description))
                }
            }
            
            stickerViewModel.isTodayStickerOn = stickerViewModel.getTodayStickerOn(date: date)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.themeColor40)
                    .frame(width: 50, height: 50)
                    .zIndex(0)
                Image(systemName: stickerName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .zIndex(1)
                
            }
            .padding(.vertical, 20)
        }
        .buttonStyle(SelectStickerStyle())
        
    }
}
