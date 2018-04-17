//
//  ModulesUIBlocks.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 04/10/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModulesUIBlocks: NSObject {
    var moduleUIUrl: String?
    var moduleUIVersion: String?
    var isModuleUIUpdated: Bool?
    var pageUIBlock: PageUIBlocks = PageUIBlocks.sharedInstance
}
