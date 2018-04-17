//
//  VideoDetailDescriptionViewController.swift
//  AppCMS
//
//  Created by Abhinav Saldi on 12/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit
import Firebase
@objc protocol MoreButtonDelegate: NSObjectProtocol {
     @objc func videoDescRemoved() -> Void
}
class VideoDetailDescriptionViewController: UIViewController {
    
    weak var moreButtonDelegate: MoreButtonDelegate?
    var film: SFFilm?
    var show: SFShow?
    var filmDescriptionTextView: UITextView = UITextView()
    var filmTitleLabel: UILabel = UILabel()
    var closeButton: UIButton!
    
    let closeButtonDimension: CGFloat = 40.0 * Utility.getBaseScreenHeightMultiplier()
    
    init(film: SFFilm?, show: SFShow?) {
        self.film = film
        self.show = show
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pageTitle = ""//"Video Detail Screen - "
        
        if self.film != nil {
            
            pageTitle = "Video Detail Screen - "
            pageTitle += film?.title ?? ""
        }
        else if self.show != nil {
            
            pageTitle = "Show Detail Screen - "
            pageTitle += show?.showTitle ?? ""
        }
        
        if Utility.sharedUtility.checkIfGoogleTagMangerAvailable() {
            
            FIRAnalytics.setScreenName(pageTitle, screenClass: nil)
        }
        
        closeButton = UIButton.init(type: UIButtonType.custom)
        
        var closeButtonYAxis:CGFloat = 20
        
        if Utility.sharedUtility.isIphoneX() {
            
            closeButtonYAxis = 30
        }
        
        closeButton.frame = CGRect.init(x: self.view.frame.width - closeButtonDimension - (10 * Utility.getBaseScreenHeightMultiplier()), y: (closeButtonYAxis * Utility.getBaseScreenHeightMultiplier()), width: closeButtonDimension, height: closeButtonDimension)
        
        let closeButtonImageView: UIImageView = UIImageView.init(image: #imageLiteral(resourceName: "cancelIcon.png"))
        
        closeButton.setImage(closeButtonImageView.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.imageView?.tintColor = Utility.hexStringToUIColor(hex: "ffffff")
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped(sender:)), for: .touchUpInside)
        self.view.addSubview(closeButton)
        
        filmTitleLabel = UILabel.init(frame: CGRect.init(x: 5 * Utility.getBaseScreenHeightMultiplier(), y: self.closeButton.frame.maxY + (10 * Utility.getBaseScreenHeightMultiplier()), width: self.view.frame.size.width - (10 * Utility.getBaseScreenHeightMultiplier()), height: closeButtonDimension * 2))
        filmTitleLabel.backgroundColor = .clear
        filmTitleLabel.textColor = .white
        if Constants.IPHONE {
            filmTitleLabel.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 18 * Utility.getBaseScreenHeightMultiplier())
        }
        else
        {
            filmTitleLabel.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())-Bold", size: 23 * Utility.getBaseScreenHeightMultiplier())
        }
        filmTitleLabel.numberOfLines = 0
        filmTitleLabel.textAlignment = .center
        self.view.addSubview(filmTitleLabel)
        
        
        filmDescriptionTextView = UITextView.init()
        filmDescriptionTextView.frame = CGRect.init(x: (10 * Utility.getBaseScreenHeightMultiplier()), y: self.filmTitleLabel.frame.maxY, width: self.view.frame.size.width - (20 * Utility.getBaseScreenHeightMultiplier()), height: (self.view.frame.height - self.filmTitleLabel.frame.maxY - (10 * Utility.getBaseScreenHeightMultiplier())))
        filmDescriptionTextView.backgroundColor = .clear
        if Constants.IPHONE {
            filmDescriptionTextView.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 12 * Utility.getBaseScreenHeightMultiplier())
        }
        else
        {
            filmDescriptionTextView.font = UIFont.init(name: "\(Utility.sharedUtility.fontFamilyForApplication())", size: 13 * Utility.getBaseScreenHeightMultiplier())
        }
        filmDescriptionTextView.isEditable = false
        filmDescriptionTextView.isSelectable = false
        
        self.view.addSubview(filmDescriptionTextView)
        self.filmDescriptionTextView.textColor = .white
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.film != nil {
            
            self.filmTitleLabel.text = self.film?.title
            self.filmDescriptionTextView.text = self.film?.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
        else if self.show != nil {
            
            self.filmTitleLabel.text = self.show?.showTitle
            self.filmDescriptionTextView.text = self.show?.desc!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeButtonTapped(sender: UIButton) -> Void {
        self.dismiss(animated: true) {
            if self.moreButtonDelegate != nil && (self.moreButtonDelegate?.responds(to: #selector(self.moreButtonDelegate?.videoDescRemoved)))! {
                self.moreButtonDelegate?.videoDescRemoved()
            }
        }
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        
        var closeButtonYAxis:CGFloat = 20
        
        if Utility.sharedUtility.isIphoneX() {
            
            closeButtonYAxis = 30
        }
        
        self.closeButton.frame = CGRect.init(x: self.view.frame.width - closeButtonDimension - (10 * Utility.getBaseScreenHeightMultiplier()), y: (closeButtonYAxis * Utility.getBaseScreenHeightMultiplier()), width: closeButtonDimension, height: closeButtonDimension)
        self.filmTitleLabel.frame = CGRect.init(x: 5 * Utility.getBaseScreenHeightMultiplier(), y: self.closeButton.frame.maxY + (10 * Utility.getBaseScreenHeightMultiplier()), width: self.view.frame.size.width - (10 * Utility.getBaseScreenHeightMultiplier()), height: closeButtonDimension * 2)
        self.filmDescriptionTextView.frame = CGRect.init(x: (10 * Utility.getBaseScreenHeightMultiplier()), y: self.filmTitleLabel.frame.maxY, width: self.view.frame.size.width - (20 * Utility.getBaseScreenHeightMultiplier()), height: (self.view.frame.height - self.filmTitleLabel.frame.maxY - (10 * Utility.getBaseScreenHeightMultiplier())))
    }
    
}
