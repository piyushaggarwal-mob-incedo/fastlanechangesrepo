//
//  String+HeightCalculator.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

extension String {

    func height(withConstraintWidth:CGFloat, withConstraintHeight:CGFloat?, font:UIFont) -> CGFloat {
        
        let constraintRect = CGSize(width: withConstraintWidth, height: withConstraintHeight ?? .greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
