

import UIKit

class SFMenuViewParser: NSObject {
    
    func parseMenuModuleJson() -> SFMenuViewObject
    {
        let menuModuleObject = SFMenuViewObject()
        
            var filePath:String
            filePath = (Bundle.main.resourcePath?.appending("/MenuSportsView_AppleTV.json"))!
            if FileManager.default.fileExists(atPath: filePath){
                let jsonData:Data = FileManager.default.contents(atPath: filePath)!
                let responseJson: Dictionary<String, Any> = try! JSONSerialization.jsonObject(with:jsonData) as! Dictionary<String, AnyObject>
                let layoutDict = responseJson["layout"] as? Dictionary<String, Any>
                let componentArray = responseJson["components"] as? Array<Dictionary<String, AnyObject>>
                if componentArray != nil {
                    menuModuleObject.components = componentConfigArray(componentsArray: componentArray!)
                }
                
                let layoutObjectParser = LayoutObjectParser()
                menuModuleObject.layoutObjectDict = layoutObjectParser.parseLayoutJson(layoutDictionary: layoutDict!)
            }
        
        return menuModuleObject
    }
    
    
    func componentConfigArray(componentsArray:Array<Dictionary<String, AnyObject>>) -> Array<AnyObject> {
        
        var componentArray:Array<AnyObject> = []
        
        for moduleDictionary: Dictionary<String, AnyObject> in componentsArray {
            
            let typeOfModule: String? = moduleDictionary["type"] as? String
            if typeOfModule == "collectionGrid"
            {
                let colletionGridParser = SFCollectionGridParser()
                let collectionGridObject = colletionGridParser.parseCollectionGridJson(collectionGridDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(collectionGridObject)
            }
            else if typeOfModule == "label" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(labelObject)
            }
            else if typeOfModule == "button" {
                
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                componentArray.append(buttonObject)
            }
        }
        
        return componentArray
    }
}
