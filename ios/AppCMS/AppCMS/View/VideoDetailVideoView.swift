//
//  VideoDetailVideoView.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 19/05/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import Foundation



class VideoDetailVideoView: UIView{
    
    weak var videoPlaybackDelegate: VideoPlaybackDelegate?

    
    var videoTitle: String?
    var videoRunTime: Int?
    var videoReleaseYear: String?
    var videoThumbnailUrl: String?
    
    var titleLabel: UILabel!
    var runTimeLabel: UILabel!
    var thumbnailImageview: UIImageView!
    var playButton: UIButton!
    
    func createVideoRunTimeLabel(fontName: String, fontSize: Float, viewFrame: CGRect, labelTextColor: UIColor) -> UILabel {
        let videoRuntimeLabel: UILabel = UILabel.init(frame: viewFrame)
        videoRuntimeLabel.font = UIFont.init(name: fontName, size: CGFloat(fontSize))
        videoRuntimeLabel.textColor = labelTextColor
        return videoRuntimeLabel
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let upperSpacing: CGFloat = 5.0
        let leftSpacing: CGFloat = 5.0
        let titleHeight: CGFloat = 30.0
        let runTimeLabelWidth: CGFloat = 100.0
        self.titleLabel = UILabel.init(frame: CGRect.init(x: leftSpacing, y: upperSpacing, width: frame.width - runTimeLabelWidth, height: titleHeight))
        self.titleLabel.font = UIFont.init(name: "Helvetica-Bold", size: 16)
        self.runTimeLabel = self.createVideoRunTimeLabel(fontName: "Helvetica", fontSize: 14, viewFrame: CGRect.init(x: titleLabel.frame.maxX + leftSpacing, y: upperSpacing, width: runTimeLabelWidth - leftSpacing, height: titleHeight), labelTextColor: Utility.hexStringToUIColor(hex: "ffffff"))
        
        self.thumbnailImageview = UIImageView.init(frame: CGRect.init(x: 0, y: titleLabel.frame.maxY + upperSpacing, width: frame.width, height: frame.height - (titleLabel.frame.maxY + upperSpacing)))
        let playButtonDimension: CGFloat = 50.0
        self.playButton = UIButton.init(frame: CGRect.init(x: self.thumbnailImageview.frame.midX - (playButtonDimension/2), y: self.thumbnailImageview.frame.midY - (playButtonDimension/2), width: playButtonDimension, height: playButtonDimension))
        let playButtonImage: UIImage = UIImage.init(named: "play", in: nil, compatibleWith: nil)!
        self.playButton.setImage(playButtonImage, for: UIControlState.normal)
        self.playButton.addTarget(self, action: #selector(videoPlayButtonTapped(sender:)), for: .touchUpInside)
        
        
        self.addSubview(titleLabel)
        self.addSubview(runTimeLabel)
        self.addSubview(thumbnailImageview)
        self.addSubview(playButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView() -> Void {
        DispatchQueue.main.async {
            self.titleLabel.text = self.videoTitle
            let runTimeString: String = String.init(format: "%d min | %@", self.videoRunTime!, self.videoReleaseYear!)
            self.runTimeLabel.text = runTimeString
            
            self.thumbnailImageview.af_setImage(
                withURL: URL(string: self.videoThumbnailUrl ?? "")!,
                placeholderImage: UIImage(named: "placeholder"),
                filter: nil,
                imageTransition: .crossDissolve(0.2)
            )
        }
    }
    
    func videoPlayButtonTapped(sender: UIButton) -> Void
    {
        if (self.videoPlaybackDelegate != nil) && (self.videoPlaybackDelegate?.responds(to: #selector(self.videoPlaybackDelegate?.playVideo)))!
        {
            self.videoPlaybackDelegate?.playVideo()
        }
    }

}
