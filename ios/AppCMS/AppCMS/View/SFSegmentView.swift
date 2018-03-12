//
//  SFSegmentView.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 26/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFSegmentViewDelegate: NSObjectProtocol {
    @objc func segmentSelectionChangedWith(selectedSection: Int) -> Void
}


class SFSegmentView: UIView {
    var segmentObject: SFSegmentObject?
    var selectedIndex: Int?
    weak var segmentDelegate: SFSegmentViewDelegate?
    
    init(segmentComponentObject: SFSegmentObject) {
        let segmentLayout = Utility.fetchSegmentViewLayoutDetails(segmentViewObject: segmentComponentObject)
        super.init(frame: CGRect.init(x: CGFloat(segmentLayout.xAxis!), y: CGFloat(segmentLayout.yAxis!), width: CGFloat(segmentLayout.width!), height: CGFloat(segmentLayout.height!)))
        self.segmentObject = segmentComponentObject
        self.selectedIndex = segmentComponentObject.selectedIndex
        createSegmentView()
    }
    
    func initialiseSegmentFrameFromLayout(segmentViewLayout:LayoutObject, relativeViewFrame: CGRect) {
        
        self.frame = Utility.initialiseViewLayout(viewLayout: segmentViewLayout, relativeViewFrame: relativeViewFrame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSegmentView() -> Void
    {
        var ii: Int = 0
        for component:AnyObject in (self.segmentObject?.components)! {
            
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject, containerView: self, index: ii)
                ii = ii + 1
            }
        }
    }
    
    func updateSegmentView() -> Void
    {
        for component: AnyObject in self.subviews {
            
            if component is SFLabel {
                
                updateLabelViewFrame(label: component as! SFLabel, containerView: self)
            }
        }
    }
    
    func createLabelView(labelObject:SFLabelObject, containerView:UIView, index: Int) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        label.createLabelView()
        
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        label.font = UIFont(name: label.font.fontName, size: label.font.pointSize * Utility.getBaseScreenHeightMultiplier())
        label.text = labelObject.text

        if index == self.selectedIndex {
            if labelObject.underline != nil && (labelObject.underline)! {
                
                let line = CAShapeLayer()
                let linePath = UIBezierPath()
                linePath.move( to: CGPoint.init(x: (label.frame.width - label.intrinsicContentSize.width)/2 - 2, y: (label.frame.maxY - CGFloat(labelObject.underlineWidth!))))
                linePath.addLine(to: CGPoint.init(x: label.intrinsicContentSize.width + (label.frame.width - label.intrinsicContentSize.width)/2 + 2, y: (label.frame.maxY - CGFloat(labelObject.underlineWidth!))))
                line.path = linePath.cgPath
                
                line.strokeColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? labelObject.underlineColor ?? "ffffff").cgColor
                line.lineWidth =  CGFloat(labelObject.underlineWidth!)
                line.lineJoin = kCALineJoinRound
                label.layer.addSublayer(line)
            }
        }
        else
        {
            let selectorTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.segmentLabelTapGestureRecongniser(tapGesture:)))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(selectorTapGesture)
        }
        
        
        self.addSubview(label)
    }
    
    func updateLabelViewFrame(label:SFLabel, containerView:UIView) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!)
        label.labelLayout = labelLayout
        label.relativeViewFrame = containerView.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.changeFrameXAxis(xAxis: label.frame.minX * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameYAxis(yAxis: label.frame.minY * Utility.getBaseScreenHeightMultiplier())
        label.changeFrameWidth(width: label.frame.width * Utility.getBaseScreenWidthMultiplier())
        label.changeFrameHeight(height: label.frame.height * Utility.getBaseScreenHeightMultiplier())
        
    }
    
    func segmentLabelTapGestureRecongniser(tapGesture: UITapGestureRecognizer) -> Void {
        var selectionIndex: Int = 0
        if self.selectedIndex == 0 {
            selectionIndex = 1
        }
        if self.segmentDelegate != nil && (self.segmentDelegate?.responds(to: #selector(self.segmentDelegate?.segmentSelectionChangedWith(selectedSection:))))! {
            self.segmentDelegate?.segmentSelectionChangedWith(selectedSection: selectedIndex!)
        }
    }
    
}
