//
//  SFHeaderView.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFHeaderView: UIView {

    var headerViewObject:SFHeaderViewObject?
    var headerViewlayout:LayoutObject?
    var relativeViewFrame:CGRect?
    var film: SFFilm!
    var show: SFShow!
    
    func initialiseHeaderViewFrameFromLayout(headerViewlayout:LayoutObject) {
        self.headerViewlayout = headerViewlayout
        self.frame = Utility.initialiseViewLayout(viewLayout: headerViewlayout, relativeViewFrame: relativeViewFrame!)
        self.backgroundColor = Utility.hexStringToUIColor(hex: "24282b")
    }
    
    func updateViewWithFilmObject (_ film: SFFilm) {
        self.backgroundColor = UIColor.clear
        self.film = film
        for components in (headerViewObject?.components)! {
            
            if components is SFLabelObject {
                
                createLabelView(labelObject: components as! SFLabelObject)
            }
        }
    }
    
    
    func updateViewWithShowObject (_ film: SFShow) {
        self.backgroundColor = Utility.hexStringToUIColor(hex: "24282b")
        self.show = film
        for components in (headerViewObject?.components)! {
            
            if components is SFLabelObject {
                
                createLabelViewForShow(labelObject: components as! SFLabelObject)
            }
        }
    }
    
    
    private func createLabelView (labelObject: SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label = SFLabel()
        label.isHidden = false
        label.relativeViewFrame = self.frame
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)

        if labelObject.key != nil && labelObject.key == "videoTitle" {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            label.text = film.title ?? ""
        }
        else if labelObject.key != nil && labelObject.key == "videoSubTitle" {
            label.text = self.film.getVideoInfoString()
        }
        label.createLabelView()
        self.addSubview(label)
    }
    
    private func createLabelViewForShow (labelObject: SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label = SFLabel()
        label.isHidden = false
        label.relativeViewFrame = self.frame
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if labelObject.key != nil && labelObject.key == "showTitle" {
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            label.text = show.showTitle ?? ""
        }
        else if labelObject.key != nil && labelObject.key == "showSubTitle" {
            label.text = self.show.getShowInfoString()
        }
        label.createLabelView()
        self.addSubview(label)
    }
    
}
