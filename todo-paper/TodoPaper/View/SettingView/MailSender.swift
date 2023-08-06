//
//  MailSender.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/06.
//

import Foundation
import Combine
import SwiftUI
import MessageUI

struct MailSender: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        let contents = """
                                     
                         Device Model   : \(self.getDeviceIdentifier())
                         Device OS      : \(UIDevice.current.systemVersion)
                         App Version    : \(self.getCurrentVersion())
                         
                         위 내용은 변경하지 말아주세요!
                         아래에 투두 페이퍼 문의 사항을 작성해주세요.
                         ---------------------------------------------------
                         """
        
        mail.setSubject("제목제목")
        mail.setToRecipients(["abcde@naver.com"])
        mail.setMessageBody(contents, isHTML: false)
        
        // delegate 채택
        //    mail.delegate = context.coordinator 주의: 이렇게 하면 안됨!!
        mail.mailComposeDelegate = context.coordinator
        return mail
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    typealias UIViewControllerType = MFMailComposeViewController
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
        var parent: MailSender
        
        init(_ parent: MailSender) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            // TODO(iOS버그)
            // Error creating the CFMessagePort needed to communicate with PPT. 가 오는데 메일 정상적으로 보내지는 문제 https://stackoverflow.com/questions/63441752/error-creating-the-cfmessageport-needed-to-communicate-with-ppt
            
            // https://developer.apple.com/forums/thread/662643
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// 기기 정보 가져오기
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }
    
    // 어플 현재 버전 가져오기
    func getCurrentVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
}
