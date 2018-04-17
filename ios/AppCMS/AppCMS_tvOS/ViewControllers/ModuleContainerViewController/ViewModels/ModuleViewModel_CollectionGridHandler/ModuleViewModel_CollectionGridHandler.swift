//
//  ModuleViewModel_CollectionGridHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_CollectionGridHandler: ModuleViewModel, CollectionGridViewDelegate {
    
    /// Method creates the collection grid view according to the inputs provided.
    ///
    /// - Parameters:
    ///   - parentViewFrame: view frames of the parent.
    ///   - pageModuleObject: module object based on which the view is getting created i.e. data.
    ///   - trayObject: tray Object for UI.
    /// - Returns: Created CollectionGridViewController.
    func getCollectionGrid(parentViewFrame:CGRect, pageModuleObject:SFModuleObject, trayObject: SFTrayObject) -> CollectionGridViewController {

        let collectionGridViewController:CollectionGridViewController = CollectionGridViewController(trayObject: trayObject)
        
        let rowHeight:CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject).height ?? 170)
        var cellFrame:CGRect = parentViewFrame
        cellFrame.size.width =  UIScreen.main.bounds.width
        cellFrame.size.height = rowHeight
        collectionGridViewController.view.frame = Utility.initialiseViewLayout(viewLayout: Utility.fetchTrayLayoutDetails(trayObject: trayObject), relativeViewFrame: cellFrame)
        collectionGridViewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: rowHeight)
        collectionGridViewController.relativeViewFrame = collectionGridViewController.view.frame
        collectionGridViewController.delegate = self
        collectionGridViewController.moduleAPIObject = pageModuleObject
        collectionGridViewController.createSubViews()
        return collectionGridViewController
    }
    
    //MARK:Collection Grid Delegates and Carousel Delegate
    func didSelectVideo(gridObject: SFGridObject?) {
        
        var viewControllerPage:Page?
        let filePath:String?
        if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Show Page") ?? "")
        } else {
            filePath = AppSandboxManager.getpageFilePath(fileName: Utility.getPageIdFromPagesArray(pageName: "Video Page") ?? "")
        }
        guard let _filePath = filePath else {
            return
        }
        if !_filePath.isEmpty {
            
            let jsonData:Data? = AppSandboxManager.getContentOfFilesAt(fileLocation: _filePath)
            
            if jsonData != nil {
                
                let responseJson:Dictionary<String, AnyObject>? = try! JSONSerialization.jsonObject(with:jsonData!) as? Dictionary<String, AnyObject>
                
                viewControllerPage = PageUIParser.sharedInstance.parsePageConfigurationJson(pageConfigDictionary: responseJson!)
            }
        }
        
        if viewControllerPage != nil {
            
            var videoDetailViewController:ModuleContainerViewController_tvOS!
            if gridObject?.contentType?.lowercased() == Constants.kShowContentType || gridObject?.contentType?.lowercased() == Constants.kShowsContentType
            {
                videoDetailViewController = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "show_detail")
            }
            else
            {
                videoDetailViewController = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "video_detail")
            }
            
//            let videoDetailViewController:ModuleContainerViewController_tvOS = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "video_detail")
            videoDetailViewController.contentId = gridObject?.contentId ?? ""
            videoDetailViewController.pagePath = gridObject?.gridPermaLink ?? ""
            videoDetailViewController.viewModel.pageOpenAction = .videoClickAction
            videoDetailViewController.gridObject = gridObject
            videoDetailViewController.view.changeFrameYAxis(yAxis: 20.0)
            videoDetailViewController.view.changeFrameHeight(height: videoDetailViewController.view.frame.height - 20.0)
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoDetailPage(videoDetailPage:))))! {
                delegate?.launchVideoDetailPage!(videoDetailPage: videoDetailViewController)
            }
        }
    }
    
    func videoSelectedAtIndexPath(gridObject: SFGridObject) {
        
        if gridObject.contentType?.lowercased() == Constants.kShowContentType || gridObject.contentType?.lowercased() == Constants.kShowsContentType {
            didSelectVideo(gridObject: gridObject)
        }
        else {
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayer(video:))))! {
                let videoObject = VideoObject.init(gridObject: gridObject)
                delegate?.launchVideoPlayer!(video: videoObject)
            }
        }
    }
}
