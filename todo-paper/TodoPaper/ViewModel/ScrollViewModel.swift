//
//  ScrollViewModel.swift
//  todo-paper
//
//  Created by 이지수 on 2023/07/26.
//

import SwiftUI
import UIKit
import Combine

enum ScrollDirect {
    case none
    case left
    case right
}

enum ScrollPosition {
    case none
    case leading
    case trailing
}

class ScrollViewModel: NSObject, UIScrollViewDelegate, ObservableObject {
    @Published var isTrailingValue: Bool = false
    @Published var isLeadingValue: Bool = false
    
    lazy var isLeading : AnyPublisher<Bool, Never> = $isLeadingValue.removeDuplicates().eraseToAnyPublisher()
    lazy var isTrailing : AnyPublisher<Bool, Never> = $isTrailingValue.removeDuplicates().eraseToAnyPublisher()
    
    let lthreshold: CGFloat
    let rthreshold: CGFloat
    
    init(lthreshold: CGFloat = 0, rthreshold: CGFloat = 0) {
        self.lthreshold = lthreshold
        self.rthreshold = rthreshold
    }
    
    /// 스크롤뷰 동작시 감지
    /// - Parameter scrollView: 스크롤뷰 인스턴스
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("ScrollViewHelper scrollViewDidScroll() called \(scrollView.contentOffset.x)")
        
        self.isTrailingValue = isScrollTrailing(scrollView, rthreshold)
        self.isLeadingValue = isScrollLeading(scrollView, lthreshold)
        
        print("isTrailing: ", isTrailingValue)
        print("isLeading: ", isLeadingValue)
    }
    
    
}

fileprivate func isScrollTrailing(_ scrollView: UIScrollView, _ rthreshold: CGFloat) -> Bool {
    return scrollView.contentSize.width - scrollView.contentOffset.x - scrollView.frame.width < rthreshold
}

fileprivate func isScrollLeading(_ scrollView: UIScrollView, _ lthreshold: CGFloat) -> Bool {
    return (-lthreshold < scrollView.contentOffset.x) || (scrollView.contentOffset.x < lthreshold)
}

