//
//  SFTopHeadLineView.swift
//  AppCMS
//
//  Created by Rajni Pathak on 19/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import Foundation
class SFTopHeadLineView: UIView {
    
    var topHeadLineViewObject:SFTopHeadLineViewObject?
    
    //MARK: Method to create sub views
    func createSubView() {
        
        if topHeadLineViewObject != nil {
            
            if topHeadLineViewObject?.topHeadlineViewComponents != nil {
                
                for component in (topHeadLineViewObject?.topHeadlineViewComponents)! {
                    
                    if component is SFLabelObject {
                        
                        createLabelView(labelObject: component as! SFLabelObject)
                    }
                    else if component is SFTableViewObject {
                        
                        createTableView(tableViewObject: component as! SFTableViewObject)
                    }
                   
                }
            }
        }
    }
    
    
    //MARK: Method to create label view
    private func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.createLabelView()
        
        if labelObject.key == "topHeadLineViewTitle" {
            
            label.text = topHeadLineViewObject?.topHeadlineTitle
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff")
        }
        
        self.addSubview(label)
}
    
    //method to create table view
    func createTableView(tableViewObject:SFTableViewObject) {
        
//        let tableViewLayout = Utility.sharedUtility.fetchTableViewLayoutDetails(tableViewObject: tableViewObject)
//        var tableView: SFTableView = SFTableView(frame: CGRect.zero, style: .plain)
//        tableView?.relativeViewFrame = relativeViewFrame!
//        tableView?.tableObject = tableViewObject
//        tableView?.tableLayout = tableViewLayout
//        tableView?.initialiseTableViewFrameFromLayout(tableViewLayout: tableViewLayout)
//        tableView?.changeFrameYAxis(yAxis: (tableView?.frame.minY)! + Utility.sharedUtility.getPosition(position: 20))
//        tableView?.dataSource = self
//        tableView?.delegate = self
//        tableView?.updateTableView()
//        tableView?.register(SFTableViewCell.self, forCellReuseIdentifier: "tableViewCustomCell")
//        self.view.addSubview(tableView!)
//        self.tableView?.isHidden = true
    }
    
}
