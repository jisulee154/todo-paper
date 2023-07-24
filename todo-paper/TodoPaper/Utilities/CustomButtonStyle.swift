//
//  CustomButtonStyle.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/24.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        configuration
            .label
            .padding()
            .cornerRadius(15)
            .foregroundColor(configuration.isPressed ? Color.white : Color.themeColor40)
            .background(configuration.isPressed ? Color.themeColor40 : Color.yellow)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.themeColor40, lineWidth: 1)
            )
    }
    
}

struct CustomButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button {
            print("dd")
        } label: {
            Text("버튼")
        }.buttonStyle(CustomButtonStyle())

    }
}
