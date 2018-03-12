//
//  SearchHsitoryView_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 13/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

private let y_axis : Int =  0

private let titleFont = "OpenSans-Semibold"
private let labelFontSize = 20.0
private let labelTag = 200
private let cellTag = 250



@objc protocol SearchHistoryViewDelegate: class {
   @objc optional func searchTextTapped(searchText : String?)
   @objc  optional func clearPreviousSearchHistory()
    
}


class SearchHistoryView_tvOS: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    ///collectionView containes previous search terms.
    var collectionView : UICollectionView?
    
    ///stored property searchTextArray containes array of search term.
    var searchTextArray : Array<String>?
    
    
    /// clearHistoryBtn refernce to instance of UIButton.
    var clearHistoryBtn : SFButton?

    //Create  delegate property of SearchHsitoryViewDelegate.
    weak var delegate:SearchHistoryViewDelegate?
    
    
    deinit {
        //deinit called for dealloc resources.
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*setupSubView method is used to create subview's of previous search view sub module.*/
    func setupSubView() -> Void {
        createPreviousSearchText()
        createClearHistoryButton()
        createCollectionView()
    }
    
    
    /*Method to create search text*/
    private func createPreviousSearchText() {
        let label = UILabel.init(frame: CGRect(x: 240, y:y_axis, width: 230, height: 60))
        label.textAlignment = .center
        label.text = "PREVIOUS SEARCHES:"
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.textColor = UIColor.white
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        var fontWeight = "ExtraBold"
        
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Black"
        }
        
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Bold"
        }
        if UIFont.init(name: "\(fontFamily!)-\(fontWeight)", size: CGFloat(labelFontSize)) != nil {
            label.font = UIFont.init(name: "\(fontFamily!)-\(fontWeight)", size: CGFloat(labelFontSize))
            
        } else {
            label.font = UIFont.init(name: "\(fontFamily!)-Bold", size: CGFloat(labelFontSize))
        }
            
        self.view.addSubview(label)
    }
    
    
    private func createClearHistoryButton()
    {
        clearHistoryBtn = SFButton(frame: CGRect(x: 1426, y: 0, width: 255, height: 60))
        let buttonObject = SFButtonObject()
        buttonObject.textColor = AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff"
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        
        buttonObject.fontFamily = fontFamily!
        buttonObject.textFontSize = 18
        if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeEntertainment {
            buttonObject.borderWidth = 4
        } else {
            buttonObject.borderWidth = 2
        }
        buttonObject.text = "CLEAR HISTORY"
        buttonObject.borderColor = AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff"
        clearHistoryBtn?.buttonObject = buttonObject
        clearHistoryBtn?.createButtonView()
        clearHistoryBtn?.addTarget(self, action: #selector(SearchHistoryView_tvOS.clearPreviousHistoryBtnTapped(_:)), for: .primaryActionTriggered)
        self.view.addSubview(clearHistoryBtn!)
    }
    

    func clearPreviousHistoryBtnTapped(_ sender : UIButton) -> Void {
        print("\(String(describing: sender.titleLabel?.text))")
        
        delegate?.clearPreviousSearchHistory!()
    }
    
    
    func refreshCollectionView() -> Void{
        
        if (self.collectionView != nil && self.searchTextArray != nil && (self.searchTextArray?.count)! > 0)
        {
            self.collectionView?.reloadData()
        }
    }
    
    
    func createCollectionView() -> Void {
        
        //Create collection View frame
        let  collectionViewFrame = CGRect(x: 475, y: 0, width: 900 , height: self.view.bounds.size.height)
        
        //Create UICollectionViewFlowLayout layout instance.
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        //layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        //Create UICollection View.
        collectionView = UICollectionView.init(frame: collectionViewFrame, collectionViewLayout: layout);
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.clear
        
        //menuCollectionView?.clipsToBounds = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isScrollEnabled = true
        self.view.addSubview(collectionView!)
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchTextArray != nil && (self.searchTextArray?.count)! > 0
        {
            return (self.searchTextArray?.count)!
        }
        else{
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
       (cell.viewWithTag(labelTag) as? UILabel)?.removeFromSuperview()
        let  tempStr  =   self.searchTextArray?[indexPath.row]
        let stringWidth = calculateWidthOfText((self.searchTextArray?[indexPath.row])!)
        let lblFrame = CGRect(x: 0, y: 0, width: stringWidth.size.width, height: 60)
        
        //Create custom label
        let searchTextLabel = UILabel.init(frame: lblFrame)
        searchTextLabel.text = tempStr //menuArray[indexPath.row] as? String
        searchTextLabel.font = UIFont(name: titleFont, size: CGFloat(labelFontSize))
        searchTextLabel.textColor = UIColor.white
        searchTextLabel.textAlignment = .center
        searchTextLabel.center = cell.contentView.center;
        searchTextLabel.tag = labelTag
        searchTextLabel.textAlignment = NSTextAlignment.center
        cell.tag = cellTag
        cell.contentView.addSubview(searchTextLabel);
        return cell
    }
    
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        delegate?.searchTextTapped!(searchText: self.searchTextArray?[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator){
        if let previousCell = context.previouslyFocusedView as? UICollectionViewCell {
            if previousCell.tag == cellTag
            {
                (previousCell.viewWithTag(labelTag) as! UILabel).textColor = UIColor.white
            }
            
        }
        if let nextCell = context.nextFocusedView as? UICollectionViewCell {
            
            if nextCell.tag == cellTag
            {
                (nextCell.viewWithTag(labelTag) as! UILabel).textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
            }
        }
    }
    
    //MARK:- UICollectionViewFlow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let cellFrame = calculateWidthOfText((self.searchTextArray?[indexPath.row])!)
        let sizeOfItem =  CGSize(width: cellFrame.size.width > 250 ? cellFrame.size.width : 250 , height: 60)
        return sizeOfItem;
    }
    
    
    //MARK: - ViewController Update focus method
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

    }
    
    
    //MARK: - Helper methods
    func calculateWidthOfText (_ menuTitle : String ) -> CGRect
    {
        let font : UIFont = UIFont(name: titleFont, size: CGFloat(labelFontSize + 2))!
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuTitle.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return  boundingBox
    }
    
}
