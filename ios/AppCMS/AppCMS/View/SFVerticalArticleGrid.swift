//
//  SFVerticalArticleGrid.swift
//  AppCMS
//
//  Created by Gaurav Vig on 26/01/18.
//  Copyright © 2018 Viewlift. All rights reserved.
//

import UIKit

enum ImageFetchType {
    case VideoImage
    case BadgeImage
}

class SFVerticalArticleGrid: UICollectionViewCell {
    
    var gridComponents:Array<Any> = []
    var articleImage:SFImageView?
    var badgeImage:SFImageView?
    var articleMetadataView:SFVerticalArticleMetadataView?
    var thumbnailImageType:String?
    var relativeViewFrame:CGRect?
    var cellRowValue:Int = 0
    var gridObject:SFGridObject?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Method to create subview
    private func createCellView() {
        
        articleImage = SFImageView()
        self.addSubview(articleImage!)
        articleImage?.isHidden = true
        articleImage?.isUserInteractionEnabled = false
        
        badgeImage = SFImageView()
        self.addSubview(badgeImage!)
        badgeImage?.isHidden = true
        badgeImage?.isUserInteractionEnabled = false
        
        articleMetadataView = SFVerticalArticleMetadataView()
        articleMetadataView?.isHidden = true
        self.addSubview(articleMetadataView!)
        articleMetadataView?.isUserInteractionEnabled = false
    }
    
    
    //MARK: Update Cell components
    //Reusing it in tableview cell to update cell contents
    func updateGridSubviews() {
        
        for cellComponent in gridComponents {
            
            if cellComponent is SFImageObject {
                
                createImageView(imageObject: cellComponent as! SFImageObject)
            }
            else if cellComponent is SFVerticalArticleMetadataObject {
                
                createMetadataView(metadataViewObject: cellComponent as! SFVerticalArticleMetadataObject)
            }
        }
    }
    
    //MARK: Method to create image view
    private func createImageView(imageObject:SFImageObject) {
        
        if imageObject.key != nil && imageObject.key == "thumbnailImage" {
            
            articleImage?.isHidden = false
            articleImage?.relativeViewFrame = relativeViewFrame
            articleImage?.imageViewObject = imageObject
            articleImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            
            var imageURL:String? = self.getImageUrlFromArryy(imageFetchType: .VideoImage)
            var placeholderImagePath:String?
            
            if imageURL == nil {
                
                imageURL = gridObject?.thumbnailImageURL
            }
            
            placeholderImagePath = Constants.kVideoImagePlaceholder
            
            if imageURL != nil {
                
                articleImage?.contentMode = .scaleAspectFit
                imageURL = imageURL?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: articleImage?.frame.size.width ?? 0))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: articleImage?.frame.size.height ?? 0))")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil {
                    
                    if let imageUrl = URL(string: imageURL!) {
                        
                        articleImage?.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: UIImage(named: placeholderImagePath!),
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                    else {
                        
                        articleImage?.contentMode = .scaleToFill
                        articleImage?.image = UIImage(named: placeholderImagePath!)
                    }
                }
                else {
                    
                    articleImage?.contentMode = .scaleToFill
                    articleImage?.image = UIImage(named: placeholderImagePath!)
                }
            }
            else {
                
                articleImage?.contentMode = .scaleToFill
                articleImage?.image = UIImage(named: placeholderImagePath!)
            }
        }
        else if imageObject.key != nil && imageObject.key == "badgeImage" {
            
            badgeImage?.isHidden = false
            badgeImage?.imageViewObject = imageObject
            badgeImage?.relativeViewFrame = relativeViewFrame
            badgeImage?.initialiseImageViewFrameFromLayout(imageLayout: Utility.fetchImageLayoutDetails(imageObject: imageObject))
            badgeImage?.updateView()
            
            var imageURL:String? = self.getImageUrlFromArryy(imageFetchType: .BadgeImage)
            if imageURL != nil {
                
                imageURL = imageURL?.appending("?impolicy=resize&w=\(badgeImage?.frame.size.width ?? 0)&h=\(badgeImage?.frame.size.height ?? 0)")
                imageURL = imageURL?.trimmingCharacters(in: .whitespaces)
                
                if imageURL != nil && !(imageURL?.isEmpty)! {
                    
                    if let imageUrl = URL(string: imageURL!) {
                        
                        badgeImage?.isHidden = false
                        badgeImage?.af_setImage(
                            withURL: imageUrl,
                            placeholderImage: nil,
                            filter: nil,
                            imageTransition: .crossDissolve(0.2)
                        )
                    }
                }
                else {
                    
                    badgeImage?.isHidden = true
                }
            }
        }
    }
    
    //MARK: Method to get image url from images array
    private func getImageUrlFromArryy(imageFetchType:ImageFetchType) -> String? {
    
        var imageUrl:String?
        
        if self.gridObject != nil {
            
            for image in (self.gridObject?.images)! {
                
                let imageObj: SFImage = image as! SFImage
                
                if imageObj.imageType == Constants.kSTRING_IMAGETYPE_VIDEO || imageObj.imageType == Constants.kSTRING_IMAGETYPE_WIDGET {
                    
                    if imageFetchType == .BadgeImage {
                        
                        imageUrl = imageObj.badgeImageUrl
                    }
                    else if imageFetchType == .VideoImage {
                        
                        imageUrl = imageObj.imageSource
                    }
                    break
                }
            }
        }
        
        return imageUrl
    }
    
    //MARK: Method to create article metadata view
    private func createMetadataView(metadataViewObject:SFVerticalArticleMetadataObject) {
        
        articleMetadataView?.isHidden = false
        articleMetadataView?.isUserInteractionEnabled = true
        articleMetadataView?.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchArticleMetadataViewLayoutDetails(articleMetadataObject: metadataViewObject), relativeViewFrame: relativeViewFrame!)
        articleMetadataView?.components = metadataViewObject.components
        articleMetadataView?.gridObject = gridObject
        articleMetadataView?.updateSubViews()
    }
}
