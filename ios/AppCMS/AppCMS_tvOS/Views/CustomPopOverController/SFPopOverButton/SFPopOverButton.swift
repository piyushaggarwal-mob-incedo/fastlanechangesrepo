//
//  SFPopOverButton.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
class SFPopOverButton: SFButton {
    
    var popOverButtonObject: SFPopOverButtonObject?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func createButtonView() -> Void {
        self.buttonObject = popOverButtonObject
        super.createButtonView()
    }
    
    #if os(tvOS)
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if self.isFocused {
            updateViewForFocusedState()
        } else {
            updateViewForUnFocusedState()
        }
    }
    
    override func updateViewForFocusedState() {
        super.updateViewForFocusedState()
    }
    
    override func updateViewForUnFocusedState() {
        super.updateViewForUnFocusedState()
    }
    
    #endif

}
