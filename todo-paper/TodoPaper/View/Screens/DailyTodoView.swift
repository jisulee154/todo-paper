//
//  DailyTodoView.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/07.
//

import SwiftUI
import CoreData
import Combine

struct DailyTodoView: View {
    
    //MARK: - Shared Data
    @Environment(\.managedObjectContext) private var viewContext
    //    @StateObject var todayTodoViewModel: TodoViewModel = TodoViewModel()
    //    @StateObject var previousTodoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var todoViewModel: TodoViewModel = TodoViewModel()
    @StateObject var detailTodoViewModel: DetailTodoViewModel = DetailTodoViewModel()
    
    //MARK: - View
    var body: some View {
        ZStack {
            VStack {
                //MARK: - Calendar Scroll
                DateHeader(todoViewModel: todoViewModel)
                if todoViewModel.todos.count > 0 {
                    //MARK: - Todo list
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
            
            
            //MARK: - Make New Todo Button & Complete Sticker
            FloatingFooter(todoViewModel: todoViewModel)
            
            
            //MARK: - 투두 개별 상세 설정 시트(하단에서 슬라이드 업)
            ///
            ///[정대리님 질문]
            ///1. 기능 설명
            ///화면상의 투두 오른쪽 점 세개 버튼을 누르게 되면, 상세설정(수정, 날짜 변경 등)을 할 수 있는 bottom sheet가 올라옵니다.
            ///bottom sheet에 여러 버튼이 있는데, 다른날 하기 버튼을 선택하면 투두 날짜를 바꿀 수 있습니다.
            ///
            ///2. 제가 구현하고 싶은 것
            ///다른날 하기 버튼을 클릭하면 date picker가 있는 날짜 선택 bottom sheet가 올라와야 하는데요,
            ///이 날짜 선택 bottom sheet가 올라오기 전에 기존에 떠 있던 bottom sheet는 사라지게 하고 싶습니다.
            ///다른날 하기 버튼을 클릭했을 때 기존의 bottom sheet가 밑으로 내려가는 애니메이션과 함께 사라지면,
            ///그 다음에 날짜 선택 bottom sheet가 밑에서 올라오는 애니메이션과 함께 나타나게 하고 싶습니다.
            ///
            ///3. 지금 구현된 것
            ///다른날 하기 버튼을 클릭했을 때 (애니메이션 효과가 먹히지 않고) 날짜 선택 bottom sheet가 나타납니다.
            ///
            ///
            BottomSheet(detailTodoViewModel: detailTodoViewModel, maxHeight: UIScreen.main.bounds.size.height / 1.8) {
//            BottomSheet(detailTodoViewModel: detailTodoViewModel, maxHeight: UIScreen.main.bounds.size.height / 1) {
                switch (detailTodoViewModel.timePosition) {
                case .past:
                    DetailTodoOfPast(detailTodoViewModel)
                case .today:
                    DetailTodoOfToday(detailTodoViewModel)
                case .future:
                    DetailTodoOfFuture(detailTodoViewModel)
                case .none:
                    Text("Time Position Error.")
                }
            }
            .edgesIgnoringSafeArea(.all)
//            .onChange(of: detailTodoViewModel.isDatePickerShowing) { newValue in
//                print("date picker showing changed.")
//                detailTodoViewModel.isDetailSheetShowing = false
//            }
            
            //MARK: - Date Picker 시트(하단에서 슬라이드 업)
            if detailTodoViewModel.isDatePickerShowing {
                DatePickerBottomSheet(detailTodoViewModel: detailTodoViewModel, maxHeight: UIScreen.main.bounds.size.height / 2.2) {
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
                            "datepicker_1",
                            selection: $detailTodoViewModel.pickedDate,
                            displayedComponents: [.date]
                        )
                        .frame(width: 320, alignment: .center)
                        .datePickerStyle(.graphical)
                        .background(Color.clear)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

//MARK: - 상세 설정 시트 (과거)
struct DetailTodoOfPast: View {
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(_ detailTodoViewModel: DetailTodoViewModel) {
        self.detailTodoViewModel = detailTodoViewModel
    }
    
    var body: some View {
        VStack (spacing: 10) {
            HStack {
                Text("상세 설정")
                    .font(.title)
                Spacer()
                Button {
                    detailTodoViewModel.isDetailSheetShowing = false
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .frame(width: 60, height: 40)
                }
                .foregroundColor(.themeColor40)
            }
            
            Button {
                //action
                detailTodoViewModel.isDetailSheetShowing.toggle()
                detailTodoViewModel.isDatePickerShowing.toggle()
            } label: {
                Text("다른날 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Button {
                //action
            } label: {
                Text("오늘 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
}

//MARK: - 상세 설정 시트 (오늘)
struct DetailTodoOfToday: View {
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(_ detailTodoViewModel: DetailTodoViewModel) {
        self.detailTodoViewModel = detailTodoViewModel
    }
    
    var body: some View {
        VStack (spacing: 10) {
            // 제목과 취소 버튼
            HStack {
                Text("상세 설정")
                    .font(.title)
                Spacer()
                Button {
                    detailTodoViewModel.isDetailSheetShowing = false
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .frame(width: 60, height: 40)
                }
                .foregroundColor(.themeColor40)
            }
            
            HStack (spacing: 10) {
                Button {
                    //action
                } label: {
                    Text("수정하기")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(SettingButtonStyle())
                
                Button {
                    //action - 오늘
                    
                    detailTodoViewModel.isDetailSheetShowing.toggle() // 기존 상세설정 bottom sheet가 밑으로 내려감.
                    detailTodoViewModel.isDatePickerShowing.toggle() // Date Picker bottom sheet가 위로 올라옴.
                } label: {
                    Text("다른날 하기")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(SettingButtonStyle())
                //                .alert("날짜 변경", isPresented: $detailTodoViewModel.isDatePickerShowing) {
                //                    Button("확인") {
                //                        detailTodoViewModel.isDetailSheetShowing.toggle()
                //                        print("투두의 날짜가 변경되었습니다.") //토스트 메시지!!!
                //                    }
                //                    Button("취소", role: .cancel) { }
                //                } message: {
                //
                //                }
                
            }
            
            Button {
                //action
            } label: {
                Text("내일 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Button {
                //action
            } label: {
                Text("포기하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Button {
                //action
            } label: {
                Text("삭제")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(DeleteButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
    }
}

//MARK: - 상세 설정 시트 (미래)
struct DetailTodoOfFuture: View {
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(_ detailTodoViewModel: DetailTodoViewModel) {
        self.detailTodoViewModel = detailTodoViewModel
    }
    
    var body: some View {
        VStack (spacing: 10) {
            // 제목과 취소 버튼
            HStack {
                Text("상세 설정")
                    .font(.title)
                Spacer()
                Button {
                    detailTodoViewModel.isDetailSheetShowing = false
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .frame(width: 60, height: 40)
                }
                .foregroundColor(.themeColor40)
            }
            
            HStack (spacing: 10) {
                Button {
                    //action
                } label: {
                    Text("수정하기")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(SettingButtonStyle())
                
                Button {
                    detailTodoViewModel.isDetailSheetShowing.toggle()
                    detailTodoViewModel.isDatePickerShowing.toggle()
                } label: {
                    Text("다른날 하기")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(SettingButtonStyle())
            }
            
            Button {
                //action
            } label: {
                Text("오늘 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Button {
                //action
            } label: {
                Text("포기하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(SettingButtonStyle())
            
            Button {
                //action
            } label: {
                Text("삭제")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
                    .contentShape(Capsule())
            }
            .buttonStyle(DeleteButtonStyle())
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 30)
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
