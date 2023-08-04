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
//    @ObservedObject var todoViewModel: TodoViewModel
    
    var body: some View {
        HPageView(alignment: .leading, spacing: 20) {
            ForEach(completeRepoViewModel.completePages) { view in
                view
            }
        }
        .onAppear {
            let allDates = completeRepoViewModel.fetchAllDates()
            completeRepoViewModel.allDates = allDates
            let completeDates = completeRepoViewModel.getCompleteDates(allDates: allDates)
            completeRepoViewModel.completeDates = completeDates
            let completePages =  completeRepoViewModel.getCompletePages()
            completeRepoViewModel.completePages = completePages
        }
    }
}

class pageTestStuct {
    
}
