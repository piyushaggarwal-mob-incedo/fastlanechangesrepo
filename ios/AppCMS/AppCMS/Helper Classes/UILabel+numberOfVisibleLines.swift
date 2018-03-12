//
//  UILabel+numberOfLines.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 19/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}
