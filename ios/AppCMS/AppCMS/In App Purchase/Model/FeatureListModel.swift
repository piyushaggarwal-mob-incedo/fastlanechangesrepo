//
//  FeatureListModel.swift
//  AppCMS
//
//  Created by Gaurav Vig on 12/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

class FeatureListModel: NSObject {

    /*!
     * @discussion featureListImageURL property holds feature list image url.
     */
    var featureListImageURL:String?
    
    /*!
     * @discussion featureListImageURL property holds feature list title.
     */
    var featureListTitle:String?
    
    /*!
     * @discussion featureListDescription property holds feature list description.
     */
    var featureListDescription:String?
        
    override init () {
        
    }

    
    //MARK: Method to create plan features list
    func createPlanFeatureListDetails(planDetailsDict:Dictionary<String, AnyObject>) -> FeatureListModel {
        
        self.featureListTitle = planDetailsDict["title"] as? String
        self.featureListDescription = planDetailsDict["description"] as? String
        self.featureListImageURL = planDetailsDict["imageUrl"] as? String

        return self
    }
}
