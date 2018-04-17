//
//  SFSearchResultTypeAheadCell.swift
//  AppCMS
//
//  Created by Gaurav Vig on 07/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class SFSearchResultTypeAheadCell: UITableViewCell {

    var videoTitle:UILabel?
    var videoInfo:UILabel?
    var separatorView:UIView?
    var relativeViewFrame:CGRect?
    var layoutDictVideoTitle:Dictionary<String, LayoutObject> = [:]
    var layoutDictVideoInfo:Dictionary<String, LayoutObject> = [:]
    var layoutDictSepartorView:Dictionary<String, LayoutObject> = [:]
    var tableViewLayoutDict:Dictionary<String, LayoutObject> = [:]
    var tableViewRelativeFrame:CGRect?
    var gridObject:SFGridObject?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        createCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    //MARK: Creation of cell view 
    func createCellView() {
        
        createVideoInfoDictLayout()
        createVideoTitleDictLayout()
        createSeparatorViewDictLayout()
        
        createVideoTitleView()
        createVideoInfoView()
        createSepartorView()
    }
    
    
    func createVideoTitleView() {
        
        videoTitle = UILabel(frame: .zero)
        videoTitle?.textColor = Utility.hexStringToUIColor(hex: "#4A4A4A")
        videoTitle?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", size: 14)
        videoTitle?.textAlignment = .left
        
        self.addSubview(videoTitle!)
    }
    
    func createVideoInfoView() {
        
        videoInfo = UILabel(frame: .zero)
        videoInfo?.textColor = Utility.hexStringToUIColor(hex: "#0A151C")
        videoInfo?.font = UIFont(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 10)
        videoInfo?.textAlignment = .right
        
        self.addSubview(videoInfo!)
    }
    
    func createSepartorView() {
        
        separatorView = UIView(frame: .zero)
        separatorView?.backgroundColor = Utility.hexStringToUIColor(hex: "#20495C")
        
        self.addSubview(separatorView!)
    }
    
    func updateCellView() {
        
        videoTitle?.text = gridObject?.contentTitle
        
        if let contentType = gridObject?.contentType {
            
            if contentType.lowercased() != Constants.kShowContentType.lowercased() && contentType.lowercased() != Constants.kShowsContentType.lowercased() {
                
                videoInfo?.text = gridObject?.getVideoInfoString()
            }
            else {
                
                videoInfo?.text = ""
            }
        }
        else {
            
            videoInfo?.text = gridObject?.getVideoInfoString()
        }
    }
    
    override func layoutSubviews() {
        
        let layoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: tableViewLayoutDict)

        tableViewRelativeFrame?.size.width = UIScreen.main.bounds.size.width
        relativeViewFrame?.size.width = Utility.initialiseViewLayout(viewLayout: layoutObject, relativeViewFrame: tableViewRelativeFrame!).size.width
        
        let videoTitleLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictVideoTitle)
        videoTitle?.frame = Utility.initialiseViewLayout(viewLayout: videoTitleLayoutObject, relativeViewFrame: relativeViewFrame!)
        
        let videoInfoLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictVideoInfo)
        videoInfo?.frame = Utility.initialiseViewLayout(viewLayout: videoInfoLayoutObject, relativeViewFrame: relativeViewFrame!)
        
        let separtorViewLayoutObject:LayoutObject = Utility.fetchLayoutDetailsFromDictionary(layoutObjectDict: layoutDictSepartorView)
        separatorView?.frame = Utility.initialiseViewLayout(viewLayout: separtorViewLayoutObject, relativeViewFrame: relativeViewFrame!)
    }
    
    
    //MARK:Create Layout Dict for Cell subviews
    func createVideoTitleDictLayout() {
        
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 1.97
        let rightMarginPercentiPhone:Float = 41.13
        let topMarginPercentiPhone:Float = 30
        let bottomMarginPercentiPhone:Float = 34

        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.bottomMargin = bottomMarginPercentiPhone
        
        layoutDictVideoTitle["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 1.97
        let rightMarginPercentiPadPortrait:Float = 41.13
        let topMarginPercentiPadPortrait:Float = 30
        let bottomMarginPercentiPadPortrait:Float = 34

        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.bottomMargin = bottomMarginPercentiPadPortrait
        
        layoutDictVideoTitle["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 1.97
        let rightMarginPercentiPadLandscape:Float = 41.13
        let topMarginPercentiPadLandscape:Float = 30
        let bottomMarginPercentiPadLandscape:Float = 34

        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.bottomMargin = bottomMarginPercentiPadLandscape
        
        layoutDictVideoTitle["iPadLandscape"] = layoutObject3
    }
    
    func createVideoInfoDictLayout() {
        
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let leftMarginPercentiPhone:Float = 62.54
        let rightMarginPercentiPhone:Float = 1.97
        let topMarginPercentiPhone:Float = 30
        let bottomMarginPercentiPhone:Float = 34
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.topMargin = topMarginPercentiPhone
        layoutObject1.bottomMargin = bottomMarginPercentiPhone
        
        layoutDictVideoInfo["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 62.54
        let rightMarginPercentiPadPortrait:Float = 1.97
        let topMarginPercentiPadPortrait:Float = 30
        let bottomMarginPercentiPadPortrait:Float = 34
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.topMargin = topMarginPercentiPadPortrait
        layoutObject2.bottomMargin = bottomMarginPercentiPadPortrait
        
        layoutDictVideoInfo["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 62.54
        let rightMarginPercentiPadLandscape:Float = 1.97
        let topMarginPercentiPadLandscape:Float = 30
        let bottomMarginPercentiPadLandscape:Float = 34
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.topMargin = topMarginPercentiPadLandscape
        layoutObject3.bottomMargin = bottomMarginPercentiPadLandscape
        
        layoutDictVideoInfo["iPadLandscape"] = layoutObject3
    }
    
    func createSeparatorViewDictLayout() {
        
        let layoutObject1 = LayoutObject()
        let layoutObject2 = LayoutObject()
        let layoutObject3 = LayoutObject()
        
        let height:Float = 1
        let leftMarginPercentiPhone:Float = 0
        let rightMarginPercentiPhone:Float = 0
        let bottomMarginPercentiPhone:Float = 0
        
        layoutObject1.leftMargin = leftMarginPercentiPhone
        layoutObject1.rightMargin = rightMarginPercentiPhone
        layoutObject1.height = height
        layoutObject1.bottomMargin = bottomMarginPercentiPhone
        
        layoutDictSepartorView["iPhone"] = layoutObject1
        
        let leftMarginPercentiPadPortrait:Float = 0
        let rightMarginPercentiPadPortrait:Float = 0
        let bottomMarginPercentiPadPortrait:Float = 0
        
        layoutObject2.leftMargin = leftMarginPercentiPadPortrait
        layoutObject2.rightMargin = rightMarginPercentiPadPortrait
        layoutObject2.height = height
        layoutObject2.bottomMargin = bottomMarginPercentiPadPortrait
        
        layoutDictSepartorView["iPadPortrait"] = layoutObject2
        
        let leftMarginPercentiPadLandscape:Float = 0
        let rightMarginPercentiPadLandscape:Float = 0
        let bottomMarginPercentiPadLandscape:Float = 0
        
        layoutObject3.leftMargin = leftMarginPercentiPadLandscape
        layoutObject3.rightMargin = rightMarginPercentiPadLandscape
        layoutObject3.height = height
        layoutObject3.bottomMargin = bottomMarginPercentiPadLandscape
        
        layoutDictSepartorView["iPadLandscape"] = layoutObject3
    }

}
