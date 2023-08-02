//
//  SettingViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/02.
//
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var isTodoNotificationOn: Bool = false
    @Published var isStickerNotificationOn: Bool = false
    @Published var isUnfinishedTaskPostponeOn: Bool = false
    @Published var isHideGaveUpTaskOn: Bool = false
    
    init(isTodoNotificationOn: Bool = false,
         isStickerNotificationOn: Bool = false,
         isUnfinishedTaskPostponeOn: Bool = false,
         isHideGaveUpTaskOn: Bool = false) {
        self.isTodoNotificationOn = isTodoNotificationOn
        self.isStickerNotificationOn = isStickerNotificationOn
        self.isUnfinishedTaskPostponeOn = isUnfinishedTaskPostponeOn
        self.isHideGaveUpTaskOn = isHideGaveUpTaskOn
    }
}

