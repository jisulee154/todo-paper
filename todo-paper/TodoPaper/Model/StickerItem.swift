//
//  StickerItem.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/03.
//
import Foundation
import SwiftUI

struct StickerItem: Identifiable {
    var id: UUID {
        return uuid
    }
    var uuid = UUID()
    var date: Date = Date()
    var isExist: Bool = false
    var stickerName: String? = nil
    var stickerBgColor: String? = nil
    
    init(uuid: UUID = UUID(),
         date: Date = Date(),
         isExist: Bool = false,
         stickerName: String? = nil,
         stickerBgColor: String? = nil) {
        
        self.uuid = uuid
        self.date = date
        self.isExist = isExist
        self.stickerName = stickerName
        self.stickerBgColor = stickerBgColor
    }
}

enum StickerCase: String, CaseIterable {
    case st1 = "hands.clap"
    case st2 = "globe.asia.australia"
    case st3 = "moonphase.waxing.crescent"
    case st4 = "star"
    case st5 = "star.leadinghalf.filled"
    case st6 = "star.fill"
    case st7 = "moon.stars.circle"
    case st8 = "sun.min.fill"
    case st9 = "figure.run"
    case st10 = "dollarsign.circle"
    case st11 = "house"
    case st12 = "music.note"
    case st13 = "figure.dance"
    case st14 = "teddybear"
    case st15 = "teddybear.fill"
    case st16 = "atom"
    case st17 = "hand.thumbsup"
    case st18 = "hand.thumbsdown"
    case st19 = "medal"
    case st20 = "checkmark.seal.fill"
}
