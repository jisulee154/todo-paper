//
//  CompletePage.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/04.
//

import SwiftUI

struct CompletePage: View, Identifiable {
    //    @ObservedObject var completeRepoViewModel: CompleteRepoViewModel
    
    var id: UUID
    private var todos: [TodoItem]
    private var oldTodos: [TodoItem]
    public var date: Date
    private var dateFormatted: String
    private var stickerName: String
    
    init(id: UUID = UUID(), date: Date, todos: [TodoItem], oldTodos: [TodoItem], dateFormatted: String, stickerName: String) {
        self.id = id
        //        self.completeRepoViewModel = completeRepoViewModel
        self.date = date
        self.todos = todos
        self.oldTodos = oldTodos
        self.dateFormatted = dateFormatted
        self.stickerName = stickerName
    }
    
    var body: some View {
        ZStack {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.themeColor40)
                    .edgesIgnoringSafeArea(.all)
            }
            .zIndex(0)
            
            VStack {
                ZStack {
                    makeSticker()
                        .contentShape(Circle())
                        .zIndex(1)
                    List {
                        HStack {
                            Text(dateFormatted)
                                .font(.title3)
                                .padding(.horizontal, 20)
                                .foregroundColor(.themeColor40)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .listRowBackground(Color.themeColor20)
                        
                        
                        if todos.count > 0 {
                            Section("list") {
                                VStack {
                                    ForEach(todos) { todo in
                                        makeTodoItemRow(todoItem: todo, todoItemRowType: TodoItemRowType.today)
                                        //                            TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                        //                                                       title: todo.title,
                                        //                                                       duedate: todo.duedate,
                                        //                                                       status: todo.status,
                                        //                                                       completeDate: todo.completeDate),
                                        //                                        todoViewModel: todoViewModel,
                                        //                                        todoItemRowType: TodoItemRowType.today,
                                        //                                        detailTodoViewModel: detailTodoViewModel,
                                        //                                        stickerViewModel: stickerViewModel)
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
                        if date == Calendar.current.startOfDay(for: Date()) {
                            if oldTodos.count != 0 {
                                Section("old") {
                                    VStack {
                                        ForEach(oldTodos) { todo in
                                            makeTodoItemRow(todoItem: todo, todoItemRowType: TodoItemRowType.old)
                                            //                                TodoItemRow(with: TodoItem(uuid: todo.uuid,
                                            //                                                           title: todo.title,
                                            //                                                           duedate: todo.duedate,
                                            //                                                           status: todo.status,
                                            //                                                           completeDate: todo.completeDate),
                                            //                                            todoViewModel: todoViewModel,
                                            //                                            todoItemRowType: TodoItemRowType.old,
                                            //                                            detailTodoViewModel: detailTodoViewModel,
                                            //                                            stickerViewModel: stickerViewModel)
                                            
                                            Divider()
                                        }
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .circular).stroke(Color.themeColor40, lineWidth: 2)
                                    )
                                }
                                .listRowInsets(EdgeInsets.init())
                            }
                        }
                        Color.clear.frame(height: 100)
                            .listRowBackground(Color.clear)
                    } // List
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.all, 50)
            .zIndex(1)
        }
    }
    
    func makeTodoItemRow(todoItem: TodoItem, todoItemRowType: TodoItemRowType) -> some View {
        HStack {
            HStack {
                switch(todoItem.status) {
                case .none:
                    Image(systemName: "square")
                        .todoImageModifier()
                case .completed:
                    Image(systemName: "checkmark.square")
                        .todoImageModifier()
                case .postponed:
                    Image(systemName: "arrow.forward.square")
                        .todoImageModifier()
                        .foregroundColor(.gray)
                case .canceled:
                    Image(systemName: "xmark.square")
                        .todoImageModifier()
                        .foregroundColor(.gray)
                }
            }
            // TodoItemRowType에 따라 다른 형태로 보여주기
            // 현재 일자
            if todoItemRowType == TodoItemRowType.today {
                if todoItem.status == TodoStatus.canceled {
                    Text(todoItem.title)
                        .foregroundColor(.gray)
                        .strikethrough()
                } else if todoItem.status == TodoStatus.postponed {
                    Text(todoItem.title)
                        .foregroundColor(.gray)
                } else {
                    Text(todoItem.title)
                }
                // 지난 일자
            } else {
                VStack {
                    // 지난 기한 표시
                    HStack {
                        if let interval = getDelayedDays(with: todoItem.duedate) {
                            Text("\(interval)일 지남")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        Spacer()
                    }
                    HStack {
                        if todoItem.status == TodoStatus.canceled {
                            Text(todoItem.title)
                                .foregroundColor(.gray)
                                .strikethrough()
                        } else if todoItem.status == TodoStatus.postponed {
                            Text(todoItem.title)
                                .foregroundColor(.gray)
                        } else {
                            Text(todoItem.title)
                        }
                        Spacer()
                    }
                }
            }
            Spacer()
        }
        .foregroundColor(.themeColor40)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
    
    private func makeSticker() -> some View {
        VStack {
            HStack {
                Spacer()
                //                Menu {
                //                    Button {
                //                        detailTodoViewModel.setStickerBottomSheetPosition = .relative(0.5)
                //                    } label: {
                //                        Text("수정")
                //                    }
                //
                //                    Button {
                //                        stickerViewModel.sticker = stickerViewModel.updateASticker(updatingSticker: stickerViewModel.sticker!,
                //                                                                                   date: todoViewModel.searchDate,
                //                                                                                   isExist: false, stickerName: nil,
                //                                                                                   stickerBgColor: nil)
                //
                //                        stickerViewModel.isTodayStickerOn = false
                //                    } label: {
                //                        Text("삭제")
                //                    }
                //
                //                } label: {
                //                }
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
                    Image(systemName: stickerName == "" ? "checkmark.seal.fill" : stickerName)
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
    
    //helper
    fileprivate func getDelayedDays(with duedate: Date) -> Int? {
        var numberOfDays: DateComponents? = Calendar.current.dateComponents([.day], from: Date(), to: duedate)
        if let numberOfDays = numberOfDays {
            return -numberOfDays.day!
        } else {
            return nil
        }
    }
}
