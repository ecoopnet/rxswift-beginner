//
//  UIScrollView+scrollToBottom.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/07/15.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit

extension UIScrollView {

    func scrollToBottom(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }

    func scrollToTop(animated: Bool) {
        setContentOffset(.zero, animated: animated)
    }
}
