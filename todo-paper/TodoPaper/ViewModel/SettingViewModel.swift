//
//  SettingViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/08/02.
//
import SwiftUI
import MessageUI

class SettingViewModel: ObservableObject, MFMailComposeViewControllerDelegate {
    @Published var enableHideGaveUpTask: Bool = UserDefaults.standard.bool(forKey: "enableHideGaveUpTask")
    //    @Published var enableHideGaveUpTask: Bool = UserDefaults.standard.bool(forKey: "enableHideGaveUpTask") {
    //        didSet {
    //            UserDefaults.standard.set(self.enableHideGaveUpTask, forKey: "enableHideGaveUpTask")
    //        }
    //    }
    //    @AppStorage("enableHideGaveUpTask") var enableHideGaveUpTask: Bool = UserDefaults.standard.bool(forKey: "enableHideGaveUpTask")
    
    //    @Published var enableTodoNotification: Bool = false
    //    @Published var enableStickerNotification: Bool = false
    //    @Published var timeToTodoNotification: Date = Date() // type?
    //    @Published var timeToStickerNotification: Date = Date() // type?
    //    @Published var isUnfinishedTaskPostponeOn: Bool = false
    
    init(enableHideGaveUpTask: Bool) {
        
        //        self.enableTodoNotification = enableTodoNotification
        //        self.enableStickerNotification = enableStickerNotification
        //        self.isUnfinishedTaskPostponeOn = isUnfinishedTaskPostponeOn
        
        self.enableHideGaveUpTask = UserDefaults.standard.bool(forKey: "enableHideGaveUpTask")
    }
    
    func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                                     투두 페이퍼 문의 메일입니다.
                                     
                                     -------------------
                                     
                                     Device Model   : \(self.getDeviceIdentifier())
                                     Device OS      : \(UIDevice.current.systemVersion)
                                     App Version    : \(self.getCurrentVersion())
                                     
                                     위 내용은 변경하지 말아주세요.
                                     -------------------
                                     """
            
            composeViewController.setToRecipients(["todopaper.help@gmail.com"])
            composeViewController.setSubject("투두 페이퍼 문의 메일")
            composeViewController.setMessageBody(bodyString, isHTML: false)
            
            self.present(composeViewController, animated: true, completion: nil)
        } else {
            print("메일 전송 실패")
            let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
            let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
                // 앱스토어로 이동하기(Mail)
                if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
            
            sendMailErrorAlert.addAction(goAppStoreAction)
            sendMailErrorAlert.addAction(cancleAction)
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
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

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}


