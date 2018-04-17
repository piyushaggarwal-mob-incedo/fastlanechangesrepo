//
//  SFCastView_tvOS.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 18/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFCastView_tvOS: SFCastView {
    
    func createSegregatedCastViewWithCastSet(_ creditsSet: NSSet) {
        var previousHeight : CGFloat = 0.0
        var arrayOfCredits = creditsSet.allObjects
        //Sorting it alphabetically.
        arrayOfCredits = arrayOfCredits.sorted(by: { ($0 as! SFCreditObject).creditTitle < ($1 as! SFCreditObject).creditTitle })
        
        var ii = 0
        while ii < arrayOfCredits.count {
            let credit = arrayOfCredits[ii]
            let localCredit: SFCreditObject = credit as! SFCreditObject
            if localCredit.credits != nil {
                
                //Adding titleLabel.
                let titleLabel = UILabel()
                titleLabel.font = UIFont(name: (castViewObject?.fontFamilyKey) ?? "OpenSans-Bold", size: CGFloat((castViewLayout?.fontSizeKey) ?? 14.0))!
                titleLabel.textColor = Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
                
                titleLabel.numberOfLines = 1
                titleLabel.text = localCredit.creditTitle
                if previousHeight != 0 {
                    previousHeight = previousHeight + 15 /*Padding*/
                }
                titleLabel.frame = CGRect(x: 0, y: previousHeight, width: 130, height: titleLabel.font.pointSize)
                
                //Getting subTitleLabel Data.
                //            var subTitleString = "lakhjfalffj  kjk klaj j flkajs fksjfksdjfk jkjk kfj klfj  lkfja fj kjfkls j"
                var subTitleString = String()
                var jj = 0
                while jj < (localCredit.credits?.count)! {
                    
                    let creditSubStr = localCredit.credits?[jj]
                    subTitleString.append((creditSubStr as! String))
                    if jj == (localCredit.credits?.count)! - 2 {
                        subTitleString.append(" & ")
                    } else if jj == (localCredit.credits?.count)! - 1 {
                        subTitleString.append("")
                    } else {
                        subTitleString.append(", ")
                    }
                    jj = jj + 1
                }
                //Adding subTitleLabel.
                let subTitleLabel = UILabel()
                subTitleLabel.numberOfLines = 0
                subTitleLabel.font = UIFont(name: castViewObject?.fontFamilyValue ?? "OpenSans", size: CGFloat(castViewLayout?.fontSizeValue ?? 13.0))!
                subTitleLabel.textColor = Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
                if subTitleString.characters.count > 0 {
                    subTitleLabel.text = subTitleString.uppercased()
                }
                subTitleLabel.frame = CGRect(x: titleLabel.bounds.size.width + 33.0, y: previousHeight, width: self.bounds.size.width -  (titleLabel.bounds.size.width + 33.0), height: subTitleLabel.font.pointSize)
                
                //Setting height for the subTitleLabel.
                let size = sizeForLabel(label: subTitleLabel, maxWidth: (self.bounds.size.width -  (titleLabel.bounds.size.width + 33)))
                let numberOfLines = floor(size.height / subTitleLabel.font.pointSize) > 4 ? 4 : floor(size.height / subTitleLabel.font.pointSize)
                subTitleLabel.changeFrameHeight(height: CGFloat(subTitleLabel.font.pointSize * numberOfLines))
                previousHeight = subTitleLabel.bounds.size.height
                subTitleLabel.numberOfLines = Int(numberOfLines)
                
                // - Setting height for the subTitleLabel.
                
                //Adding subviews.
                if (localCredit.credits?.count)! > 0 {
                    self.addSubview(titleLabel)
                }
                self.addSubview(subTitleLabel)
                titleLabel.sizeToFit()
                subTitleLabel.sizeToFit()
            }
            ii = ii + 1
            // - Adding subviews.
        }
    }
    
    func sizeForLabel(label: UILabel, maxWidth: CGFloat) -> CGSize {
        let labelSize: CGSize = label.text!.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: castViewObject?.fontFamilyValue ?? "OpenSans", size: CGFloat(castViewLayout?.fontSizeValue ?? 13.0))!], context: nil).size
        return labelSize
    }
}
