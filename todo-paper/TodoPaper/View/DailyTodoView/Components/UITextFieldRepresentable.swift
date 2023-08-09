//
//  UITextFieldRepresentable.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/09.
//

import Foundation
import UIKit
import SwiftUI

struct UITextFieldRepresentable: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isFirstResponder: Bool = false
    @Binding var isFocused: Bool // first responder
    
    func makeUIView(context: UIViewRepresentableContext<UITextFieldRepresentable>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = self.placeholder
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<UITextFieldRepresentable>) {
        uiView.text = self.text
        if isFirstResponder && !context.coordinator.didFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didFirstResponder = true
        }
    }
    
    func makeCoordinator() -> UITextFieldRepresentable.Coordinator {
        Coordinator(text: self.$text, isFocused: self.$isFocused)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool
        var didFirstResponder = false
        
        init(text: Binding<String>, isFocused: Binding<Bool>) {
            self._text = text
            self._isFocused = isFocused
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            self.text = textField.text ?? ""
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.isFocused = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            self.isFocused = false
        }
    }
}
