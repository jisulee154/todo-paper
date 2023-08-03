//
//  FloatingFooter.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI
import BottomSheetSwiftUI

/// 새로운 투두 추가하기 버튼, 칭찬 스티커 붙이기 버튼
struct FloatingFooter: View{
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack (spacing: 10) {
                Spacer()
                Button {
                    // 미완료한 일이 없는 날(미래 제외)에만 칭찬 스티커를 붙일 수 있다.
                    let timePosition = DetailTodoViewModel.getTimePosition(of: todoViewModel.searchDate)
                    let todos = todoViewModel.fetchTodosBySelectedDate()
                    var oldTodos: [TodoItem] = []
                    if timePosition == .today {
                        oldTodos = todoViewModel.fetchOldTodos()
                    }
                    
                    todoViewModel.isTodosDone = todoViewModel.getTodosDone(todos: todos, oldTodos: oldTodos)
                    
                    if (timePosition == .today || timePosition == .past) {
                        if todoViewModel.isTodosDone {
                            //미완료 투두가 없음
                            
                            if todos.isEmpty && oldTodos.isEmpty {
                                // 설정된 투두가 없어 칭찬 스티커 붙일 수 없음 안내
                                if timePosition == .past {
                                    detailTodoViewModel.showCantPutStickerNonePast.toggle()
                                } else {
                                    detailTodoViewModel.showCantPutStickerNone.toggle()
                                }
                            } else {
                                detailTodoViewModel.setStickerBottomSheetPosition = .relative(0.7)
                            }
                        } else {
                            //미완료 투두 있음
                            
                            // 미완료 투두 있음 토스트 메시지
                            detailTodoViewModel.showUnfinishedTodosToast.toggle()
                        }
                        
                    }
                    else {
                        // 해당 일자(미래)엔 아직 칭찬 스티커 붙일 수 없음 안내
                        detailTodoViewModel.showCantPutStickerYet.toggle()
                    }
                } label: {
                    
                    if todoViewModel.isActivePutSticker {
                        // 활성
                        Image(systemName: "checkmark.seal")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.all, 10)
                            .foregroundColor(.white)
                            .background(Color.yellow)
                            .cornerRadius(50)
                            .padding(.bottom, 20)
                    }
                    else {
                        // 비활성
                        Image(systemName: "checkmark.seal")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding(.all, 10)
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .cornerRadius(50)
                            .padding(.bottom, 20)
                            .opacity(0.3) // 비활성 효과
                    }
                        
                }
                .onAppear {
                    todoViewModel.isTodosDone = todoViewModel.getTodosDone(todos: todoViewModel.todos, oldTodos: todoViewModel.oldTodos)
                    
                }
                
                
                Button(action: {
                    detailTodoViewModel.addTodoBottomSheetPosition = .relative(0.7)
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.all, 10)
                        .foregroundColor(.white)
                        .background(Color.themeColor40)
                        .cornerRadius(50)
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                    
                }
            }
        }
    }
    
//    private func makeAddTodoBottomSheet() -> some View {
//        Color.clear
//            .bottomSheet(bottomSheetPosition: $detailTodoViewModel.addTodoBottomSheetPosition,
//                         switchablePositions:[.dynamicBottom,.relative(0.7)],
//                         headerContent: {
//                Text("새로운 투두")
//                    .font(.title)
//            }) {
//                VStack {
//                    TextField("새로운 할일을 입력해주세요.", text: $newTitle)
//                    Button {
//                        newTodo.uuid = UUID()
//                        newTodo.duedate = todoViewModel.searchDate
//                        newTodo.status = TodoStatus.none
//                        newTodo.section = "Today"
//                        if newTitle != "" {
//                            newTodo.title = newTitle
//                            todoViewModel.todos = todoViewModel.addATodo(
//                                TodoItem(uuid: newTodo.uuid,
//                                         title: newTodo.title,
//                                         duedate: newTodo.duedate,
//                                         status: newTodo.status,
//                                         section: newTodo.section)
//                            )
//                        }
//                        
//                        newTitle = "" // 초기화
//                        
//                        detailTodoViewModel.addTodoBottomSheetPosition = .hidden
//                    } label: {
//                        Text("완료")
//                    }
//                    .buttonStyle(SettingButtonStyle())
//                    .padding(.horizontal, 30)
//                    .padding(.vertical, 20)
//                }
//            }
//            .showCloseButton()
//            .enableSwipeToDismiss()
//            .enableTapToDismiss()
//    }
}

////MARK: - 새로운 투두 추가 Sheet
//struct AddATodoSheet: View {
////    var enteredTitle: (String) -> Void
////    var togglePresented: (Bool) -> Void
////    let text: String
////    let isSheetPresented: Bool
//    @Binding var newTitle: String
//    @Binding var isSheetPresented: Bool
//
//    var body: some View{
//        VStack {
//            TextField("새로운 할일을 입력해주세요.", text: $newTitle)
////            TextField("새로운 할일을 입력해주세요.", text: enteredTitle(text))
//            Button("Dismiss", action: { isSheetPresented.toggle() })
////            Button("Dismiss", action: { togglePresented(isSheetPresented.toggle()) })
//        }
//
//    }
//}
