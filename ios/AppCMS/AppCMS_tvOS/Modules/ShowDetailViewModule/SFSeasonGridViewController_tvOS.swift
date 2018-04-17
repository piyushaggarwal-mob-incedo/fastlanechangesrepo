//
//  SeasonGridViewController.swift
//  AppCMS
//
//  Created by Gaurav Vig on 21/09/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

@objc protocol SFSeasonGridDelegate:NSObjectProtocol {
    @objc func playSelectedEpisode(showObject: SFShow, filmObject:SFFilm, nextEpisodesArray: Array<String>?) -> Void
}

class SFSeasonGridViewController_tvOS: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource {
    /// Holds the current section item.
    var currentSectionIndex : Int = 0
    var trayObject:SFTrayObject?
    var collectionGrid:UICollectionView?
    var collectionGridObject:SFCollectionGridObject?
    var relativeViewFrame:CGRect?
    var show:SFShow?
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
        
        
    }
    
    
    deinit {
        
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
            label.text = show?.seasons?[currentSectionIndex].title?.uppercased() ?? "SEASON \(currentSectionIndex + 1)"
        }
        
        self.view.addSubview(label)
        label.createLabelView()
        
        if labelObject.key == "trayTitle" {
            
            if AppConfiguration.sharedAppConfiguration.appPageTitleColor != nil {
                
                label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appPageTitleColor!)
            }
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
        
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: true, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 1.0)
        
        collectionGrid = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: relativeViewFrame!), collectionViewLayout: collectionViewFlowLayout)
        collectionGrid?.register(SFShowGridCell_tvOS.self, forCellWithReuseIdentifier: "Grids")
        if #available(tvOS 11.0, *) {
            self.collectionGrid?.contentInsetAdjustmentBehavior = .never
            self.collectionGrid?.contentInset = UIEdgeInsets.zero
        }
        collectionGrid?.delegate = self
        collectionGrid?.isScrollEnabled = true
        collectionGrid?.dataSource = self
        collectionGrid?.backgroundColor = UIColor.clear
        collectionGrid?.clipsToBounds = false
        collectionGrid?.isUserInteractionEnabled = true
        collectionGrid?.showsVerticalScrollIndicator = false
        collectionGrid?.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionGrid!)
        //self.view.sendSubview(toBack: collectionGrid!)
    }
    
    //MARK: CollectionView Delegates
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (show?.seasons?[currentSectionIndex].episodes!.count) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return (show?.seasons?.count)!
        return 1
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell:SFShowGridCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: "Grids", for: indexPath) as! SFShowGridCell_tvOS
        gridCell.gridComponents = (collectionGridObject?.trayComponents)!
        gridCell.thumbnailImageType = trayObject?.trayImageType
        gridCell.relativeViewFrame = gridCell.frame
        gridCell.film = show?.seasons?[currentSectionIndex].episodes![indexPath.row]
        gridCell.showGridCellDelegate = self as? SFShowGridCellDelegate
        gridCell.episodeNumber = indexPath.row + 1
        gridCell.updateGridSubView()
        
        return gridCell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if delegate != nil {
            let filmObject = show?.seasons?[currentSectionIndex].episodes![indexPath.row]
            //As we currently there is only 1 season
            let nextEpisodesArray:Array<String>? = self.fetchNextEpisodesToBeAutoPlayed(filmObject: filmObject!, seasonsArray: (show?.seasons)!, currentEpisodeIndex:indexPath.row, seasonIndex: currentSectionIndex)
            if (self.delegate != nil) && (self.delegate?.responds(to: #selector(self.delegate?.playSelectedEpisode(showObject:filmObject:nextEpisodesArray:))))!
            {
                self.delegate?.playSelectedEpisode(showObject:show!, filmObject: filmObject!, nextEpisodesArray:nextEpisodesArray ?? [])
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
    
    
    
}

