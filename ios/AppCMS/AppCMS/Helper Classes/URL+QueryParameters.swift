//
//  URL+QueryParameters.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 28/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

extension URL {
    func valueOf(queryParamaterName: String) -> String? {
        
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
