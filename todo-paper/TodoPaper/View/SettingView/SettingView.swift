//
//  SettingView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/02.
//

import SwiftUI
import UserNotifications
import MessageUI

struct SettingView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var settingViewModel: SettingViewModel
    
    @State var showTipTodoNotification: Bool = false
    @State var showTipStickerNotification: Bool = false
    
//    @State var enableHideGaveUpTask: Bool = UserDefaults.standard.bool(forKey: "enableHideGaveUpTask")
    

    var body: some View {
        ZStack {
            // 상단 뒤로가기 버튼
            makeGoBackButton()
                .zIndex(1)
            
            // 설정 항목 목록
            makeSettingList()
                .zIndex(0)
        }
    }
    
    private func makeGoBackButton() -> some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    todoViewModel.showSettingView.toggle()
                    
                    todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                    if settingViewModel.enableHideGaveUpTask {
                        // 포기한 일 숨기기 true일 때
                        todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
                    }
                    todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                    if settingViewModel.enableHideGaveUpTask {
                        // 포기한 일 숨기기 true일 때
                        todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
                    }
                    
                    
                    UserDefaults.standard.set(settingViewModel.enableHideGaveUpTask, forKey: "enableHideGaveUpTask")
//                    UserDefaults.standard.set(settingViewModel.enableHideGaveUpTask, forKey: "enableHideGaveUpTask")
                    print("userDefaults 저장된 값: ", UserDefaults.standard.bool(forKey: "enableHideGaveUpTask"))
                } label: {
                    Text("뒤로가기")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            Spacer()
        }
    }
    
    private func makeSettingList() -> some View {
        NavigationView {
            Form {
//                Section("알림 설정") {
//                    // 당일 할일 알림 받기
//                    VStack {
//                        HStack {
//                            Toggle(isOn: $settingViewModel.enableTodoNotification) {
//                                Text("투두 알림 받기")
//                            }.padding(.trailing, 10)
//                            // 도움말
//                            Button {
//                                showTipTodoNotification = true
//                            } label: { Image(systemName: "questionmark.circle.fill") }
//                            .foregroundColor(.gray)
////                            .help("하루에 한번 그날의 투두를 알려드려요.")
//                            .opacity(0.5)
//                            .alert("하루에 한번 그날의 투두를 알려드려요.", isPresented: $showTipTodoNotification) {
//                                Button("확인", role: .cancel) { }
//                            }
//                        }
//                        DatePicker("시간", selection: $settingViewModel.timeToTodoNotification, displayedComponents: [.hourAndMinute])
//                            .disabled(!settingViewModel.enableTodoNotification)
//                    }
                    
//                    // 완료 스티커 붙이기 알림
//                    VStack {
//                        HStack {
//                            Toggle(isOn: $settingViewModel.enableStickerNotification) {
//                                Text("완료 스티커 알림 받기")
//                            }.padding(.trailing, 10)
//                            // 도움말
//                            Button {
//                                showTipStickerNotification = true
//                            } label: { Image(systemName: "questionmark.circle.fill") }
////                            .foregroundColor(.gray)
////                            .help("스티커를 붙이는 걸 안까먹게 도와드려요.")
//                            .opacity(0.5)
//                            .alert("스티커를 붙이는 걸 안 잊게 도와드려요.", isPresented: $showTipStickerNotification) {
//                                Button("확인", role: .cancel) { }
//                            }
//                        }
//                        DatePicker("시간", selection: $settingViewModel.timeToStickerNotification, displayedComponents: [.hourAndMinute])
//                            .disabled(!settingViewModel.enableStickerNotification)
//                    }
//                }
                
                Section("투두 설정") {
                    // 포기한 일 숨기기
                    Toggle(isOn: $settingViewModel.enableHideGaveUpTask) {
                        Text("포기한 투두 숨기기")
                    }
                }
                
                Section("기타") {
                    // 리뷰
                    Button {
                        //나중에 추가
                        //action
                        //requestReviewmenually(id: <#T##String#>)
                    } label: {
                        Text("투두 페이퍼 리뷰하기")
                    }
                    
                    // 문의
                    Button {
                        makeSendMail()
                    } label: {
                        Text("버그 신고 및 문의하기")
                    }


                }
            }.navigationTitle("설정")
        }
    }
    
    func requestReviewmenually(id: String) { //app store connect의 앱정보에서 apple id를 확인한다
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(id)?action=write-review")
        else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    
    
    
}
