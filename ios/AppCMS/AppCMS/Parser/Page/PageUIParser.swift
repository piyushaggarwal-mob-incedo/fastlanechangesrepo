//
//  PageUIParser.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 09/03/17.
//
//

import Foundation

class PageUIParser: NSObject {
    
    //MARK: Method to create singeleton class object
    static let sharedInstance:PageUIParser = {
        
        let instance = PageUIParser()
        
        return instance
    }()
    
    func parsePageConfigurationJson(pageConfigDictionary: Dictionary<String, AnyObject>) -> Page
    {
        
        let pageTypeString: String? = pageConfigDictionary["type"] as? String
        
        let page = Page(pageString: pageTypeString != nil ? pageTypeString! : "")
        page.pageId = pageConfigDictionary["id"] as? String
        page.pageName = pageConfigDictionary["title"] as? String
        page.pageAPI = pageConfigDictionary["apiURL"] as? String
        
        if let cacheDictionary = pageConfigDictionary["caching"] as? Dictionary<String, AnyObject> {
            
            if let isCaching = cacheDictionary["isEnabled"] as? Bool {
                
                page.shouldUseCacheAPI = isCaching
            }
        }
        
        let moduleParser = ModuleUIParser()
        
        let pageModulesArray:Array<Dictionary<String, Any>>? = pageConfigDictionary["moduleList"] as? Array<Dictionary<String, Any>>
        
        if pageModulesArray != nil {
            
            page.modules = moduleParser.parseModuleConfigurationJson(modulesConfigurationArray: pageModulesArray!)
        }
        
        return page
    }    
}
