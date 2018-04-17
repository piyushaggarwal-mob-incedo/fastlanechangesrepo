//
//  SFVerticalArticleMetadataParser.swift
//  AppCMS
//
//  Created by Gaurav Vig on 25/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

class SFVerticalArticleMetadataParser: NSObject {

    func parseVerticalArticalMetadataJson(verticalArticalMetadataDictionary: Dictionary<String, AnyObject>) -> SFVerticalArticleMetadataObject {
        
        let verticalArticleMetadata = SFVerticalArticleMetadataObject()
        
        verticalArticleMetadata.type = verticalArticalMetadataDictionary["type"] as? String
        verticalArticleMetadata.key = verticalArticalMetadataDictionary["key"] as? String
                
        if let componentArray = verticalArticalMetadataDictionary["components"] as? Array<Dictionary<String, AnyObject>> {
            
            let componentsUIParser = ComponentUIParser()
            verticalArticleMetadata.components = componentsUIParser.componentConfigArray(componentsArray: componentArray)
        }
        
        if let layoutDict = verticalArticalMetadataDictionary["layout"] as? Dictionary<String, Any>{
            let layoutObjectParser = LayoutObjectParser()
            let layoutObjectDict:Dictionary <String, LayoutObject> = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict)
            verticalArticleMetadata.layoutObjectDict = layoutObjectDict
        }
        
        return verticalArticleMetadata
    }
}
