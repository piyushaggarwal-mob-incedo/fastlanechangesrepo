//
//  LiveKiswePlayerDescriptionViewController.swift
//  AppCMS
//
//  Created by Rajesh Kumar  on 11/21/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol LiveVideoPlaybackDelegate: NSObjectProtocol {
    @objc func buttonTapped(button: SFButton, gridObject:SFGridObject?) -> Void
}

class LiveKiswePlayerDescriptionViewController: UIViewController,SFButtonDelegate {
    var videoThumbeImage : SFImageView!
    var playButton : SFButton!
    var imagePathString : String?
    var gridObject : SFGridObject?
    weak var liveVideoPlaybackDelegate: LiveVideoPlaybackDelegate?

    init(frame: CGRect, gridObject: SFGridObject?) {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = frame
        self.gridObject = gridObject
        if let object = self.gridObject{
            self.imagePathString = object.thumbnailImageURL
        }
        createImageView()
        createPlayButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: set image on imageView
    func updateImageOnImageView() -> Void {
        if self.imagePathString != nil
        {
            self.imagePathString = self.imagePathString?.appending("?impolicy=resize&w=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoThumbeImage.frame.size.width))&h=\(Utility.sharedUtility.getImageSizeAsPerScreenResolution(size: videoThumbeImage.frame.size.height))")
            self.imagePathString = self.imagePathString?.trimmingCharacters(in: .whitespaces)

            if self.imagePathString != nil
            {
                if let imageUrl = URL(string:self.imagePathString!) {

                    videoThumbeImage.af_setImage(
                        withURL: imageUrl,
                        placeholderImage: UIImage(named: Constants.kVideoImagePlaceholder),
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
                else {

                    videoThumbeImage.image = UIImage(named: Constants.kVideoImagePlaceholder)
                }
            }
            else
            {
                videoThumbeImage.image = UIImage(named: Constants.kVideoImagePlaceholder)
            }
        }
        else {

            videoThumbeImage.image = UIImage(named: Constants.kVideoImagePlaceholder)
        }
    }

    //MARK: Create imageView
    func createImageView() -> Void {
        videoThumbeImage = SFImageView()
        videoThumbeImage.frame = self.view.bounds
        self.updateImageOnImageView()
        self.view.addSubview(videoThumbeImage)
        self.view.bringSubview(toFront: videoThumbeImage)
    }

    //MARK: Create Play Button
    func createPlayButton() -> Void {
        playButton = SFButton(frame: CGRect.zero)
        playButton.relativeViewFrame = self.view.frame
        playButton.buttonDelegate = self
        playButton.createButtonView()
        if Constants.IPHONE {
            playButton.frame = CGRect(x: 0, y: 0, width: 76, height: 85)
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "videoDetailPlayIcon_iPhone.png"))
            
            self.playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.themeFontColor ?? AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
        }
        else {
            playButton.frame = CGRect(x: 0, y: 0, width: 111, height: 126)
            let playButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "videoDetailPlayIcon_iPad.png"))
            
            self.playButton?.setImage(playButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.playButton?.imageView?.tintColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.themeFontColor ?? AppConfiguration.sharedAppConfiguration.primaryButton.selectedColor ?? "ffffff")
        }
        playButton.center = self.view.center
        self.view.addSubview(playButton)
        self.view.bringSubview(toFront: playButton)
    }

    //MARK: Button Delegate Events
    func buttonClicked(button: SFButton) {
        if (self.liveVideoPlaybackDelegate != nil) && (self.liveVideoPlaybackDelegate?.responds(to: #selector(self.liveVideoPlaybackDelegate?.buttonTapped(button:gridObject:))))!{
            self.liveVideoPlaybackDelegate?.buttonTapped(button: button, gridObject: self.gridObject)
        }
    }

    //MARK: View orientation delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if !Constants.IPHONE {
            self.view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.width * 9/16)
            videoThumbeImage.frame = self.view.bounds
            self.updateImageOnImageView()
            playButton.center = self.view.center
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
