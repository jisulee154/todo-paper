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
                                                todoItemRowType: TodoItemRowType.today)
                                    
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
                                                    todoItemRowType: TodoItemRowType.old)
                                        
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
            //MARK: - Make New Todo Button & Complete Sticker
            FloatingFooter(todoViewModel: todoViewModel)
        }
        .onAppear {
            todoViewModel.searchDate = todoViewModel.setSearchDate(date: Date())
            todoViewModel.scrollTargetDate = todoViewModel.setScrollTargetDate(with: Date())
            todoViewModel.todos = todoViewModel.fetchTodosBySelectedDate()
            
            if todoViewModel.canShowOldTodos() {
                todoViewModel.oldTodos = todoViewModel.fetchOldTodos()
            }
        }
    }
}


struct DailyTodoView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTodoView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
