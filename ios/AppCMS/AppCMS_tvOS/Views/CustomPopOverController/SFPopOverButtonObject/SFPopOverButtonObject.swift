//
//  SFPopOverButtonObject.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFPopOverButtonObject: SFButtonObject {

    var _popOverAction: SFPopOverAction?
    var popOverAction: SFPopOverAction? {
        set (newPopOverAction) {
            _popOverAction = newPopOverAction
            self.text = newPopOverAction?.title
        } get {
            return _popOverAction
        }
    }
}
