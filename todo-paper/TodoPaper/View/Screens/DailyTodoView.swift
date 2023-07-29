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
            DetailTodoViewSheet(detailTodoViewModel: detailTodoViewModel, maxHeight: UIScreen.main.bounds.size.height / 1.8) {
//                Color.blue
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
            
            //MARK: - Date Picker
            if detailTodoViewModel.isDatePickerShowing {
                VStack {
                    Color.black
                        .opacity(0.3)
                        .frame(alignment: .top)
                        .onTapGesture {
                            detailTodoViewModel.isDatePickerShowing.toggle()
                        }
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        DatePicker(
                            "datepicker_1",
                            selection: $detailTodoViewModel.pickedDate,
                            displayedComponents: [.date]
                        )
                        .frame(width: 320, alignment: .center)
                        .datePickerStyle(.graphical)
                        .background(Color.clear)
                    }
                    .frame(width: UIScreen.main.bounds.size.width)
                    .background(Color.white)
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
                print("날짜 변경 버튼 누름")
            } label: {
                Text("날짜 변경")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
            Button {
                //action
            } label: {
                Text("오늘 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
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
                }
                .modifier(DetailTodoSheetModifier())
                
                Button {
                    //action - 오늘
                    detailTodoViewModel.isDatePickerShowing.toggle()
                } label: {
                    Text("날짜 변경")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                }
                .modifier(DetailTodoSheetModifier())
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
                Text("포기하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
            Button {
                //action
            } label: {
                Text("내일 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
            Button {
                //action
            } label: {
                Text("삭제")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
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
                }
                .modifier(DetailTodoSheetModifier())
                
                Button {
                    //action
                } label: {
                    Text("날짜 변경")
                        .frame(minWidth: 100, maxWidth: 500, maxHeight: 50)
                }
                .modifier(DetailTodoSheetModifier())
            }
            
            Button {
                //action
            } label: {
                Text("포기하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
            Button {
                //action
            } label: {
                Text("오늘 하기")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
            Button {
                //action
            } label: {
                Text("삭제")
                    .frame(minWidth: 200, maxWidth: 1000, maxHeight: 50)
            }
            .modifier(DetailTodoSheetModifier())
            
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

//MARK: - 상세 설정 시트 버튼 Custom Modifier
struct DetailTodoSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.themeColor40)
            .cornerRadius(35)
            .overlay {
                Capsule()
                    .stroke(Color.themeColor40, lineWidth: 1)
            }
    }
}

//MARK: - Date Picker Alert
struct DatePickerAlert<Content: View>: View {
    let content: Content
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    init(detailTodoViewModel: DetailTodoViewModel,
         @ViewBuilder content: () -> Content) {
        self.detailTodoViewModel = detailTodoViewModel
        self.content = content()
    }
    
    var body: some View {
        self.content
            .alert("Date Picker", isPresented: $detailTodoViewModel.isDatePickerShowing) {
                Button("OK") { }
            } message: {
                Text("This is date picker ...")
            }

    }
}
