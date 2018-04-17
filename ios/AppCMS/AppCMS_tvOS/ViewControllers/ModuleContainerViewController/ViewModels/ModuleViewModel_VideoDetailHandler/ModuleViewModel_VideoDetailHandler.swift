//
//  ModuleViewModel_VideoDetailHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_VideoDetailHandler: ModuleViewModel, VideoPlaybackDelegate {
    
    /// Method creates the video detail view according to the inputs provided.
    ///
    /// - Parameters:
    ///   - parentViewFrame: view frames of the parent.
    ///   - pageModuleObject: module object based on which the view is getting created i.e. data.
    ///   - videoDetailObject: video detail Object for UI.
    /// - Returns: Created VideoDetailViewModule_tvOS.
    func getVideoDetail(parentViewFrame:CGRect, pageModuleObject:SFModuleObject, videoDetailObject: SFVideoDetailModuleObject, gridObject: SFGridObject?) -> VideoDetailViewModule_tvOS {
        
        let moduleHeight: CGFloat = CGFloat(Utility.fetchVideoDetailLayoutDetails(videoDetailObject: videoDetailObject).height!)
        let moduleWidth: CGFloat = UIScreen.main.bounds.size.width
        let videoDescriptionView: VideoDetailViewModule_tvOS = VideoDetailViewModule_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), videoDescriptionModule: videoDetailObject, film: pageModuleObject.moduleData![0] as! SFFilm)
        videoDescriptionView.videoPlaybackDelegate = self
        videoDescriptionView.gridObject = gridObject
        videoDescriptionView.createView()
        return videoDescriptionView
    }
    
    func buttonTapped(button: SFButton, filmObject: SFFilm) {
        if button.buttonObject?.action == "watchVideo" {
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayer(video:))))! {
                let videoObject = VideoObject.init(filmObject: filmObject)
                delegate?.launchVideoPlayer!(video: videoObject)
            }
        }
        else if button.buttonObject?.action == "watchTrailer" {
            
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchTrailerPlayer(trailerURL:))))! {
                delegate?.launchTrailerPlayer!(trailerURL: filmObject.trailerURL!)
            }
            //GA watch trailer event
            GATrackerTVOS.sharedInstance().event(withCategory: "trailer-video", action: "playTrailer", label: filmObject.title, customParameters: [ "ev" : String(Int(-1)) ])
        }
    }
    
    func moreButtonTapped(filmObject: SFFilm) {
        let morePopOver = SFPopOverController(title: "", message: filmObject.desc!.stringByStrippingHTMLTags(), preferredStyle: .popOverSheet)
        morePopOver.view.backgroundColor = Utility.hexStringToUIColor(hex: "#24282b").withAlphaComponent(0.3)
        morePopOver.modalPresentationStyle = .overCurrentContext
        let closeAction = SFPopOverAction(title: "CLOSE", handler: { (action) in
            morePopOver.dismiss(animated: true, completion: nil)
        })
        morePopOver.actions = [closeAction]
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.showPopOverController(controller:))))! {
            delegate?.showPopOverController!(controller: morePopOver)
        }
    }
    
    func videoImageDidUpdateFocus(isFocused: Bool,film: SFFilm) {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.updateBackgroundView(film:isFocused:))))! {
            delegate?.updateBackgroundView!(film: film, isFocused: isFocused)
        }
    }
    
    
}
