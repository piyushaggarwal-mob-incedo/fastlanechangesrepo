//
//  ModuleViewModel.swift
//  AppCMS
//
//  Created by Anirudh Vyas on 02/08/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation

@objc protocol ModuleViewModelDelegate: NSObjectProtocol {
    
    /// Implement this to launch account page.
    ///
    /// - Parameter accountPage: Account Page Object to be pushed.
    @objc optional func launchAccountPage(accountPage: UIViewController)
    
    /// Implement this to launch video player.
    
    /// Implement this to launch video player.
    ///
    /// - Parameter withVideo: Video Object to be played.
    @objc optional func launchVideoPlayer(video: VideoObject)
    /// Implement this to launch video player.
    ///
    /// - Parameter withVideo: Video Object to be played.
    @objc optional func launchVideoPlayerForEpisodicContent(video: VideoObject, nextEpisodesArray:Array<String>?)

    /// Implement this to launch the video detail page.
    ///
    /// - Parameter videoDetailPage: video detail module object
    @objc optional func launchVideoDetailPage(videoDetailPage: ModuleContainerViewController_tvOS)
    
    /// Implement this to launch the team detail page.
    ///
    /// - Parameter videoDetailPage: team detail module object
    @objc optional func launchTeamDetailPage(teamDetailPage: ModuleContainerViewController_tvOS)

    
    /// Implement this to launch the show detail page.
    ///
    /// - Parameter showDetailpage: show detail module object
    @objc optional func launchShowDetailPage(showDetailpage: ModuleContainerViewController_tvOS)
    
    /// Implement this to launch trailer screen.
    ///
    /// - Parameter trailerURL: string object
    @objc optional func launchTrailerPlayer(trailerURL: String)
    
    /// Implement this to show pop over controller on view controller
    ///
    /// - Parameter controller: PopOverController instance.
    @objc optional func showPopOverController(controller: SFPopOverController)
    
    /// Implement this to show the background view.
    ///
    /// - Parameters:
    ///   - film: film object
    ///   - isFocused: bool flag which alerts the viewcontroller whether the controlling view is focused or not.
    @objc optional func updateBackgroundView(film: SFFilm,isFocused: Bool)
    
    /// Implement this to show the background view.
    ///
    /// - Parameters:
    ///   - show: show object
    ///   - isFocused: bool flag which alerts the viewcontroller whether the controlling view is focused or not.
    @objc optional func updateBackgroundViewForShowObject(show: SFShow,isFocused: Bool)
    
    /// Implement this to show the alertController .
    ///
    /// - Parameters:
    /// - alertController: alertController object
    @objc optional func showAlertController(alertController: UIAlertController)
    
    
    /// Implement this to show the Forgot Password screen.
    ///
    /// - Parameters:
    ///
    @objc optional func forgotPasswordButtonTapped(forgotCredentialVC:ModuleContainerViewController_tvOS)
    
    /// Implement this to pop the current view controller.
    @objc optional func popCurrentViewController()
    
    /// Implement this to load loadAncillaryPageData depending on the type.
    @objc optional func loadAncillaryPageData(ancillaryVC:ModuleContainerViewController_tvOS)
    
    /// Implement to scroll on gesture.
    @objc optional func scrollToNextFocusableItem()
}

class ModuleViewModel: NSObject {
    
    /// ModuleViewModel Delegate property. Set this to get callbacks of the inherited classes. This is private property. Set using #delegate property.
    private weak var _delegate: ModuleViewModelDelegate?
    weak var delegate: ModuleViewModelDelegate? {
        set (newDelegate) {
            _delegate = newDelegate
        }
        get {
            return _delegate
        }
    }
    
}
