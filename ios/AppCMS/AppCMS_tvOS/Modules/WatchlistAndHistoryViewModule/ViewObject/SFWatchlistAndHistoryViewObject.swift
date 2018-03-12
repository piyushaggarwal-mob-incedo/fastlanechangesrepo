//
//  SFWatchlistAndHistoryViewObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 10/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit


enum ContentPageType {
    case watchlist
    case history
}

class SFWatchlistAndHistoryViewObject: NSObject {
    
    var layoutObjectDict:Dictionary <String,LayoutObject> = [:]
    var components:Array<AnyObject> = []
    var moduleType: String?
    var moduleTitle: String?
    var moduleID: String?
    var contentPageType: ContentPageType?
}
