//
//  SFLabel+LetterSpacing.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 28/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension UILabel {
    func addTextSpacing(spacing: Float) {
        if let textString = text {
            let attributedString = NSMutableAttributedString(string: textString)
            if attributedString.length > 0 {
                attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: attributedString.length - 1))
            }
            attributedText = attributedString
        }
    }
}
