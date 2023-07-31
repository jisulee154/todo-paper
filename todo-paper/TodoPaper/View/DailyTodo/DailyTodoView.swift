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


/// 일별 투두 보기 탭
struct DailyTodoView: View {
    
    //MARK: - Shared Data
    @Environment(\.managedObjectContext) private var viewContext
    //    @StateObject var todayTodoViewModel: TodoViewModel = TodoViewModel()
    //    @StateObject var previousTodoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var detailTodoViewModel: DetailTodoViewModel = DetailTodoViewModel()
    
    /// BottomSheet 관련
    @State var editingTitle: String = "" // 투두 수정하기 텍스트필드 입력값
    
    //MARK: - View
    var body: some View {
        ZStack {
            //MARK: - 날짜 선택 스크롤과 투두 리스트 목록
            makeTodoList()
                .zIndex(0)
            
            //MARK: - 새로운 투두 만들기 & 완료 스티커 설정
            makeAddButtonAndSticker()
                .zIndex(1)
            
            //MARK: - 투두 상세 설정
            if detailTodoViewModel.isDetailSheetShowing {
                switch (detailTodoViewModel.timePosition) {
                case .past:
                    makePastDetailSettingBottomSheet()
                        .zIndex(2)
                case .today:
                    makeTodayDetailSettingBottomSheet()
                        .zIndex(13)
                case .future:
                    makeFutureDetailSettingBottomSheet()
                        .zIndex(14)
                case .none:
                    Text("Time Position Error.")
                        .zIndex(15)
                }
            }
            
            //MARK: - 투두 일자 수정
            if detailTodoViewModel.isDatePickerShowing {
                makeDatePickerBottomSheet()
                    .zIndex(16)
            }
            
            //MARK: - 투두 내용 수정
            if detailTodoViewModel.isEditBottomSheetShowing {
                makeTitleEditBottomSheet()
                    .zIndex(17)
            }
            
        }
    }
    
    //MARK: - make 함수
    private func makeTodoList() -> some View {
        VStack {
            //MARK: - Calendar Scroll
            ///캘린더 스크롤 부분
            DateHeader(todoViewModel: todoViewModel)
            
            if todoViewModel.todos.count > 0 {
                //MARK: - Todo list
                ///투두 목록 부분
                List {
                    Section("list") {
                        VStack {
                            ForEach(todoViewModel.todos) { todo in
                                TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                                           title: todo.title,
                                                           duedate: todo.duedate,
                                                           status: todo.status,
                                                           section: todo.section),
                                            todoViewModel: todoViewModel,
                                            todoItemRowType: TodoItemRowType.today,
                                            detailTodoViewModel: detailTodoViewModel)
                                Divider()
                                
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 2)
                        )
                    } // Section - Today
                    .listRowInsets(EdgeInsets.init())
                    
                    
                    // 보여지는 일자가 오늘인 경우 기한이 지난 투두를 old 섹션에 출력한다.
                    if todoViewModel.canShowOldTodos() {
                        Section("old") {
                            VStack {
                                ForEach(todoViewModel.oldTodos) { todo in
                                    TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                                               title: todo.title,
                                                               duedate: todo.duedate,
                                                               status: todo.status,
                                                               section: todo.section),
                                                todoViewModel: todoViewModel,
                                                todoItemRowType: TodoItemRowType.old,
                                                detailTodoViewModel: detailTodoViewModel)
                                    
                                    Divider()
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 2)
                            )
                        } // Section - Old
                        .listRowInsets(EdgeInsets.init())
                    }
                } // List
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
        }
        // 할일 목록 새로고침
        .refreshable {
            todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
            
            if todoViewModel.canShowOldTodos() {
                todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
            }
        }
        .onAppear {
            todoViewModel.searchDate = todoViewModel.setSearchDate(date: Date())
            //todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: Date())
            todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
            
            if todoViewModel.canShowOldTodos() {
                todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
            }
        }
    }
    
    private func makeAddButtonAndSticker() -> some View {
        FloatingFooter(todoViewModel: todoViewModel)
    }
    
    private func makePastDetailSettingBottomSheet() -> some View {
        DetailSheetOfPast(detailTodoViewModel)
    }
    
    private func makeTodayDetailSettingBottomSheet() -> some View {
        DetailSheetOfToday(detailTodoViewModel)
    }
    
    private func makeFutureDetailSettingBottomSheet() -> some View {
        DetailSheetOfFuture(detailTodoViewModel)
    }
    
    private func makeDatePickerBottomSheet() -> some View {
        DatePickerBottomSheet(detailTodoViewModel: detailTodoViewModel, maxHeight: UIScreen.main.bounds.size.height / 1.8) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        detailTodoViewModel.isDatePickerShowing = false
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .frame(width: 60, height: 40)
                    }
                    .foregroundColor(.themeColor40)
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                
                DatePicker(
                    "date picker",
                    selection: $detailTodoViewModel.changedDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .frame(width: 320, alignment: .center)
                .datePickerStyle(.graphical)
                .background(Color.clear)
                
                Button {
                    todoViewModel.todos = todoViewModel.updateATodo(
                        updatingTodo: detailTodoViewModel.pickedTodo,
                        title: nil,
                        status: nil,
                        duedate: detailTodoViewModel.changedDate
                    )
                } label: {
                    Text("설정 완료")
                        .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(SettingButtonStyle())
                
            }
            .padding(.bottom, 20)
        }
    }
    
    private func makeTitleEditBottomSheet() -> some View {
        Color.clear
            .bottomSheet(
                bottomSheetPosition: $detailTodoViewModel.bottomSheetPosition,
                switchablePositions: [
                    .dynamicBottom,
                    .relative(0.6)],
                headerContent: {
                    Text("수정")
                        .font(.title)
            }) {
            VStack {
                HStack {
                    TextField(detailTodoViewModel.pickedTodo.title, text: self.$editingTitle)
                        .padding()
                }
                    Text("you entered: \(editingTitle)")
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .showCloseButton()
            .enableSwipeToDismiss()
            .enableTapToDismiss()
    }
    
    
}


struct DailyTodoView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTodoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
