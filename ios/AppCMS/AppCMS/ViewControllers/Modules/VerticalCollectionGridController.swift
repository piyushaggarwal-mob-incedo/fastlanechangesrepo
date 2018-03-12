//
//  VerticalCollectionGridController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 14/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol VerticalCollectionGridDelegate:NSObjectProtocol {
    
    @objc func didSelectVideo(gridObject:SFGridObject?) -> Void
    @objc optional func didPlayVideo(contentId:String?, button:SFButton, gridObject:SFGridObject?) -> Void
    /*videoSelectedAtIndexPath delegate method provide selected gridobject/video to the adopted class.*/
    @objc optional func videoSelectedAtIndexPath(gridObject:SFGridObject) -> Void
}

class VerticalCollectionGridController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, SFVerticalCollectionGridCellDelegate,SFKisweBaseViewControllerDelegate {

    var trayObject:SFTrayObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var moduleAPIObject:SFModuleObject?
    weak var delegate:VerticalCollectionGridDelegate?
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

        // Do any additional setup after loading the view.
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
            label.text = moduleAPIObject?.moduleTitle?.uppercased()
            
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

        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: collectionGridObject?.isHorizontalScroll ?? false, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout)
        collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
        collectionGrid?.isPagingEnabled = collectionGridObject?.supportPagination != nil ? (collectionGridObject?.supportPagination)! : false
        collectionGrid?.register(SFVerticalCollectionGridCell.self, forCellWithReuseIdentifier: "Grids")
        collectionGrid?.delegate = self
        collectionGrid?.isScrollEnabled = false
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = true
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
        self.view.sendSubview(toBack: collectionGrid!)
    }
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (moduleAPIObject?.moduleData?.count)!
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let gridCell:SFVerticalCollectionGridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFVerticalCollectionGridCell
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = trayObject?.trayImageType
        gridCell.gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
        gridCell.collectionGridCellDelegate = self
        gridCell.updateGridSubViewFrames()
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if delegate != nil && (delegate?.responds(to: #selector(VerticalCollectionGridDelegate.didSelectVideo(gridObject:))))! {
            
            let gridObject = moduleAPIObject?.moduleData?[indexPath.row] as? SFGridObject
            delegate?.didSelectVideo(gridObject: gridObject)
        }
    }
    
    //MARK: View orientation delegates
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if !Constants.IPHONE {
            
            let rowHeight:CGFloat = CGFloat(Utility.sharedUtility.calculateCellHeightFromCellComponents(trayObject: trayObject!, noOfData: Float(moduleAPIObject?.moduleData?.count ?? 0))) * Utility.getBaseScreenHeightMultiplier()
            
            self.view.changeFrameHeight(height: rowHeight)
            self.view.changeFrameWidth(width: UIScreen.main.bounds.size.width)
            
            relativeViewFrame = self.view.frame
            
            for subview:Any in self.view.subviews {
                
                if subview is SFLabel {
                    
                    let label:SFLabel = subview as! SFLabel
                    label.relativeViewFrame = relativeViewFrame
                    label.initialiseLabelFrameFromLayout(labelLayout: Utility.fetchLabelLayoutDetails(labelObject: label.labelObject!))
                }
                else if subview is UICollectionView {
                    
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
                    
                    let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!) * Utility.getBaseScreenWidthMultiplier(), height: CGFloat(collectionGridLayout.gridHeight!) * Utility.getBaseScreenHeightMultiplier()), isHorizontalScroll: (collectionGridObject?.isHorizontalScroll)!, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
                    
                    collectionGrid?.collectionViewLayout = collectionViewFlowLayout
                    collectionGrid?.frame = Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!)
                    collectionGrid?.changeFrameHeight(height: (collectionGrid?.frame.size.height)! * Utility.getBaseScreenHeightMultiplier())
                    collectionGrid?.changeFrameYAxis(yAxis: (collectionGrid?.frame.origin.y)! * Utility.getBaseScreenHeightMultiplier())
                    
                    self.collectionGrid?.reloadData()
                }
                else if subview is SFSeparatorView {
                    
                    let separatorView:SFSeparatorView = subview as! SFSeparatorView
                    separatorView.relativeViewFrame = relativeViewFrame
                    separatorView.initialiseSeparatorViewFrameFromLayout(separatorViewLayout: Utility.fetchSeparatorViewLayoutDetails(separatorViewObject:separatorView.separtorViewObject!))
                }
            }
        }
    }
    
    
    //MARK: Collection Grid Cell Delegates
    func buttonClicked(button: SFButton, gridObject: SFGridObject?) {
        
        if button.buttonObject?.action == "watchVideo" {
            
            if delegate != nil {
                
                if (delegate?.responds(to: #selector(VerticalCollectionGridDelegate.didPlayVideo(contentId:button:gridObject:))))! {
                    
                    self.delegate?.didPlayVideo!(contentId: gridObject?.contentId, button: button, gridObject: gridObject)
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
                
                Utility.presentKiswePlayer(forEventId: eventId!, withFilmId: gridObject?.contentId ?? "",vc: self)
            }
            else{
                
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
}
