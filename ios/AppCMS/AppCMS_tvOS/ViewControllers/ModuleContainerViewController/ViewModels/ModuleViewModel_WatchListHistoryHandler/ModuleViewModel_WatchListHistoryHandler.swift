//
//  ModuleViewModel_WatchListHistoryHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 11/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_WatchListHistoryHandler: ModuleViewModel, SFWatchlistAndHistoryViewModuleDelegate {
    
    func getModuleView(parentViewFrame:CGRect, watchListObject: SFWatchlistAndHistoryViewObject) -> SFWatchlistAndHistoryViewModule {
        let moduleHeight: CGFloat = CGFloat(Utility.fetchWatchlistLayoutDetails(watchListObject: watchListObject).height!)
        let watchListView: SFWatchlistAndHistoryViewModule = SFWatchlistAndHistoryViewModule(frame: CGRect(x: 0, y: 0, width: parentViewFrame.size.width, height: moduleHeight))
        watchListView.delegate = self
        watchListView.moduleObject = watchListObject
        watchListView.relativeViewFrame = parentViewFrame
        watchListView.createView()
        return watchListView
    }
    
    func launchVideo(gridObject: SFGridObject?, cellRowValue: Int) {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayer(video:))))! {
            let videoObject = VideoObject.init(gridObject: gridObject!)
            delegate?.launchVideoPlayer!(video: videoObject)
        }
    }
    
    func openVideoDetails(gridObject: SFGridObject?, cellRowValue: Int) {
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
            
            //let videoDetailViewController:ModuleContainerViewController_tvOS = ModuleContainerViewController_tvOS.init(pageObject: viewControllerPage!, pageDisplayName: "video_detail")
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
    
    func clearButtonClicked(button: SFButton) {
        
    }
}
