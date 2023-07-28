//
//  FloatingFooter.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/15.
//

import SwiftUI

struct FloatingFooter: View{
//    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        entity: Item.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.id, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
    
    @State var newTodo: TodoItem = TodoItem(title: "")
    @State var newTitle: String = ""
    @State var isSheetPresented = false
    @ObservedObject var todoViewModel: TodoViewModel
    
//    var enterTitle: (String) -> Void
//    var togglePresented: (Bool) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack (spacing: 10) {
                Spacer()
                Button {
                    //action
                } label: {
                    Image(systemName: "medal")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .padding(.all, 10)
                        .foregroundColor(.white)
                        .background(Color.gray)
                        .cornerRadius(50)
                        .opacity(0.5)
                        .padding(.bottom, 20)
                }
                Button(action: {
                    isSheetPresented.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 65, height: 65)
                        .padding(.all, 10)
                        .foregroundColor(.white)
                        .background(Color.themeColor40)
                        .cornerRadius(50)
                        .padding(.bottom, 20)
                        .padding(.trailing, 20)
                    
                }
                .sheet(isPresented: $isSheetPresented, onDismiss: didDismiss) {
                    AddATodoSheet(newTitle: $newTitle, isSheetPresented: $isSheetPresented)
                }
                Spacer()
                    .frame(width: 0, height: 10)
            }
        }
    }
    
    func didDismiss() {
        newTodo.uuid = UUID()
        newTodo.duedate = todoViewModel.searchDate
        newTodo.status = TodoStatus.none
        newTodo.section = "Today"
        if newTitle != "" {
            newTodo.title = newTitle
            todoViewModel.todos = todoViewModel.addATodo(
                TodoItem(uuid: newTodo.uuid,
                         title: newTodo.title,
                         duedate: newTodo.duedate,
                         status: newTodo.status,
                         section: newTodo.section)
            )
        }
        
        newTitle = "" // 초기화
    }
}

//MARK: - 새로운 투두 추가 Sheet
struct AddATodoSheet: View {
//    var enteredTitle: (String) -> Void
//    var togglePresented: (Bool) -> Void
//    let text: String
//    let isSheetPresented: Bool
    @Binding var newTitle: String
    @Binding var isSheetPresented: Bool
                        
    var body: some View{
        VStack {
            TextField("새로운 할일을 입력해주세요.", text: $newTitle)
//            TextField("새로운 할일을 입력해주세요.", text: enteredTitle(text))
            Button("Dismiss", action: { isSheetPresented.toggle() })
//            Button("Dismiss", action: { togglePresented(isSheetPresented.toggle()) })
        }

    }
}
