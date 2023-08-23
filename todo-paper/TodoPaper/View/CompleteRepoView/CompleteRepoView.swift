//
//  CompleteRepoView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/04.
//
import SwiftUIPageView
import SwiftUI

struct CompleteRepoView: View {
    //MARK: - Shared Data
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var completeRepoViewModel = CompleteRepoViewModel()
    @ObservedObject var stickerViewModel: StickerViewModel = StickerViewModel()
    @ObservedObject var settingViewModel: SettingViewModel
//    @ObservedObject var todoViewModel: TodoViewModel
    
    init(settingViewModel: SettingViewModel) {
        self.settingViewModel = settingViewModel
    }
    
    var body: some View {
        VStack {
            if completeRepoViewModel.completePages.count > 0 {
                HPageView(alignment: .leading, spacing: 20) {
                    ForEach(completeRepoViewModel.completePages) { view in
                        view
                    }
                }
            } else {
                makeBlank()
            }
            
        }
        .onAppear {
            let allDates = completeRepoViewModel.fetchAllDates()
            completeRepoViewModel.allDates = allDates
            let completeDates = completeRepoViewModel.getCompleteDates(allDates: allDates)
            completeRepoViewModel.completeDates = completeDates
//            print(completeDates)
            let completePages =  completeRepoViewModel.getCompletePages(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
            completeRepoViewModel.completePages = completePages
        }
    }
    
    private func makeBlank() -> some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("""
                   아직 완료한 페이퍼가 없어요.\n
                   투두를 마무리한 날의 페이퍼가\n
                   이곳에 쌓여요. 📎
                   """).frame(alignment: .center)
                Spacer()
            }
            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
        )
        .padding(.all, 10)
    }
}

class pageTestStuct {
    
}
