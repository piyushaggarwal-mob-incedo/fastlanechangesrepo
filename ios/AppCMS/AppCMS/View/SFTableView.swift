//
//  SFTableView.swift
//  AppCMS
//
//  Created by Gaurav Vig on 22/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFTableView: UITableView {
    
    var tableObject:SFTableViewObject?
    var relativeViewFrame:CGRect?
    var tableLayout:LayoutObject?
    
    func initialiseTableViewFrameFromLayout(tableViewLayout:LayoutObject) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: tableViewLayout, relativeViewFrame: relativeViewFrame!)
    }
    
    func updateTableView() {
        
        #if os(iOS)
            self.separatorStyle = .none
        #endif
        self.backgroundView = nil
        self.backgroundColor = UIColor.clear
        self.showsVerticalScrollIndicator = false
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
