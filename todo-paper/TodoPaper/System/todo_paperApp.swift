//
//  todo_paperApp.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI

@main
struct todo_paperApp: App {
    let persistenceController = PersistenceController.shared
    
    
    @StateObject var settingViewModel: SettingViewModel = SettingViewModel(enableHideGaveUpTask: UserDefaults.standard.bool(forKey: "settingViewModel"))
//    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                /// 일별 투두 관리
                DailyTodoView(settingViewModel: settingViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("투두", systemImage: "square.and.pencil")
                    }
                /// 완료한 투두 페이지 모아보기
                CompleteRepoView(settingViewModel: settingViewModel)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("페이퍼 모아보기", systemImage: "crown.fill")
                    }

            }
        }
    }
}
