//
//  ModuleViewModel_RawTextViewHandler.swift
//  AppCMS
//
//  Created by Rajni Pathak on 19/12/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_RawTextViewHandler: ModuleViewModel {
    
    deinit {
        ///release any strong refrence object or observers
    }
    
   
    func getRawTextView(parentViewFrame:CGRect, pageModuleObject: SFModuleObject, rawTextObject: SFRawTextViewObject) -> SFRawTextView {
        
        let moduleHeight = CGFloat(Utility.fetchRawTextViewLayoutDetails(RawTextViewObject: rawTextObject).height ?? 880)
        let moduleWidth = CGFloat(Utility.fetchRawTextViewLayoutDetails(RawTextViewObject: rawTextObject).width ?? 1920)
        let contactUsView  = SFRawTextView.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), rawTextObject: rawTextObject, pageModuleObject: pageModuleObject)
        return contactUsView
    }
}
