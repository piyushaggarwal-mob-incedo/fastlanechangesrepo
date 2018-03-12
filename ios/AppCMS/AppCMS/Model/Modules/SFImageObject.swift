//
//  SFImageObject.swift
//  SwiftPOCConfiguration
//
//  Created by Gaurav Vig on 14/03/17.
//
//

import UIKit

class SFImageObject: NSObject {

    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var action:String?
    var type:String?
    var key:String?
    var imageName:String?
    var isVisibleForiPhone:Bool?
    var isVisibleForiPad:Bool?
    var backgroundColor:String?
    var alpha: Float?
    var autoHide: Bool?
    var autoHideDuration: Float?
}
