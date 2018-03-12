//
//  ModuleViewModel_CarouselHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 02/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_CarouselHandler: ModuleViewModel, CarouselViewControllerDelegate {
    
    /// Method creates the carousel view according to the inputs provided.
    ///
    /// - Parameters:
    ///   - parentViewFrame: view frames of the parent.
    ///   - pageModuleObject: module object based on which the view is getting created i.e. data.
    ///   - jumbotronObject: jumbotron Object for UI.
    /// - Returns: Created CarouselViewController.
    func getCarouselView(parentViewFrame:CGRect, pageModuleObject:SFModuleObject, jumbotronObject: SFJumbotronObject) -> CarousalViewController {
        var viewFrame = parentViewFrame
        let rowHeight:CGFloat = CGFloat(Utility.fetchCarouselLayoutDetails(carouselViewObject: jumbotronObject).height ?? 400)
        //Updating jumbotron height and width
        viewFrame.size.height = rowHeight
        viewFrame.size.width = UIScreen.main.bounds.size.width
        let carouselViewController:CarousalViewController = CarousalViewController()
        carouselViewController.view.frame = viewFrame
        
        carouselViewController.relativeViewFrame = viewFrame
        carouselViewController.isCarouselHidden = false
        carouselViewController.delegate = self
        carouselViewController.carouselObject = jumbotronObject
        carouselViewController.pageModuleObject = pageModuleObject
        carouselViewController.createSubViews()

        return carouselViewController
    }
    
    @objc func didCarouselButtonClicked(contentId: String?, buttonAction: String, gridObject: SFGridObject) {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayer(video:))))! {
            let videoObject = VideoObject.init(gridObject: gridObject)
            delegate?.launchVideoPlayer!(video: videoObject)
        }
    }
    
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
}
