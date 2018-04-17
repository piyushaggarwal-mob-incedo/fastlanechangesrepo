//
//  SeasonGridViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 21/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFSeasonGridDelegate:NSObjectProtocol {
    
    @objc optional func didSelectVideo(gridObject:SFGridObject?) -> Void
    @objc optional func didPlayVideo(contentId:String?, filmObject:SFFilm?, nextEpisodesArray: Array<String>?) -> Void
    @objc optional func didButtonClicked(gridObject:SFGridObject?, button:SFButton?) -> Void
    @objc optional func didSeasonSelectorButtonClicked(dropDownButton:SFDropDownButton?) -> Void
}

class SFSeasonGridViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, SFShowGridCellDelegate, downloadManagerDelegate,SFKisweBaseViewControllerDelegate, SFDropDownButtonDelegate {
    
    var trayObject:SFTrayObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var show:SFShow?
    var selectedSeason:Int?
    weak var delegate:SFSeasonGridDelegate?
    var isFromSearch:Bool = false
    
    init (trayObject:SFTrayObject) {
        
        self.trayObject = trayObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.sharedInstance.downloadDelegate = self
        // Do any additional setup after loading the view.
    }

    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updatePlayerProgress"), object: nil)
        DownloadManager.sharedInstance.downloadDelegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createSubViews() {
        
        for component:Any in (trayObject?.trayComponents)! {
            
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                createGridView()
            }
            else if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFDropDownButtonObject {
                
                if let seasons = show?.seasons {
                    
                    if seasons.count > 1 {
                        
                        createDropDownButtonView(dropDownButtonObject: component as! SFDropDownButtonObject)
                    }
                }
            }
        }
    }
    
    //MARK: Creation of Label View
    private func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if labelObject.key == "trayTitle" {
            
            if let seasons = show?.seasons {
                
                if seasons.count > 1 {
                    
                    label.isHidden = true
                }
            }
            
            label.text = show?.seasons?[selectedSeason ?? 0].title
            
            if label.text == nil || label.text?.isEmpty == true {
                
                if show?.seasons != nil && (show?.seasons?.count)! > 0 {
                    
                    label.text = "SEASON \((selectedSeason ?? 0) + 1)"
                }
            }
            
            if isFromSearch {
                
                label.text = "Search Results"
            }
        }
        
        self.view.addSubview(label)
        label.createLabelView()
        
        if labelObject.key == "trayTitle" {
            
            if AppConfiguration.sharedAppConfiguration.appPageTitleColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
            }
        }
    }
    
    
    //MARK: Creation of drop down view
    private func createDropDownButtonView(dropDownButtonObject:SFDropDownButtonObject) {
        
        let dropDownButtonLayout = Utility.fetchDropDownButtonViewLayoutDetails(dropDownButtonObject: dropDownButtonObject)
        
//        if dropDownButtonObject.isVerticalDropDown != nil {
//
//            if dropDownButtonObject.isVerticalDropDown! {
//
//                self.createHorizontalSeasonSelectorView(dropDownButtonObject: dropDownButtonObject, dropDownButtonLayout: dropDownButtonLayout)
//            }
//            else {
//
//                self.createHorizontalSeasonSelectorView(dropDownButtonObject: dropDownButtonObject, dropDownButtonLayout: dropDownButtonLayout)
//            }
//        }
//        else {
        
            self.createVerticalSeasonSelectorView(dropDownButtonObject: dropDownButtonObject, dropDownButtonLayout: dropDownButtonLayout)
//        }
    }
    
    
    //MARK: Creation of horizontal season selector view
    private func createHorizontalSeasonSelectorView(dropDownButtonObject:SFDropDownButtonObject, dropDownButtonLayout: LayoutObject) {
        
    }
    
    
    //MARK: Creation of vertical season selector view
    private func createVerticalSeasonSelectorView(dropDownButtonObject:SFDropDownButtonObject, dropDownButtonLayout: LayoutObject) {
        
        let dropDownButton:SFDropDownButton = SFDropDownButton(frame: .zero)
        dropDownButton.buttonObject = dropDownButtonObject
        dropDownButton.relativeViewFrame = relativeViewFrame!
        dropDownButton.buttonDelegate = self
        dropDownButton.initialiseDropDownButtonFrameFromLayout(dropDownButtonLayout: dropDownButtonLayout)
        dropDownButton.createButtonView()
        
        if show?.seasons != nil && (show?.seasons?.count)! > 0 {
            
            dropDownButton.setTitle(show?.seasons?[selectedSeason ?? 0].title ?? "SEASON \((selectedSeason ?? 0) + 1)", for: .normal)
        }
        
        if dropDownButtonObject.imageName != nil {
            
            dropDownButton.imageEdgeInsets = UIEdgeInsetsMake((dropDownButton.frame.size.height - 13)/2, (dropDownButton.frame.size.width - 11), (dropDownButton.frame.size.height - 13)/2, 0)
        }
        
        if dropDownButton.titleLabel?.font != nil {
            
            dropDownButton.titleLabel?.font = UIFont(name: (dropDownButton.titleLabel?.font.fontName)!, size: (dropDownButton.titleLabel?.font.pointSize)! * Utility.getBaseScreenHeightMultiplier())
            dropDownButton.titleLabel?.adjustsFontSizeToFitWidth = true
            dropDownButton.titleLabel?.minimumScaleFactor = 0.5
        }
        
        dropDownButton.titleLabel?.lineBreakMode = .byTruncatingTail
        dropDownButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 11)
        dropDownButton.setTitleColor(Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "ffffff"), for: .normal)
        
        self.view.addSubview(dropDownButton)
    }
    
    
    //MARK: Creation of Separtor View
    private func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        self.view.addSubview(separatorView)
    }
    
    //MARK: Creation of Grid View
    private func createGridView() {
        
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    private func createCollectionView(collectionGridLayout:LayoutObject) {
        
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll) ?? false, gridPadding: collectionGridLayout.trayPadding != nil ? (CGFloat((collectionGridLayout.trayPadding)!) * Utility.getBaseScreenHeightMultiplier()) : 1.0)
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout)
        collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! )//+ 30.0) //* Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
        collectionGrid?.register(SFShowGridCell.self, forCellWithReuseIdentifier: "Grids")
        collectionGrid?.delegate = self
        collectionGrid?.isScrollEnabled = false
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = true
        collectionGrid?.isUserInteractionEnabled = true
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
        self.view.sendSubview(toBack: collectionGrid!)
    }
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (show?.seasons?[selectedSeason ?? 0].episodes!.count) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let gridCell:SFShowGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFShowGridCell
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = trayObject?.trayImageType
        gridCell.relativeViewFrame = gridCell.frame
        gridCell.film = show?.seasons?[selectedSeason ?? 0].episodes![indexPath.row]
        gridCell.showGridCellDelegate = self
        gridCell.episodeNumber = indexPath.row + 1
        gridCell.updateGridSubView()
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if delegate != nil {
            
            let filmObject = show?.seasons?[selectedSeason ?? 0].episodes![indexPath.row]
            
            let nextEpisodesArray:Array<String>? = self.fetchNextEpisodesToBeAutoPlayed(filmObject: filmObject!, seasonsArray: (show?.seasons)!, currentEpisodeIndex:indexPath.row, seasonIndex: selectedSeason ?? 0)
            if (delegate?.responds(to: #selector(SFSeasonGridDelegate.didPlayVideo(contentId:filmObject:nextEpisodesArray:))))! {
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "updatePlayerProgress"), object: nil)
                NotificationCenter.default.addObserver(self, selector:#selector(updatePlayerProgress), name: NSNotification.Name(rawValue: "updatePlayerProgress"), object: nil);
                self.delegate?.didPlayVideo!(contentId: filmObject?.id, filmObject: filmObject, nextEpisodesArray: nextEpisodesArray)
            }
        }
    }
    
    
    private func fetchNextEpisodesToBeAutoPlayed(filmObject:SFFilm, seasonsArray:Array<SFSeason>, currentEpisodeIndex:Int, seasonIndex:Int) -> Array<String>?{
        
        var nextEpisodeArray:Array<String>?
        var currentEpisodeIndexValue = currentEpisodeIndex + 1
        
        for seasonNumber in seasonIndex ..< seasonsArray.count {
            
            if seasonNumber != seasonIndex {
                
                currentEpisodeIndexValue = 0
            }
            
            let episodesArray = seasonsArray[seasonNumber].episodes
            
            if episodesArray != nil {
                
                if currentEpisodeIndexValue < (episodesArray?.count)! {
                    
                    for episodeNumber in currentEpisodeIndexValue ..< (episodesArray?.count)! {
                        
                        if nextEpisodeArray == nil {
                            
                            nextEpisodeArray = []
                        }
                        
                        let nextEpisode:SFFilm = episodesArray![episodeNumber]
                        
                        if nextEpisode.id != nil {
                            
                            nextEpisodeArray?.append(nextEpisode.id!)
                        }
                    }
                }
            }
        }
        
        return nextEpisodeArray
    }
    
    
    //MARK: View orientation delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if !Constants.IPHONE {
            
            let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject!, noOfData: Float(show?.seasons?[selectedSeason ?? 0].episodes!.count ?? 0))) * Utility.getBaseScreenHeightMultiplier()
            relativeViewFrame?.size.height = rowHeight
            relativeViewFrame?.size.width = UIScreen.main.bounds.size.width
            
            for subview:Any in self.view.subviews {
                
                if subview is SFLabel {
                    
                    let label:SFLabel = subview as! SFLabel
                    label.relativeViewFrame = relativeViewFrame
                    label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
                }
                else if subview is UICollectionView {
                    
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                    
                    let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll) ?? false, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
                    
                    collectionGrid?.collectionViewLayout = collectionViewFlowLayout
                    collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
                    collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
                    collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())

                    coordinator.animate(alongsideTransition: { (context) in
                        
                        self.collectionGrid?.reloadData()
                    }, completion: nil)
                }
                else if subview is SFSeparatorView {
                    
                    let separatorView:SFSeparatorView = subview as! SFSeparatorView
                    separatorView.relativeViewFrame = relativeViewFrame
                    separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
                }
                else if subview is SFDropDownButton {
                    
                    let dropDownButton:SFDropDownButton = subview as! SFDropDownButton
                    dropDownButton.relativeViewFrame = relativeViewFrame
                    dropDownButton.initialiseDropDownButtonFrameFromLayout(dropDownButtonLayout: Utility.fetchDropDownButtonViewLayoutDetails(dropDownButtonObject: dropDownButton.buttonObject!))
                    
                    if dropDownButton.buttonObject?.imageName != nil {
                        
                        dropDownButton.imageEdgeInsets = UIEdgeInsetsMake((dropDownButton.frame.size.height - 13)/2, (dropDownButton.frame.size.width - 11), (dropDownButton.frame.size.height - 13)/2, 0)
                    }
                }
            }
        }
    }
    
    
    //MARK: Collection Grid Cell Delegates
    func buttonClicked(button: SFButton, filmObject: SFFilm?) {

    }

    func removeKisweBaseViewController(viewController:UIViewController) -> Void{
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK: method to play video
    func playVideo(gridObject:SFGridObject?) {
        
        if gridObject != nil {
            
             let eventId = gridObject?.eventId
            
            if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "",vc: self)
            }
            else {
                
                if CastPopOverView.shared.isConnected(){
                    
                    if  Utility.sharedUtility.checkIfMoviePlayable() == true || gridObject?.isFreeVideo == true {
                        CastController().playSelectedItemRemotely(contentId: gridObject?.contentId ?? "", isDownloaded:  false, relatedContentIds: nil, contentTitle: gridObject?.contentTitle ?? "")
                    }
                    else{
                        Utility.sharedUtility.showAlertForUnsubscribeUser()
                    }
                }
                else{
                    let videoObject: VideoObject = VideoObject()
                    videoObject.videoTitle = gridObject?.contentTitle ?? ""
                    videoObject.videoPlayerDuration = gridObject?.totalTime ?? 0
                    videoObject.videoContentId = gridObject?.contentId ?? ""
                    videoObject.gridPermalink = gridObject?.gridPermaLink ?? ""
                    videoObject.videoWatchedTime = gridObject?.watchedTime ?? 0
                    
                    let playerViewController: CustomVideoController = CustomVideoController.init(videoObject: videoObject, videoPlayerType: .streamVideoPlayer, videoFitType: .fullScreen)
                    self.present(playerViewController, animated: true, completion: nil)
                }
            }
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Error is loading film details", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    // MARK: - DownloadManager Delegate
    func updateDownloadProgress(for thisObject: DownloadObject, withProgress progress: Float) {
        
        var index:Int = -1
        let episodesArray = show?.seasons?[selectedSeason ?? 0].episodes!
        
        if episodesArray != nil {
            
            for episodeIndex in 0 ..< (episodesArray?.count)! {
                
                let episode:SFFilm = episodesArray![episodeIndex]
                
                if episode.id == thisObject.fileID {
                    
                    index = episodeIndex
                    break
                }
            }
            
            if index != -1 {
                
                let gridCell:SFShowGridCell? = self.collectionGrid?.cellForItem(at: IndexPath(item: index, section: 0)) as? SFShowGridCell
                
                if gridCell != nil {
                    DispatchQueue.main.async {
                        
                        gridCell?.updateCircularProgressForDownloadObject(downloadObject: thisObject, downloadingProgress: progress)
                    }
                }
            }
        }
    }
    
    func downloadFinished(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }
    
    func downloadStateUpdate(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }
    
    func downloadFailed(for thisObject: DownloadObject) {
        manageStateOfProgressViews(with: thisObject)
    }
    
    func manageStateOfProgressViews(with thisObject: DownloadObject) {
        
        var index:Int = -1
        let episodesArray = show?.seasons?[selectedSeason ?? 0].episodes!
        
        if episodesArray != nil {
            
            for episodeIndex in 0 ..< (episodesArray?.count)! {
                
                let episode:SFFilm = episodesArray![episodeIndex]
                
                if episode.id == thisObject.fileID {
                    
                    index = episodeIndex
                    break
                }
            }
            
            if index != -1 {
                
                let gridCell:SFShowGridCell? = self.collectionGrid?.cellForItem(at: IndexPath(item: index, section: 0)) as? SFShowGridCell
                
                if gridCell != nil {
                    
                    DispatchQueue.main.async {
                        
                        gridCell?.updateCircularProgressForDownloadObject(downloadObject: thisObject, downloadingProgress: DownloadManager.sharedInstance.getDownloadProgress(forObject: thisObject.fileID))
                    }
                }
            }
        }
    }

    
    //MARK: Drop down button delegate
    func buttonClicked(button: SFDropDownButton) {
        
        if self.delegate != nil {
            
            if (self.delegate?.responds(to: #selector(SFSeasonGridDelegate.didSeasonSelectorButtonClicked(dropDownButton:))))! {
             
                self.delegate?.didSeasonSelectorButtonClicked!(dropDownButton: button)
            }
        }
    }
    
    
    //MARK: Method to update player progress
    func updatePlayerProgress(notification:Notification) {
        
        /*
        guard let userInfoDict:Dictionary<String, Any> = notification.userInfo as? Dictionary<String, Any> else { return }
        guard let notificationFilmId:String = userInfoDict["filmId"] as? String else { return }
        guard let playerProgressDuration:Double = userInfoDict["playerProgress"] as? Double else { return }
        
        var index:Int = -1
        let episodesArray = show?.seasons?.first?.episodes!
        
        if episodesArray != nil {
            
            for episodeIndex in 0 ..< (episodesArray?.count)! {
                
                let episode:SFFilm = episodesArray![episodeIndex]
                
                if episode.id == notificationFilmId {
                    
                    index = episodeIndex
                    break
                }
            }
            
            if index != -1 {
                
                let gridCell:SFShowGridCell? = self.collectionGrid?.cellForItem(at: IndexPath(item: index, section: 0)) as? SFShowGridCell
                
                if gridCell != nil {
                    
                    DispatchQueue.main.async {

                        gridCell?.updateCellPlayerProgress(progressValue: playerProgressDuration)
                    }
                }
            }
        }
        */
    }
}

