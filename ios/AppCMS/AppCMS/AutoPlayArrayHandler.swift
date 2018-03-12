//
//  AutoPlayArrayHandler.swift
//  AppCMS
//
//  Created by  Diksha Goyal on 04/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation


class AutoPlayArrayHandler: NSObject {
    
    func getTheAutoPlaybackArrayForFilm(film : String ,responseForConfiguration : @escaping (_ responseConfigData :Array<Any>?,_ film : SFFilm?) -> Void)
    {
        let apiRequest = "/content/videos?ids=\(film)&site=\(AppConfiguration.sharedAppConfiguration.sitename ?? "")"
        
        DataManger.sharedInstance.getVideoDetailById(shouldUseCacheUrl: false, apiEndPoint: apiRequest) { (dictData, filmObject) in
          
            responseForConfiguration(dictData,filmObject)
        }
    }
}
