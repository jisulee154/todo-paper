//
//  FloatingFooter.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI
import BottomSheetSwiftUI

struct FloatingFooter: View{
//    @State var newTodo: TodoItem = TodoItem(title: "")
//    @State var newTitle: String = ""
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var detailTodoViewModel: DetailTodoViewModel
    
    var body: some View {
        VStack {
            Spacer()
            HStack (spacing: 10) {
                Spacer()
                Button {
                    if todoViewModel.isTodosDone {
                        //할일 완료
                        
                        detailTodoViewModel.setStickerBottomSheetPosition = .relative(0.5)
                    } else {
                        //미완료
                        
                        // 미완료 투두 있음 토스트 메시지
                        detailTodoViewModel.showUnfinishedTodosToast.toggle()
                    }
                } label: {
                    Image(systemName: "checkmark.seal")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.all, 10)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(50)
                        .opacity(0.3)
                        .padding(.bottom, 20)
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
