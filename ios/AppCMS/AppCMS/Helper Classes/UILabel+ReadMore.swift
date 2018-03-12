//
//  UILabel+ReadMore.swift
//  AppCMS
//
//  Created by Gaurav Vig on 13/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension UILabel {
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) -> Bool{
        
        var isStringTrimmed:Bool = false
        
        let readMoreText: String = trailingText + moreText
        
        let lengthForVisibleString: Int = self.vissibleTextLength()
        let mutableString: String = self.text!
        
        var trimmedString: String?
        
        let paragraphStyle = NSMutableParagraphStyle()
        //line height size
        #if os(tvOS)
            paragraphStyle.lineSpacing = 7
            paragraphStyle.minimumLineHeight = 36
            paragraphStyle.maximumLineHeight = 36
        #endif
        
        if lengthForVisibleString > mutableString.characters.count  {
            #if os(tvOS)
                trimmedString = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString - readMoreText.characters.count, length: ((self.text?.characters.count)! - lengthForVisibleString + readMoreText.characters.count + 5)), with: "")
                let answerAttributed = NSMutableAttributedString(string: trimmedString!, attributes: [NSFontAttributeName: self.font])
                answerAttributed.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, answerAttributed.length))
                self.attributedText = answerAttributed
            #else
                trimmedString = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString - readMoreText.characters.count, length: ((self.text?.characters.count)! - lengthForVisibleString + readMoreText.characters.count)), with: "")
            #endif
        }
        else {
            #if os(tvOS)
                trimmedString = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.characters.count)! - lengthForVisibleString)), with: "")
            #else
                trimmedString = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: ((self.text?.characters.count)! - lengthForVisibleString)), with: "")
            #endif
            
        }
        
        if trimmedString != self.text! {
            let readMoreLength: Int
            #if os(tvOS)
                readMoreLength  = (readMoreText.characters.count) + 10
            #else
                readMoreLength  = (readMoreText.characters.count)
            #endif
            let trimmedForReadMore: String = (trimmedString! as NSString).replacingCharacters(in: NSRange(location: ((trimmedString?.characters.count ?? 0) - readMoreLength), length: readMoreLength), with: "") + trailingText
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSFontAttributeName: self.font])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSFontAttributeName: moreTextFont, NSForegroundColorAttributeName: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            #if os(tvOS)
            answerAttributed.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, answerAttributed.length))
                #endif
            self.attributedText = answerAttributed
            
            isStringTrimmed = true
        } else {
            
            #if os(tvOS)
            let answerAttributed = NSMutableAttributedString(string: trimmedString!, attributes: [NSFontAttributeName: self.font])
            answerAttributed.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, answerAttributed.length))
            self.attributedText = answerAttributed
            #endif
        }
        
        return isStringTrimmed
    }
    
    func vissibleTextLength() -> Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let attributes: [AnyHashable: Any] = [NSFontAttributeName: font]
        
         let paragraphStyle = NSMutableParagraphStyle()
        
        
        let attributedText = NSMutableAttributedString(string: self.text!, attributes: attributes as? [String : Any])
        #if os(tvOS)
            paragraphStyle.lineSpacing = 7
            paragraphStyle.minimumLineHeight = 36
            paragraphStyle.maximumLineHeight = 36
            attributedText.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedText.length))
        #endif
        
        let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
        
        if boundingRect.size.height > labelHeight {
            var index: Int = 0
            var prev: Int = 0
            let characterSet = CharacterSet.whitespacesAndNewlines
            repeat {
                prev = index
                if mode == NSLineBreakMode.byCharWrapping {
                    index += 1
                } else {
                    index = (self.text! as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: self.text!.characters.count - index - 1)).location
                }
            } while index != NSNotFound && index < self.text!.characters.count && (self.text! as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [String : Any], context: nil).size.height <= labelHeight
            return prev
        }
        return self.text!.characters.count
    }
    
    #if os(tvOS)
    
    func updateSubTextColorOnFocus (_ subText: String,_ color: UIColor) {
        let range = (self.text! as NSString).range(of: subText)
        
        if range.length > 0 && range.length <= (self.text?.characters.count)! {
            let attributedString = NSMutableAttributedString(attributedString: self.attributedText!)
            attributedString.addAttribute(NSForegroundColorAttributeName, value: color , range: range)

            let paragraphStyle = NSMutableParagraphStyle()
            //line height size
//            paragraphStyle.lineSpacing = 7
            paragraphStyle.minimumLineHeight = 36
            paragraphStyle.maximumLineHeight = 36
            attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.attributedText = attributedString
        }
    }
    
    #endif
}
