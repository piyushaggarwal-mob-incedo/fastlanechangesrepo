//
//  CollectionGridViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 24/03/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol CollectionGridViewDelegate:NSObjectProtocol {
    
    @objc func didSelectVideo(gridObject:SFGridObject?) -> Void
    @objc optional func didPlayVideo(contentId:String?, button:SFButton, gridObject:SFGridObject?) -> Void
    /*videoSelectedAtIndexPath delegate method provide selected gridobject/video to the adopted class.*/
    @objc optional func videoSelectedAtIndexPath(gridObject:SFGridObject) -> Void
    @objc optional func didDisplayMorePopUp(button:SFButton, gridObject:SFGridObject?) -> Void
    @objc optional func updateAdViewTrayHeight(adViewHeight:CGFloat, cellIndex:Int) -> Void
}

class CollectionGridViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SFCollectionGridCellDelegate,SFKisweBaseViewControllerDelegate {
    
    var trayObject:SFTrayObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    weak var delegate:CollectionGridViewDelegate?
    var isFromSearch:Bool = false
    #if os(tvOS)
    var trayObjectHeight:CGFloat?
    var trayObjectWidth:CGFloat?
    #endif
    
    var isWebViewInteractive:Bool = false
    var shouldNavigateToExternalBrowser:Bool = true
    var cellIndex:Int?
    
