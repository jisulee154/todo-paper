//
//  StickerItem.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/03.
//
import Foundation
import SwiftUI

struct StickerItem: Identifiable {
    var uuid = UUID()
    var id: UUID {
        return uuid
    }
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
    case st2 = "heart.fill"
    case st3 = "bolt.heart.fill"
    case st4 = "moon.haze.fill"
    case st5 = "sparkles"
    case st6 = "star.fill"
    case st7 = "moon.stars.fill"
    case st8 = "sun.min.fill"
    case st9 = "flame.fill"
    case st10 = "bolt.fill"
    case st11 = "bird.fill"
    case st12 = "pawprint.fill"
    case st13 = "leaf.fill"
    case st14 = "camera.macro"
    case st15 = "teddybear.fill"
    case st16 = "atom"
    case st17 = "hand.thumbsup"
    case st18 = "graduationcap.fill"
    case st19 = "medal"
    case st20 = "checkmark.seal.fill"
}
