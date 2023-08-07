//
//  DailyTodoView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI
import CoreData
import Combine
import BottomSheetSwiftUI
import AlertToast


/// 일별 투두 보기 탭
struct DailyTodoView: View {
    
    //MARK: - Shared Data
    @Environment(\.managedObjectContext) private var viewContext
    
//    @ObservedObject var todoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var detailTodoViewModel: DetailTodoViewModel = DetailTodoViewModel()
    @StateObject var stickerViewModel: StickerViewModel = StickerViewModel()
    @ObservedObject var settingViewModel: SettingViewModel
    
    /// BottomSheet 관련
    @State var newTodo: TodoItem = TodoItem(title: "")
    @State var newTitle: String = ""
    
    init(settingViewModel: SettingViewModel) {
        self.settingViewModel = settingViewModel
    }
    
    //MARK: - View
    var body: some View {
        ZStack {
            /// 날짜 선택 스크롤과 투두 리스트 목록, 앱 설정
            makeTodoList()
                .zIndex(0)
            
            /// 투두 생성, 스티커 생성 버튼
            makeAddButtonAndSticker()
                .zIndex(1)
            
            /// 투두 만들기 바텀 시트
            makeAddTodoBottomSheet()
                .zIndex(3)
            
            /// 투두 상세 설정 바텀 시트
            switch (detailTodoViewModel.timePosition) {
            case .past:
                makePastDetailSettingBottomSheet()
                    .zIndex(4)
            case .today:
                makeTodayDetailSettingBottomSheet()
                    .zIndex(4)
            case .future:
                makeFutureDetailSettingBottomSheet()
                    .zIndex(4)
            case .none:
                Text("Time Position Error.")
                    .zIndex(4)
            }
            
            /// - 투두 일자 수정 바텀 시트
            makeDatePickerBottomSheet()
                .zIndex(5)
            
            /// - 투두 제목 수정 바텀 시트
            makeTitleEditBottomSheet()
                .zIndex(6)
            
            /// - 완료 스티커 바텀 시트
            makeStickerBottomSheet()
                .zIndex(7)
            
            
        }
        //MARK: - 토스트 메시지
        .toast(isPresenting: $detailTodoViewModel.showDeletedToast) {
            AlertToast(displayMode: .hud, type: .regular, title: "투두가 삭제되었어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showPostponedToast) {
            AlertToast(displayMode: .hud, type: .complete(.green), title: "내일도 같은 투두를 추가했어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showChangedAsTodayToast) {
            AlertToast(displayMode: .hud, type: .complete(.green), title: "오늘 목록으로 옮겼어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showAnotherDayToast) {
            AlertToast(displayMode: .hud, type: .complete(.green), title: "선택한 일자로 옮겼어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showUnfinishedTodosToast) {
            AlertToast(displayMode: .hud, type: .regular, title: "🥺 미완료인 투두가 있어\n완료 스티커를 붙일 수 없어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showCantPutStickerYet) {
            AlertToast(displayMode: .hud, type: .regular, title: "아직 완료 스티커를 붙일 수 없어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showCantPutStickerNone) {
            AlertToast(displayMode: .hud, type: .regular, title: "우선 투두부터 추가해볼까요?")
        }
        .toast(isPresenting: $detailTodoViewModel.showCantPutStickerNonePast) {
            AlertToast(displayMode: .hud, type: .regular, title: "😖 완료한 투두가 없어\n스티커를 붙일 수 없어요.")
        }
        .toast(isPresenting: $detailTodoViewModel.showStickerDeletedToast) {
            AlertToast(displayMode: .hud, type: .regular, title: "스티커가 떼어졌어요.")
        }
        .confirmationDialog("설정", isPresented: $todoViewModel.showEditAferCompleteAlert) {
            Button("스티커 떼기", role: .destructive) {
                detailTodoViewModel.showStickerDeletedToast.toggle()
                
                stickerViewModel.isTodayStickerOn = false
                
                stickerViewModel.sticker = stickerViewModel.fetchSticker(on: todoViewModel.searchDate)
                
                stickerViewModel.deleteASticker(deletingSticker: stickerViewModel.sticker!)
                stickerViewModel.sticker = nil
//                stickerViewModel.sticker = stickerViewModel.updateASticker(updatingSticker: stickerViewModel.sticker!, date: todoViewModel.searchDate, isExist: false, stickerName: nil, stickerBgColor: nil)
            }
            Button("취소", role: .cancel) {
                
            }
        } message: {
            Text("완료 스티커를 떼고 다시 설정하시겠어요?")
        }

    }
    
    //MARK: - 날짜 선택 스크롤과 투두 리스트 목록, 앱 설정
    private func makeTodoList() -> some View {
        VStack {
            ///캘린더 스크롤 부분 & 오늘로 이동 & 앱 설정
            Header(todoViewModel: todoViewModel, stickerViewModel: stickerViewModel, settingViewModel: settingViewModel)
            
            ZStack {
                /// - 완료 스티커 부착
                if stickerViewModel.isTodayStickerOn && (stickerViewModel.sticker?.isExist ?? false){
                    makeSticker()
                        .contentShape(Circle())
                        .zIndex(1)
                }
                
                if (todoViewModel.todos.count > 0) || (todoViewModel.oldTodos.count > 0) {
                    VStack {
                        ///투두 목록 부분
                        List {
                            if todoViewModel.todos.count > 0 {
                                Section("list") {
                                    VStack {
                                        ForEach(todoViewModel.todos) { todo in
                                            TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                                                       title: todo.title,
                                                                       duedate: todo.duedate,
                                                                       status: todo.status,
                                                                       completeDate: todo.completeDate),
                                                        todoViewModel: todoViewModel,
                                                        todoItemRowType: TodoItemRowType.today,
                                                        detailTodoViewModel: detailTodoViewModel,
                                                        stickerViewModel: stickerViewModel,
                                                        settingViewModel: settingViewModel)
                                            Divider()
                                            
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 2)
                                    )
                                }
                                .listRowInsets(EdgeInsets.init())
                            }
                            
                            // 보여지는 일자가 오늘인 경우 기한이 지난 투두를 old 섹션에 출력한다.
                            if todoViewModel.canShowOldTodos() {
                                if todoViewModel.oldTodos.count != 0 {
                                    Section("old") {
                                        VStack {
                                            ForEach(todoViewModel.oldTodos) { todo in
                                                TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                                                           title: todo.title,
                                                                           duedate: todo.duedate,
                                                                           status: todo.status,
                                                                           completeDate: todo.completeDate),
                                                            todoViewModel: todoViewModel,
                                                            todoItemRowType: TodoItemRowType.old,
                                                            detailTodoViewModel: detailTodoViewModel,
                                                            stickerViewModel: stickerViewModel,
                                                            settingViewModel: settingViewModel)
                                                
                                                Divider()
                                            }
                                        }
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 2)
                                        )
                                    }.listRowInsets(EdgeInsets.init())
                                }
                            }
                            Color.clear.frame(height:100)
                                .listRowBackground(Color.clear)
                        } // List
                    }
                } else {
                    // 해당 날짜의 투두가 없을 때
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("""
                               투두가 하나도 없어요.\n
                               하나 추가해 볼까요? 📝
                               """)
                            Spacer()
                        }
                        Spacer()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 15, style: .circular).stroke(Color.themeColor40, lineWidth: 1)
                    )
                    .padding(.all, 10)
                }
            }.zIndex(0)
        }
        // 할일 목록 새로고침
        .refreshable {
            todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
            if settingViewModel.enableHideGaveUpTask {
                // 포기한 일 숨기기 true일 때
                todoViewModel.todos = todoViewModel.eraseCanceledTodo(of: todoViewModel.todos)
            }
            
            if todoViewModel.canShowOldTodos() {
                todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
                if settingViewModel.enableHideGaveUpTask {
                    // 포기한 일 숨기기 true일 때
                    todoViewModel.oldTodos = todoViewModel.eraseCanceledTodo(of: todoViewModel.oldTodos)
                }
            }
        }
        .onAppear {
            todoViewModel.searchDate = todoViewModel.setSearchDate(date: Date())
//            todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: Date())
            
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
            
            todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
            
            // 스티커 체크
            stickerViewModel.isTodayStickerOn = stickerViewModel.getTodayStickerOn(date: todoViewModel.searchDate)
            
            if stickerViewModel.isTodayStickerOn {
                stickerViewModel.sticker = stickerViewModel.fetchSticker(on: todoViewModel.searchDate)
            }
            
            // Use this for inspecting the Core Data
            if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {             print("Documents Directory: \(directoryLocation)Application Support")
                
            }
        }
    }
    
    //MARK: - 투두 생성, 스티커 생성 버튼
    private func makeAddButtonAndSticker() -> some View {
        FloatingFooter(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, stickerViewModel: stickerViewModel, settingViewModel: settingViewModel)
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
                    TextField("새로운 투두를 입력해주세요.", text: $newTitle)
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
                                             completeDate: newTodo.completeDate)
                                )
                            }
                            
                            newTitle = "" // 초기화
                            
                            detailTodoViewModel.addTodoBottomSheetPosition = .hidden
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
                                         completeDate: newTodo.completeDate)
                            )
                        }
                        
                        newTitle = "" // 초기화
                        
                        detailTodoViewModel.addTodoBottomSheetPosition = .hidden
                        
                        todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
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
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
    
    //MARK: - 투두 상세 설정 바텀 시트
    private func makePastDetailSettingBottomSheet() -> some View {
        DetailSheetOfPast(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel)
    }
    
    private func makeTodayDetailSettingBottomSheet() -> some View {
        DetailSheetOfToday(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel, settingViewModel: settingViewModel)
    }
    
    private func makeFutureDetailSettingBottomSheet() -> some View {
        DetailSheetOfFuture(todoViewModel: todoViewModel, detailTodoViewModel: detailTodoViewModel)
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
                    completeDate: nil
                )
                //                    todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
                detailTodoViewModel.datePickerBottomSheetPosition = .hidden
                
                
                // 날짜 변경 토스트 메시지 띄우기
                detailTodoViewModel.showAnotherDayToast.toggle()
                
                todoViewModel.isActivePutSticker = todoViewModel.getActivePutSticker()
                
            } label: {
                Text("설정 완료")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        }
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
                        TextField("텍스트를 입력해주세요.", text: $detailTodoViewModel.editingTitle)
                            .padding()
                            .frame(minWidth: 300, maxWidth: 1000, maxHeight: 50)
                            .background(.white)
                            .cornerRadius(10)
                            .autocorrectionDisabled()
                            .onAppear {
                                detailTodoViewModel.editingTitle = detailTodoViewModel.pickedTodo.title
                            }
                            .onSubmit {
                                detailTodoViewModel.editBottomSheetPosition = .hidden
                                todoViewModel.todos = todoViewModel.updateATodo(
                                    updatingTodo: detailTodoViewModel.pickedTodo, title: detailTodoViewModel.editingTitle, status: nil, duedate: nil, completeDate: nil
                                )
                                //                            print("onSubmit: ", detailTodoViewModel.editingTitle)
                            }
                            .padding(.bottom, 30)
                        
                        Button {
                            detailTodoViewModel.editBottomSheetPosition = .hidden
                            todoViewModel.todos = todoViewModel.updateATodo(
                                updatingTodo: detailTodoViewModel.pickedTodo, title: detailTodoViewModel.editingTitle, status: nil, duedate: nil, completeDate: nil
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
                .showCloseButton()
                .enableSwipeToDismiss()
                .enableTapToDismiss()
        
    }
    
    private func makeStickerBottomSheet() -> some View {
        StickerBottomSheet(todoViewModel: todoViewModel,
                           detailTodoViewModel: detailTodoViewModel,
                           stickerViewModel: stickerViewModel)
    }
    
    private func makeSticker() -> some View {
        ZStack {
            Color.white
//            Color.clear
                .opacity(0.6)
                .zIndex(0)
                .onTapGesture {
                    todoViewModel.showEditAferCompleteAlert.toggle()
                }
            VStack {
                HStack {
                    Spacer()
                    Menu {
                        Button {
                            detailTodoViewModel.setStickerBottomSheetPosition = .relative(0.5)
                        } label: {
                            Text("스티커 바꾸기")
                        }
                        
                        Button {
                            stickerViewModel.sticker = stickerViewModel.fetchSticker(on: todoViewModel.searchDate)
                            
                            if let sticker = stickerViewModel.sticker {
                                stickerViewModel.deleteASticker(deletingSticker: sticker)
                                stickerViewModel.sticker = nil
                            }
                            stickerViewModel.isTodayStickerOn = false
//                            stickerViewModel.sticker = stickerViewModel.updateASticker(updatingSticker: stickerViewModel.sticker!,
//                                                                                       date: todoViewModel.searchDate,
//                                                                                       isExist: false, stickerName: nil,
//                                                                                       stickerBgColor: nil)
                            
                        } label: {
                            Text("떼기")
                        }
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.themeColor40)
                                .frame(width: 100, height: 100)
                            //                            .opacity(0.7)
                                .overlay {
                                    Circle()
                                        .stroke(Color.themeColor10, lineWidth: 0)
                                }
                                .shadow(color: Color.gray, radius: 10)
                                .zIndex(1)
                            Image(systemName: stickerViewModel.sticker?.stickerName ?? "checkmark.seal.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .foregroundColor(.white)
                                .zIndex(2)
                                .padding(.vertical, 10)
                            Image(systemName: "water.waves")
                                .resizable()
                                .frame(width: 100, height: 80)
                                .foregroundColor(.themeColor40)
                                .opacity(0.7)
                                .shadow(color: Color.gray, radius: 10)
                                .zIndex(0)
                                .padding(.leading, 50)
                                .padding(.top, 30)
                        }
                    }
                    .contentShape(Circle())
                    .background(Color.clear)
                    .frame(width: 50, height: 50)
                    .padding(.top, 50)
                    .padding(.trailing, 50)
                    .zIndex(1)
                }
                Spacer()
            }
        }
    }
}


////MARK: - Date Picker Alert
//struct DatePickerAlert<Content: View>: View {
//    let content: Content
//    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
//
//    init(detailTodoViewModel: DetailTodoViewModel,
//         @ViewBuilder content: () -> Content) {
//        self.detailTodoViewModel = detailTodoViewModel
//        self.content = content()
//    }
//
//    var body: some View {
//        self.content
//            .alert("Date Picker", isPresented: $detailTodoViewModel.isDatePickerShowing) {
//                Button("OK") { }
//            } message: {
//                Text("This is date picker ...")
//            }
//
//    }
//}
