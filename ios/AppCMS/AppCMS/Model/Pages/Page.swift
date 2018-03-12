//
//  Page.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 09/03/17.
//
//

import Foundation

class Page: NSObject {
    
    enum pageType
    {
        case `default`
        case webPage
        case nativePage
        case modularPage
        case welcomePage
        case downloadPage
    }
    
    var isPageNavItem: Bool
    var menuPosition: Int
    var pageAPI: String?
    var pageId: String?
    var pageUI: String?
    var modules: Array<Any>
    var pageName: String?
    var pageTypeValue:pageType
    var pageVersion: String?
    var isPageOnTab: Bool?
    var isPageOnMenu: Bool?
    var pageJsonData: Data?
    var isPageUpdated: Bool?
    var shouldUseCacheAPI: Bool = false
    
    init(pageString: String)
    {
        isPageNavItem = false
        menuPosition = 0
        modules = []
        
        switch Utility.getCurrentTypeValue(pageTypeName: pageString) {
        case 0:
            pageTypeValue = pageType.default
        case 1:
            pageTypeValue = pageType.webPage
        case 2:
            pageTypeValue = pageType.nativePage
        case 3:
            pageTypeValue = pageType.modularPage
        case 4:
            pageTypeValue = pageType.welcomePage
        case 5:
            pageTypeValue = pageType.downloadPage
        default:
            pageTypeValue = pageType.default
        }
        
    }
    
    
    func getPageType() -> String {
        
        var pageTypeString: String
        switch  pageTypeValue{
        case .default:
            pageTypeString  = Constants.kSTRING_PAGETYPE_DEFAULT
        case .webPage:
            pageTypeString  = Constants.kSTRING_PAGETYPE_WEBPAGE
        case .nativePage:
            pageTypeString  = Constants.kSTRING_PAGETYPE_NATIVE
        case .modularPage:
            pageTypeString  = Constants.kSTRING_PAGETYPE_MODULAR
        case.welcomePage:
            pageTypeString  = Constants.kSTRING_PAGETYPE_WELCOME
        case.downloadPage:
            pageTypeString  = Constants.kSTRING_PAGETYPE_DOWNLOAD
        }
    

        return pageTypeString
    }
    
}
