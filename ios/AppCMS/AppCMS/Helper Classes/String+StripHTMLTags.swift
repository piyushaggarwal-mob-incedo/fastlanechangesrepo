//
//  String+StripHTMLTags.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 17/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension String {
    
    mutating func stringByStrippingHTMLTags() -> String {
        
        self = self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        self = self.replacingOccurrences(of: "&nbsp;", with: " ", options: .regularExpression, range: nil)
        self = self.replacingOccurrences(of: "&quot;", with: "\"", options: .regularExpression, range: nil)
        self = self.replacingOccurrences(of: "&uacute;", with: "ú", options: .regularExpression, range: nil)
        return self
    }
}
