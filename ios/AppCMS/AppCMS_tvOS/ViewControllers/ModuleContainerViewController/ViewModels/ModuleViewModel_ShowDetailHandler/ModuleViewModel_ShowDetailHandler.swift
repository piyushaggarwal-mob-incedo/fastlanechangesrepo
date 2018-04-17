//
//  ModuleViewModel_ShowDetailHandler.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 03/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

class ModuleViewModel_ShowDetailHandler: ModuleViewModel, ShowPlaybackDelegate {
    
    /// Method creates the video detail view according to the inputs provided.
    ///
    /// - Parameters:
    ///   - parentViewFrame: view frames of the parent.
    ///   - pageModuleObject: module object based on which the view is getting created i.e. data.
    ///   - videoDetailObject: video detail Object for UI.
    /// - Returns: Created VideoDetailViewModule_tvOS.
    func getShowDetail(parentViewFrame:CGRect, pageModuleObject:SFModuleObject, showDetailObject: SFShowDetailModuleObject) -> ShowDetailViewModule_tvOS {
        var moduleHeight: CGFloat = CGFloat(Utility.fetchShowDetailLayoutDetails(showDetailObject: showDetailObject).height!)
            let arrayOfTrayObjects = showDetailObject.showDetailModuleComponents?.filter() {$0 is SFTrayObject}
            if let _arrayOfTrayObjects = arrayOfTrayObjects {
                if _arrayOfTrayObjects.count > 0 {
                    let trayObject = _arrayOfTrayObjects[0]
                    let show : SFShow = pageModuleObject.moduleData![0] as! SFShow
                    // let seasonArray =  show.seasons
                    if let seasonsArray =  show.seasons {
                        if seasonsArray.count > 0{
                            let collectionViewFrameHeight: CGFloat = CGFloat(Utility.fetchTrayLayoutDetails(trayObject: trayObject as! SFTrayObject).height!)
                            moduleHeight = moduleHeight + ((CGFloat)(seasonsArray.count) * (collectionViewFrameHeight))
                        }
                    }
                }
            }
        let moduleWidth: CGFloat = UIScreen.main.bounds.size.width
        let videoDescriptionView: ShowDetailViewModule_tvOS = ShowDetailViewModule_tvOS.init(frame: CGRect.init(x: 0, y: 0, width: moduleWidth, height: moduleHeight), showDescriptionModule: showDetailObject, show: pageModuleObject.moduleData![0] as! SFShow)
        videoDescriptionView.showPlaybackDelegate = self
        return videoDescriptionView
    }
    
    func buttonTapped(button: SFButton, showObject: SFShow, filmObject:SFFilm, nextEpisodesArray: Array<String>?) {
        if button.buttonObject?.action == "watchVideo" {
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayerForEpisodicContent(video:nextEpisodesArray:))))! {
                let videoObject = VideoObject.init(filmObject: filmObject)
                delegate?.launchVideoPlayerForEpisodicContent!(video: videoObject,nextEpisodesArray:nextEpisodesArray)
            }
        }
        else if button.buttonObject?.action == "watchTrailer" {
            
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchTrailerPlayer(trailerURL:))))! {
                delegate?.launchTrailerPlayer!(trailerURL: showObject.trailerURL!)
            }
            //GA watch trailer event
            GATrackerTVOS.sharedInstance().event(withCategory: "trailer-video", action: "playTrailer", label: showObject.showTitle, customParameters: [ "ev" : String(Int(-1)) ])
        }
    }
   
    func playSelectedEpisode(showObject: SFShow, filmObject:SFFilm, nextEpisodesArray: Array<String>?) {
            if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.launchVideoPlayerForEpisodicContent(video:nextEpisodesArray:))))! {
                let videoObject = VideoObject.init(filmObject: filmObject)
                delegate?.launchVideoPlayerForEpisodicContent!(video: videoObject,nextEpisodesArray:nextEpisodesArray)
            }

    }
    
    
    
    func moreButtonTapped(showObject: SFShow) {
        let morePopOver = SFPopOverController(title: "", message: showObject.desc!.stringByStrippingHTMLTags(), preferredStyle: .popOverSheet)
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
    
    func updateBackgroundView(isFocused: Bool,show: SFShow) {
        if delegate != nil && (delegate?.responds(to: #selector(ModuleViewModelDelegate.updateBackgroundViewForShowObject(show:isFocused:))))! {
            delegate?.updateBackgroundViewForShowObject!(show: show, isFocused: isFocused)
        }
    }
    
    
}