    init (trayObject:SFTrayObject) {
        
        self.trayObject = trayObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func createSubViews() {
        
        for component:Any in (trayObject?.trayComponents)! {
            
            if component is SFLabelObject {
                
                createLabelView(labelObject: component as! SFLabelObject)
            }
            else if component is SFWebViewObject {
                
                #if os(iOS)
                    createWebView(webViewObject: component as! SFWebViewObject)
                #endif
            }
            else if component is SFCollectionGridObject {
                
                collectionGridObject = component as? SFCollectionGridObject
                createGridView()
            }
            else if component is SFSeparatorViewObject {
                
                createSeparatorView(separatorViewObject: component as! SFSeparatorViewObject)
            }
            else if component is SFAdViewObject {
                
                #if os(iOS)
                createAdView(adViewObject: component as! SFAdViewObject)
                #endif
            }
        }
    }
    
    
    //MARK: Creation of Label View
    func createLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.relativeViewFrame = relativeViewFrame!
        label.labelLayout = labelLayout
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        
        if labelObject.key == "trayTitle" {
            
            if let textStyle = labelObject.textStyle {
                
                if textStyle == "default" {
                    label.text = moduleAPIObject?.moduleTitle
                } else {
                    label.text = moduleAPIObject?.moduleTitle?.uppercased()
                }
            }
            else {
                
                label.text = moduleAPIObject?.moduleTitle?.uppercased()
            }
            
            if isFromSearch {
                
                label.text = "Search Results"
            }
        }
        
        self.view.addSubview(label)
        label.createLabelView()
        
        if labelObject.key == "trayTitle" {
            label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? AppConfiguration.sharedAppConfiguration.appPageTitleColor ?? "ffffff")
        }
    }
    
    
    //MARK: Creation of Separtor View
    func createSeparatorView(separatorViewObject:SFSeparatorViewObject) {
        
        let separatorView:SFSeparatorView = SFSeparatorView(frame: CGRect.zero)
        separatorView.separtorViewObject = separatorViewObject
        separatorView.relativeViewFrame = relativeViewFrame!
        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject))
        self.view.addSubview(separatorView)
    }
    
    //MARK: Creation of Grid View
    func createGridView() {
        
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    func createCollectionView(collectionGridLayout:LayoutObject) {
        
        #if os(tvOS)
            trayObjectHeight = CGFloat(collectionGridLayout.gridHeight ?? 143)
            trayObjectWidth = CGFloat(collectionGridLayout.gridWidth ?? 255)
        #endif
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll)!, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout)
        #if os(iOS)
            collectionGrid?.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
            collectionGrid?.register(SFCollectionGridCell.self, forCellWithReuseIdentifier: "Grids")
        #else
            collectionGrid?.register(SFCollectionGridCell_tvOS.self, forCellWithReuseIdentifier: "Grids")
            if #available(tvOS 11.0, *) {
                self.collectionGrid?.contentInsetAdjustmentBehavior = .never
                self.collectionGrid?.contentInset = UIEdgeInsets.zero
            }
        #endif
        collectionGrid?.delegate = self
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = false
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
       
        #if os(iOS)
            self.view.sendSubview(toBack: collectionGrid!)
            
            #else
            updateCollectionViewHeight()
        #endif
    }
    
    #if os(tvOS)
    func updateCollectionViewHeight() {
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            if let isHorizontalScroll = collectionGridObject?.isHorizontalScroll{
                if !isHorizontalScroll{
                    collectionGrid?.isScrollEnabled = false
                    collectionGrid?.changeFrameHeight(height: Utility.sharedUtility.getCollectionViewHeightForSportsTemplate(rowHeight: 0, gridObject: collectionGridObject!, pageAPIModuleObject: moduleAPIObject!))
                }
            }
        }
    }
    #endif

    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (moduleAPIObject?.moduleData?.count)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        #if os(iOS)
            let gridCell:SFCollectionGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFCollectionGridCell
        #else
            let gridCell:SFCollectionGridCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFCollectionGridCell_tvOS
            gridCell.trayType = trayObject?.type
        #endif
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = trayObject?.trayImageType

        gridCell.gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
        
        #if os(iOS)
            
            if collectionGridObject?.backgroundColor != nil {
                
                gridCell.backgroundColor = Utility.hexStringToUIColor(hex: (collectionGridObject?.backgroundColor)!)
            }
            gridCell.collectionGridCellDelegate = self
        #endif
        
        gridCell.updateGridSubViewFrames()
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        #if os(iOS)
            if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.didSelectVideo(gridObject:))))! {
                
                let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
                delegate?.didSelectVideo(gridObject: gridObject)
            }
        #else
            
            if self.trayObject?.type == "AC ContinueWatching 01" || self.trayObject?.type == "AC ContinueWatching 02" {
                
                if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.videoSelectedAtIndexPath(gridObject:))))! {
                    let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
                    delegate?.videoSelectedAtIndexPath!(gridObject: gridObject!)
                }
                
            } else {
                
                if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.didSelectVideo(gridObject:))))! {
                    let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
                    delegate?.didSelectVideo(gridObject: gridObject)
                }
                
            }
        #endif
    }
    
    
    //MARK:ScrollView Delegate Method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    //MARK: Memory Warning methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    //MARK: View orientation delegates
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//
//        #if os(iOS)
//            if !Constants.IPHONE {
//
//                relativeViewFrame?.size.width = size.width
////                relativeViewFrame?.size.height = size.height
//                for subview:Any in self.view.subviews {
//
//                    if subview is SFLabel {
//
//                        let label:SFLabel = subview as! SFLabel
//                        label.relativeViewFrame = relativeViewFrame
//                        label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
//                    }
//                    else if subview is UICollectionView {
//
//                        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
//
////                        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll)!, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
////
////                        collectionGrid?.collectionViewLayout = collectionViewFlowLayout
//                        collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
////                        self.collectionGrid?.reloadData()
//
//                    }
//                    else if subview is SFSeparatorView {
//
//                        let separatorView:SFSeparatorView = subview as! SFSeparatorView
//                        separatorView.relativeViewFrame = relativeViewFrame
//                        separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
//                    }
//                    else if subview is SFWebView {
//
//                        self.updateWebViewFrame(webView: subview as! SFWebView)
//                    }
//                }
//            }
//        #endif
//    }
    
    #if os(tvOS)
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
    
        if (context.nextFocusedView is UICollectionViewCell) {
            collectionView.bringSubview(toFront: context.nextFocusedView!)
        }
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if(presses.first?.type == UIPressType.playPause) {
            if (UIScreen.main.focusedView?.isMember(of: CollectionGridViewController.self))! || UIScreen.main.focusedView is SFCollectionGridCell_tvOS  {
                let cellFocused = UIScreen.main.focusedView as! SFCollectionGridCell_tvOS
                let indexPath = collectionGrid?.indexPath(for: cellFocused)
    
                if delegate != nil && (delegate?.responds(to: #selector(CollectionGridViewDelegate.videoSelectedAtIndexPath(gridObject:))))! {
                    let gridObject = moduleAPIObject?.moduleData?[(indexPath?.row)!] as? SFGridObject
                    delegate?.videoSelectedAtIndexPath!(gridObject: gridObject!)
                }
            }
        } else if (presses.first?.type == UIPressType.menu) {
            super.pressesBegan(presses, with: event)
        }
    }
    #endif

    #if os(iOS)
    //MARK: Collection Grid Cell Delegates
    func buttonClicked(button: SFButton, gridObject: SFGridObject?) {
        
        if button.buttonObject?.action == "watchVideo" {
            
            if delegate != nil {
                
                if (delegate?.responds(to: #selector(CollectionGridViewDelegate.didPlayVideo(contentId:button:gridObject:))))! {
                    
                    self.delegate?.didPlayVideo!(contentId: gridObject?.contentId, button: button, gridObject: gridObject)
                }
            }
        }
        else if button.buttonObject?.action == "morePopUp" {
            
            if delegate != nil {
                
                if (delegate?.responds(to: #selector(CollectionGridViewDelegate.didDisplayMorePopUp(button:gridObject:))))! {
                    
                    self.delegate?.didDisplayMorePopUp!(button: button, gridObject: gridObject)
                }
            }
        }
    }

    func removeKisweBaseViewController(viewController:UIViewController) -> Void{
        self.view.isUserInteractionEnabled = true
    }
    
    //MARK: method to play video
    func playVideo(gridObject:SFGridObject?) {
        
        if gridObject != nil {
            
             let eventId = gridObject?.eventId
             if eventId != nil && Constants.kAPPDELEGATE.isKisweEnable{
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "", vc:self)
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
    
    override func viewDidLayoutSubviews() {
        
        relativeViewFrame?.size.width = UIScreen.main.bounds.size.width
        self.view.frame = relativeViewFrame!
        
        for subview:Any in self.view.subviews {
            
            if subview is SFLabel {
                
                let label:SFLabel = subview as! SFLabel
                label.relativeViewFrame = relativeViewFrame
                label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
            }
            else if subview is UICollectionView {
                
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
            }
            else if subview is SFSeparatorView {
                
                let separatorView:SFSeparatorView = subview as! SFSeparatorView
                separatorView.relativeViewFrame = relativeViewFrame
                separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
            }
            else if subview is SFWebView {
                
                self.updateWebViewFrame(webView: subview as! SFWebView)
            }
            else if subview is SFAdView {
                
                self.updateAdSizeOnOrientationChange(adView: subview as! SFAdView)
            }
        }
    }
    #endif
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

