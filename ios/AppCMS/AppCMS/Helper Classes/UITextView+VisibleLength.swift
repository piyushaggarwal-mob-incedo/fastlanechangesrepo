
//
//  UITextView+VisibleLength.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension UITextView {
    
    func visibleTextLength() -> Int {
        let font: UIFont = self.font!
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSFontAttributeName: font]
        let attributedText = NSAttributedString(string: self.text!, attributes: attributes as? [String : Any])
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                
                index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.characters.count - index - 1)).location
            } while index != NSNotFound && index < self.text!.characters.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.characters.count
    }
}
