//
//  SFCastView.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 30/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class SFCastView: UILabel {
    
    var castViewText:String?
    var castViewObject:SFCastViewObject?
    var castViewLayout:LayoutObject?
    var relativeViewFrame:CGRect?
    
    func initialiseCastViewFrameFromLayout(castViewLayout:LayoutObject) {
        self.castViewLayout = castViewLayout
        self.frame = Utility.initialiseViewLayout(viewLayout: castViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    
    func updateView() {
        
        self.backgroundColor = castViewObject?.backgroundColor != nil ? Utility.hexStringToUIColor(hex: (castViewObject?.textColor)!) : UIColor.clear

        self.textColor = Utility.hexStringToUIColor(hex: (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
        
        if castViewObject?.textAlignment == "center" {
            self.textAlignment = .center
        }
        else if castViewObject?.textAlignment == "left" {
            self.textAlignment = .left
        }
        else if castViewObject?.textAlignment == "right" {
            self.textAlignment = .right
        }
        else {
            self.textAlignment = .natural
        }
//        self.lineBreakMode = .
        self.numberOfLines = 0
        //added to remove the padding within the textview text container
    }
    
    func setCreditsText(creditsSet: NSSet) -> Void {
        self.attributedText = generateAttributedStringForCreditsSet(creditsSet: creditsSet)
    }
    
    
    func generateAttributedStringForCreditsSet(creditsSet: NSSet) -> NSAttributedString {
        let creditsAttributedString: NSMutableAttributedString = NSMutableAttributedString.init()
        for credit in creditsSet
        {
            let localCredit: SFCreditObject = credit as! SFCreditObject
            
            let attributedCreditTitleDict = [NSFontAttributeName: UIFont(name: (castViewObject?.fontFamilyKey) ?? "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: CGFloat((castViewLayout?.fontSizeKey) ?? 14.0) * Utility.getBaseScreenHeightMultiplier())! , NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))]
            let attrStringTitle: NSAttributedString = NSAttributedString(string: localCredit.creditTitle, attributes: attributedCreditTitleDict)
            
            var creditSubString: String = String()
            if localCredit.credits != nil {
                
                var ii = 1
                for creditSubStr in localCredit.credits! {
                    creditSubString.append(creditSubStr as! String)
                    if ii == 3
                    {
                        break
                    }
                    if ii < (localCredit.credits?.count)! {
                        creditSubString.append(", ")
                    }
                    ii = ii+1
                }
            }
            
            let attributedSubCreditsDictionary = [NSFontAttributeName: UIFont(name: castViewObject?.fontFamilyValue ?? "\(Utility.sharedUtility.fontFamilyForApplication())", size: CGFloat(castViewLayout?.fontSizeValue ?? 13.0) * Utility.getBaseScreenHeightMultiplier())! , NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))]
            let attrSubString: NSAttributedString = NSAttributedString(string: "\t" + creditSubString + "\n", attributes: attributedSubCreditsDictionary)
         
            creditsAttributedString.append(attrStringTitle)
            creditsAttributedString.append(attrSubString)
        }
        return creditsAttributedString
    }
    
    func createSegregatedCastViewWithCastSet_iOS(_ creditsSet: NSSet) {
        var previousHeight : CGFloat = 0.0
        var arrayOfCredits = creditsSet.allObjects
        //Sorting it alphabetically.
        arrayOfCredits = arrayOfCredits.sorted(by: { ($0 as! SFCreditObject).creditTitle < ($1 as! SFCreditObject).creditTitle })
        
        for subView in self.subviews {
            
            subView.removeFromSuperview()
        }
        
        var ii = 0
        while ii < arrayOfCredits.count {
            let credit = arrayOfCredits[ii]
            let localCredit: SFCreditObject = credit as! SFCreditObject
            if localCredit.credits != nil {
                
                //Adding titleLabel.
                let titleLabel = UILabel()
                titleLabel.font = UIFont(name: (castViewObject?.fontFamilyKey) ?? "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: CGFloat((castViewLayout?.fontSizeKey) ?? 14.0) * Utility.getBaseScreenHeightMultiplier())!
                titleLabel.textColor = Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
                
                titleLabel.numberOfLines = 1
                titleLabel.text = localCredit.creditTitle
                if previousHeight != 0 {
                    previousHeight = previousHeight + 5 /*Padding*/
                }
                titleLabel.frame = CGRect(x: 0, y: previousHeight, width: 75 * Utility.getBaseScreenHeightMultiplier(), height: titleLabel.font.pointSize)
                
                var subTitleString = String()
                var jj = 0
                while jj < (localCredit.credits?.count)! {
                    
                    let creditSubStr = localCredit.credits?[jj]
                    subTitleString.append((creditSubStr as! String))
                    if jj < (localCredit.credits?.count)! - 1 {
                        subTitleString.append(", ")
                    }
                    jj = jj + 1
                }
                //Adding subTitleLabel.
                let subTitleLabel = UILabel()
                subTitleLabel.numberOfLines = 0
                subTitleLabel.font = UIFont(name: castViewObject?.fontFamilyValue ?? "\(Utility.sharedUtility.fontFamilyForApplication())", size: CGFloat(castViewLayout?.fontSizeValue ?? 13.0) * Utility.getBaseScreenHeightMultiplier())!
                subTitleLabel.textColor = Utility.hexStringToUIColor(hex: castViewObject?.textColor ?? (AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff"))
                
                if subTitleString.characters.count > 0 {
                    subTitleLabel.text = subTitleString
                }
                subTitleLabel.frame = CGRect(x: titleLabel.bounds.size.width + 8.0, y: previousHeight, width: self.bounds.size.width -  (titleLabel.bounds.size.width + 8.0), height: subTitleLabel.font.pointSize)
                
                var maxNoOfLines:CGFloat = 2
                #if os(iOS)
                if !Constants.IPHONE {
                    
                    if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                        
                        maxNoOfLines = 4
                    }
                }
                #endif
                //Setting height for the subTitleLabel.
                let size = sizeForLabel_iOS(label: subTitleLabel, maxWidth: (self.bounds.size.width -  (titleLabel.bounds.size.width + 8.0)))
                let numberOfLines = floor(size.height / subTitleLabel.font.pointSize) > maxNoOfLines ? maxNoOfLines : floor(size.height / subTitleLabel.font.pointSize)
                subTitleLabel.changeFrameHeight(height: CGFloat(subTitleLabel.font.pointSize * numberOfLines))
                previousHeight = subTitleLabel.bounds.size.height
                subTitleLabel.numberOfLines = Int(numberOfLines)
//                subTitleLabel.lineBreakMode = .byCharWrapping
                
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
    
    func sizeForLabel_iOS(label: UILabel, maxWidth: CGFloat) -> CGSize {
        let labelSize: CGSize = label.text!.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont(name: castViewObject?.fontFamilyValue ?? "\(Utility.sharedUtility.fontFamilyForApplication())", size: CGFloat(castViewLayout?.fontSizeValue ?? 13.0))!], context: nil).size
        return labelSize
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
