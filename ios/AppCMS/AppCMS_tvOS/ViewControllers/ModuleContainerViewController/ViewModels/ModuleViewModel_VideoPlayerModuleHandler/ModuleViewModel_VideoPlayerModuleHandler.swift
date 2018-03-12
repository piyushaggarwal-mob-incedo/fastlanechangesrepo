//
//  ModuleViewModel_VideoPlayerModuleHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 01/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_VideoPlayerModuleHandler: ModuleViewModel,VideoPlayerModuleDelegate {
    
    /// Method creates the video player view according to the inputs provided.
    ///
    /// - Parameters:
    ///   - parentViewFrame: view frames of the parent.
    ///   - pageModuleObject: module object based on which the view is getting created i.e. data.
    ///   - viewObject: viewObject for video Player.
    /// - Returns: VideoPlayerModule.
    func getVideoPlayerModule(parentViewFrame:CGRect, viewObject: VideoPlayerModuleViewObject, pageAPIModuleObject: SFModuleObject) -> VideoPlayerModule_tvOS {
        
        let moduleHeight: CGFloat = CGFloat(Utility.fetchVideoPlayerViewLayoutDetails(viewObject: viewObject).height!)
        let videoModule: VideoPlayerModule_tvOS = VideoPlayerModule_tvOS(frame: CGRect(x: 0, y: 0, width: parentViewFrame.size.width, height: moduleHeight))
        videoModule.view.frame = CGRect(x: 0, y: 0, width: parentViewFrame.size.width, height: moduleHeight)
        videoModule.viewObject = viewObject
        videoModule.moduleObject = pageAPIModuleObject
        videoModule.relativeViewFrame = CGRect(x: 0, y: 0, width: parentViewFrame.size.width, height: moduleHeight)
        videoModule.constructPage()
        videoModule.delegate = self
        return videoModule
    }
    
    func scrollToNextFocusableItem() {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.scrollToNextFocusableItem)))! {
            delegate?.scrollToNextFocusableItem!()
        }
    }
}
