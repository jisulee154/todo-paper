//
//  Extension.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/12.
//

import Foundation
import SwiftUI

extension Color {
    static let themeColor10 = Color("ThemeColor10")
    static let themeColor20 = Color("ThemeColor20")
    static let themeColor30 = Color("ThemeColor30")
    static let themeColor40 = Color("ThemeColor40")
}

extension Date {
    func daysThisMonth() -> Int? {
        return Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
        
    }
}

extension Image {
    func todoImageModifier() -> some View {
        self
            .resizable()
            .frame(width: 30, height: 30)
    }
}

struct PressableButtonStyle: ButtonStyle {
//    let scaledAmount: CGFloat
//
//    init(scaledAmount: CGFloat = 0.1) {
//        self.scaledAmount = scaledAmount
//    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.themeColor40 : Color.clear)
            .cornerRadius(15)
            .foregroundColor(configuration.isPressed ? .white : Color.themeColor40)
    }
}

struct SettingButtonStyle: ButtonStyle {
//    let scaledAmount: CGFloat
//
//    init(scaledAmount: CGFloat = 0.1) {
//        self.scaledAmount = scaledAmount
//    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : Color.themeColor40)
            .overlay {
                Capsule()
                    .stroke(Color.themeColor40, lineWidth: 1)
            }
            .background(configuration.isPressed ? Color.themeColor40 : Color.clear)
            .cornerRadius(35)
    }
}

struct DeleteButtonStyle: ButtonStyle {
//    let scaledAmount: CGFloat
//
//    init(scaledAmount: CGFloat = 0.1) {
//        self.scaledAmount = scaledAmount
//    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? .white : .red)
            .overlay {
                Capsule()
                    .stroke(.red, lineWidth: 1)
            }
            .background(configuration.isPressed ? .red.opacity(0.3) : .clear)
            .cornerRadius(35)
    }
}

struct SelectStickerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .shadow(color: .themeColor40, radius: (configuration.isPressed ? 30 : 0), x: 1, y: 1)
            .overlay {
                Circle()
                    .stroke(Color.themeColor40, lineWidth: (configuration.isPressed ? 1 : 0))
            }
    }
}
