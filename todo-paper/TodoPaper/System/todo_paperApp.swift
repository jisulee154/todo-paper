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
    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var detailTodoViewModel: DetailTodoViewModel = DetailTodoViewModel()
    @StateObject var stickerViewModel: StickerViewModel = StickerViewModel()
    
    /// BottomSheet 관련
    @State var newTodo: TodoItem = TodoItem(title: "")
    
    /// 키보드 포커싱
    @State private var focusedNewTitleField: Bool = false
    @State var newTitle: String = ""
    
    @State private var focusedEditingField: Bool = false
    @State var editingTitle: String = "" // 투두 수정하기 텍스트필드 입력값

    var body: some Scene {
        WindowGroup {
            ZStack {
                TabView {
                    /// 일별 투두 관리
                    DailyTodoView(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, stickerViewModel: stickerViewModel, settingViewModel: settingViewModel)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .tabItem {
                            Label("투두 페이퍼", systemImage: "square.and.pencil")
                        }
                    /// 완료한 투두 페이지 모아보기
                    CompleteRepoView(settingViewModel: settingViewModel)
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .tabItem {
                            Label("페이퍼 모아보기", systemImage: "crown.fill")
                        }
                }
                .zIndex(0)
                
                /// 투두 만들기 바텀 시트
                makeAddTodoBottomSheet()
                    .zIndex(1)
                
                /// 투두 상세 설정 바텀 시트
                switch (detailTodoViewModel.timePosition) {
                case .past:
                    makePastDetailSettingBottomSheet()
                        .zIndex(2)
                case .today:
                    makeTodayDetailSettingBottomSheet()
                        .zIndex(3)
                case .future:
                    makeFutureDetailSettingBottomSheet()
                        .zIndex(4)
                case .none:
                    Text("Time Position Error.")
                        .zIndex(5)
                }
                
                /// - 투두 일자 수정 바텀 시트
                makeDatePickerBottomSheet()
                    .zIndex(6)
                
                /// - 투두 제목 수정 바텀 시트
                makeTitleEditBottomSheet()
                    .zIndex(7)
                
                /// - 완료 스티커 바텀 시트
                makeStickerBottomSheet()
                    .zIndex(8)
                
                /// - 앱 환경설정 바텀 시트
                makeAppSettings()
                    .zIndex(9)
            }
//            /// 앱 전체 Background 색깔
//            .background(Color.white)
        }
    }
    
    //MARK: - 투두 만들기 바텀 시트
    private func makeAddTodoBottomSheet() -> some View {
        Color.clear
            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.addTodoBottomSheetPosition,
                         switchablePositions:[.dynamicBottom,.relative(0.7)],
                         headerContent: {
                Text("새로운 투두")
                    .font(.title)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                
            }) {
                VStack {
                    UITextFieldRepresentable(
                        text: $newTitle,
                        placeholder: "새로운 투두를 입력해주세요.",
                        isFirstResponder: true,
                        isFocused: $focusedNewTitleField
                    )
                        .padding()
                        .frame(minWidth: 300, maxWidth: 2000, maxHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                        .onSubmit {
                            newTodo.uuid = UUID()
                            newTodo.duedate = todoViewModel.searchDate
                            newTodo.status = TodoStatus.none
                            newTodo.completeDate = nil
                            
                            if newTitle != "" {
                                newTodo.title = newTitle
                                todoViewModel.todos = todoViewModel.addATodo(
                                    TodoItem(uuid: newTodo.uuid,
                                             title: newTodo.title,
                                             duedate: newTodo.duedate,
                                             status: newTodo.status,
                                             completeDate: newTodo.completeDate),
                                    enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                                )
                            }
                            
                            newTitle = "" // 초기화
                            
                            detailTodoViewModel.addTodoBottomSheetPosition = .hidden
                            focusedNewTitleField = false
                        }
                        .padding(.bottom, 30)
                    Button {
                        newTodo.uuid = UUID()
                        newTodo.duedate = todoViewModel.searchDate
                        newTodo.status = TodoStatus.none
                        newTodo.completeDate = nil
                        
                        if newTitle != "" {
                            newTodo.title = newTitle
                            todoViewModel.todos = todoViewModel.addATodo(
                                TodoItem(uuid: newTodo.uuid,
                                         title: newTodo.title,
                                         duedate: newTodo.duedate,
                                         status: newTodo.status,
                                         completeDate: newTodo.completeDate),
                                enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                            )
                        }
                        
                        newTitle = "" // 초기화
                        
                        detailTodoViewModel.addTodoBottomSheetPosition = .hidden
                        
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                    } label: {
                        Text("완료")
                            .frame(minWidth: 200, maxWidth: 2000, maxHeight: 50)
                            .contentShape(Capsule())
                    }
                    .buttonStyle(SettingButtonStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
            }
            .customBackground(
                LinearGradient(gradient: Gradient(colors: [.themeColor10, .themeColor20]), startPoint: .bottomLeading, endPoint: .topTrailing)
                    .foregroundColor(.themeColor40)
            )
            .customBackground(
                LinearGradient(gradient: Gradient(colors: [.themeColor10, .themeColor20]), startPoint: .bottomLeading, endPoint: .topTrailing)
                    .foregroundColor(.themeColor40)
            )
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
    
    //MARK: - 투두 상세 설정 바텀 시트
    private func makePastDetailSettingBottomSheet() -> some View {
        DetailSheetOfPast(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, settingViewModel: settingViewModel)
    }
    
    private func makeTodayDetailSettingBottomSheet() -> some View {
        DetailSheetOfToday(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, settingViewModel: settingViewModel)
    }
    
    private func makeFutureDetailSettingBottomSheet() -> some View {
        DetailSheetOfFuture(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, settingViewModel: settingViewModel)
    }
    
    //MARK: - 투두 일자 변경 바텀 시트
    private func makeDatePickerBottomSheet() -> some View {
        Color.clear
            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.datePickerBottomSheetPosition,
                         switchablePositions:[.dynamicBottom,.relative(0.7)])
        {
            DatePicker(
                "date picker",
                selection: $detailTodoViewModel.updatingDate,
                in: Date()...,
                displayedComponents: [.date]
            )
            .frame(width: 320, alignment: .center)
            .datePickerStyle(.graphical)
            .background(Color.clear)
            
            Button {
                let updatingDate = Calendar.current.startOfDay(for: detailTodoViewModel.updatingDate)
                let today = Calendar.current.startOfDay(for: Date())
                
                todoViewModel.todos = todoViewModel.updateATodo(
                    updatingTodo: detailTodoViewModel.pickedTodo,
                    title: nil,
                    status: nil,
                    duedate: updatingDate,
                    completeDate: nil,
                    enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                )
                //                    todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                detailTodoViewModel.datePickerBottomSheetPosition = .hidden
                
                
                // 날짜 변경 토스트 메시지 띄우기
                detailTodoViewModel.showAnotherDayToast.toggle()
                
                todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker(enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask)
                
            } label: {
                Text("설정 완료")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        }
        .customBackground(
            LinearGradient(gradient: Gradient(colors: [.themeColor10, .themeColor20]), startPoint: .bottomLeading, endPoint: .topTrailing)
                .foregroundColor(.themeColor40)
        )
        .showCloseButton()
        .enableSwipeToDismiss()
        .enableTapToDismiss()
    }
    
    //MARK: - 투두 제목 수정 바텀 시트
    private func makeTitleEditBottomSheet() -> some View {
        Color.clear
            .bottomSheet(
                bottomSheetPosition: $detailTodoViewModel.editBottomSheetPosition,
                switchablePositions: [
                    .dynamicBottom,
                    .relative(0.6)],
                headerContent: {
                    Text("수정")
                        .font(.title)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                }) {
                    VStack {
                        UITextFieldRepresentable(
                            text: $editingTitle,
                            placeholder: "텍스트를 입력해주세요.",
                            isFirstResponder: true,
                            isFocused: $focusedEditingField
                        )
                            .padding()
                            .frame(minWidth: 300, maxWidth: 1000, maxHeight: 50)
                            .background(.white)
                            .cornerRadius(10)
                            .autocorrectionDisabled()
                            .onAppear {
                                editingTitle = detailTodoViewModel.pickedTodo.title
                            }
                            .onSubmit {
                                detailTodoViewModel.editBottomSheetPosition = .hidden
                                todoViewModel.todos = todoViewModel.updateATodo(
                                    updatingTodo: detailTodoViewModel.pickedTodo,
                                    title: editingTitle,
                                    status: nil,
                                    duedate: nil,
                                    completeDate: nil,
                                    enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                                )
                                //                            print("onSubmit: ", detailTodoViewModel.editingTitle)
                            }
                            .padding(.bottom, 30)
                        
                        Button {
                            detailTodoViewModel.editBottomSheetPosition = .hidden
                            todoViewModel.todos = todoViewModel.updateATodo(
                                updatingTodo: detailTodoViewModel.pickedTodo,
                                title: editingTitle,
                                status: nil,
                                duedate: nil,
                                completeDate: nil,
                                enableHideGaveUpTask: settingViewModel.enableHideGaveUpTask
                            )
                            
                            //                        print("수정완료 버튼 클릭: ", detailTodoViewModel.editingTitle)
                        } label: {
                            Text("완료")
                                .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                                .contentShape(Capsule())
                        }
                        .buttonStyle(SettingButtonStyle())
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                }
                .customBackground(
                    LinearGradient(gradient: Gradient(colors: [.themeColor10, .themeColor20]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        .foregroundColor(.themeColor40)
                )
                .showCloseButton()
                .enableSwipeToDismiss()
                .enableTapToDismiss()
        
    }
    
    //MARK: - 스티커 선택 바텀 시트
    private func makeStickerBottomSheet() -> some View {
        StickerBottomSheet(todoViewModel: todoViewModel,
                           detailTodoViewModel: detailTodoViewModel,
                           stickerViewModel: stickerViewModel)
    }
    
    //MARK: - 전체 설정 바텀 시트
    private func makeAppSettings() -> some View {
        SettingBottomSheet(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, settingViewModel: settingViewModel)
    }
}

