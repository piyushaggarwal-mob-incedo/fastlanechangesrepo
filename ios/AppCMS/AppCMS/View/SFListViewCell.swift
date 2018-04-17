//
//  SFListViewCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 13/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFListViewCell: UICollectionViewCell {
    
    var listViewImage:SFImageView?
    var listViewTitle:SFLabel?
    var navItem:NavigationItem?
    var cellComponents:Array<Any> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: method to create cell view
    private func createCellView() {
        
        listViewTitle = SFLabel()
        self.addSubview(listViewTitle!)
        listViewTitle?.isHidden = true
        
        listViewImage = SFImageView()
        self.addSubview(listViewImage!)
        listViewImage?.isHidden = true
    }

    
    //MARK: Update Cell components
    //Reusing it in collectionview cell to update cell contents
    func updateCellSubView() {
        
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFImageObject {
                
                updateImageView(imageViewObject: cellComponent as! SFImageObject)
            }
        }
    }
    
    
    //MARK: Update label view
    private func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        if labelObject.key != nil && labelObject.key == "listTitle" {
            
            listViewTitle?.isHidden = false
            listViewTitle?.relativeViewFrame = self.frame
            listViewTitle?.labelObject = labelObject
            listViewTitle?.text = navItem?.title ?? ""
            listViewTitle?.labelLayout = labelLayout
            listViewTitle?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            listViewTitle?.createLabelView()
            
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                listViewTitle?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
            
            listViewTitle?.font = UIFont(name: (listViewTitle?.font.fontName)!, size: (listViewTitle?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
        }
    }
    
    //MARK: Update Image view
    private func updateImageView(imageViewObject:SFImageObject) {
        
        let imageViewLayout = Utility.fetchImageLayoutDetails(imageObject: imageViewObject)
        
        if imageViewObject.key != nil && imageViewObject.key == "listImage" {
            
            listViewImage?.isHidden = false
            listViewImage?.relativeViewFrame = self.frame
            listViewImage?.imageViewObject = imageViewObject
            listViewImage?.initialiseImageViewFrameFromLayout(imageLayout: imageViewLayout)
            listViewImage?.updateView()
            
            if var listImageString = self.navItem?.pageIcon {
                
                listImageString = listImageString.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: (listViewImage?.frame.size.width)!))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: (listViewImage?.frame.size.height)!))")

                if let imageURL = URL(string: listImageString) {
                
                    listViewImage?.af_setImage(
                        withURL: imageURL,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
            }
        }
    }
}
