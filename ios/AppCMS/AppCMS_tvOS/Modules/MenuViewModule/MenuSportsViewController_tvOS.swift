//
//  MenuSportsViewController_tvOS.swift
//  AppCMS
//
//  Created by Rajni Pathak on 03/11/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

private var cellHeight : CGFloat =  160.0
private let  MenuTitleTag = 102
private let  cellMaxWidth : CGFloat =  180.0

class MenuSportsViewController_tvOS: MenuBaseViewController_tvOS, UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, SFButtonDelegate {
    private let reuseIdentifier = "cell"
    
    private var subscribeNowButton: SFButton?
    
    //Property menuCollectionView renders collection of menu.
    var  menuCollectionView :   UICollectionView?
    
    //Property menuArray holds collection of menu.
    var  menuArray : Array<PageTuple>
    
    //MARK: - Private properties
    //Property collectionViewWidth property holds width of Collection View .
    private  var collectionViewWidth : Float = 0
    
    //Property focusedMenuTitleFont holds font NAME when cell is in focused state.
    private   var focusedMenuTitleFont  : String
    
    //Property focusedMenuTitleFontSize holds font SIZE when cell is in focused state.
    private  var focusedMenuTitleFontSize  : CGFloat

    
    private var menuCreated : Bool = false
    //Property used for storing last focus Item.
    //private var  lastFocusedMenuIndex : IndexPath?
    private var  lastFocusedMenuIndexPath = IndexPath(row: 1, section: 0)
    private var collectionGridObject:SFCollectionGridObject?
    
//    override var preferredFocusedView : UIView? {
//        return (self.menuCollectionView)!
//    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let viewToBeFocused = self.menuCollectionView {
            return [viewToBeFocused]
        } else {
            return super.preferredFocusEnvironments
        }
    }
    
    //MARK: - init Method
    //initialise properties of class in init method.
    init(menuArray : Array<PageTuple>) {
        self.menuArray = menuArray
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        self.focusedMenuTitleFont = fontFamily!
        self.focusedMenuTitleFontSize = 22
        super.init(nibName: nil, bundle: nil)
    }
    
    
    //MARK: -  deinit Method
    //deinit Method is called when
    deinit {
        print("Menu Collection view is going to be deinitialise  ")
        NotificationCenter.default.removeObserver(self, name: Constants.kToggleMenuBarNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(setNeedsFocusUpdate), name: Constants.kToggleMenuBarNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func setNeedsFocusUpdate() {
        super.setNeedsFocusUpdate()
        if (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) ?? false {
            subscribeNowButton?.isUserInteractionEnabled = false
            subscribeNowButton?.isHidden = true
        } else {
            subscribeNowButton?.isUserInteractionEnabled = true
            subscribeNowButton?.isHidden = false
        }

    }
  
    /// Method to fetch Page's Module List.
    override func fetchPageModuleList()
    {
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.backgroundColor ?? "#ffffff")
        let menuViewParser = SFMenuViewParser()
        let menuViewObject = menuViewParser.parseMenuModuleJson()
        if menuViewObject.layoutObjectDict.isEmpty == false {
            self.createModules(menuViewObject: menuViewObject)
        }
    }
    
    
    /// Method to create modules for the page.
    private func createModules(menuViewObject : SFMenuViewObject) {
        for component:AnyObject in (menuViewObject.components) {
            if component is SFCollectionGridObject {
                collectionGridObject = component as? SFCollectionGridObject
                createMenuCollectionView()
            }
            if component is SFLabelObject {
                createLabelView(labelObject: component as! SFLabelObject)
            }
            if component is SFButtonObject {
                createButtonView(buttonObject: component as! SFButtonObject)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Creation of Grid View
    private func createMenuCollectionView() {
        let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject!)
        createCollectionView(collectionGridLayout: collectionGridLayout)
    }
    
    private func createLabelView(labelObject: SFLabelObject){
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        let label:SFLabel = SFLabel(frame: CGRect.zero)
        label.labelObject = labelObject
        label.labelLayout = labelLayout
        label.relativeViewFrame = self.view.frame
        label.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
        label.text = labelObject.text
        label.createLabelView()
        label.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor ?? "#ffffff")
        self.view.addSubview(label)
    }
    
    private func createButtonView(buttonObject: SFButtonObject){
        let buttonLayout = Utility.fetchButtonLayoutDetails(buttonObject: buttonObject)
        let button:SFButton = SFButton(frame: CGRect.zero)
        button.buttonObject = buttonObject
        button.buttonLayout = buttonLayout
        button.relativeViewFrame = self.view.frame
        button.initialiseButtonFrameFromLayout(buttonLayout: buttonLayout)
        button.buttonDelegate = self
        button.createButtonView()
        button.titleLabel?.text = buttonObject.text
        if button.buttonObject?.key == "startFreeTrial"  {
            subscribeNowButton = button
            let isSubscribed = (Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kIsSubscribedKey) as? Bool) ?? false
            if isSubscribed {
                button.isHidden = true
                button.isUserInteractionEnabled = false
                
            } else {
                button.isHidden = false
                button.isUserInteractionEnabled = true
            }
            var stringForBanner = ""
            if let buttonPrefixText = AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonPrefixText {
                stringForBanner.append(buttonPrefixText)
            }
            if let buttonText = AppConfiguration.sharedAppConfiguration.pageHeaderObject?.buttonText {
                stringForBanner.append(buttonText)
            }
            button.setTitle(stringForBanner, for: UIControlState.normal)
        }
        self.view.addSubview(button)
    }
    
    
    //MARK: SFButton Delegate.
    func buttonClicked(button: SFButton) {
        if button.buttonObject?.key == "startFreeTrial" {
            Constants.kAPPDELEGATE.appContainerVC?.openSubContainerView(contentToLoad: .loadPlansPage)
        }
    }

    func createCollectionView(collectionGridLayout:LayoutObject) {
        cellHeight = CGFloat(collectionGridLayout.gridHeight ?? 160)
        // Handling multiple menu creation issue.
        if menuCreated == true {
            return
        }
        //Calculate the collection View Width
        collectionViewWidth =  self.calculateWidthOfCollectionView()
        //Get screen view width
        let screenWidth : Float = Float(self.view.frame.size.width)
        
        //If collection view width is more than screen size width then set
        //width of collection view as screen width
        if( collectionViewWidth  >  screenWidth)
        {
            collectionViewWidth = screenWidth
        }
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        //Create UICollectionViewFlowLayout layout instance.
        let collectionViewFlowLayout:SFCollectionGridFlowLayout = SFCollectionGridFlowLayout(gridItemSize: CGSize(width: CGFloat(collectionGridLayout.gridWidth!), height: CGFloat(collectionGridLayout.gridHeight!)), isHorizontalScroll: true, gridPadding: collectionGridLayout.trayPadding != nil ? CGFloat((collectionGridLayout.trayPadding)!) : 0.0)
        
        //Create UICollection View.
        menuCollectionView = UICollectionView(frame: Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: self.view.frame), collectionViewLayout: collectionViewFlowLayout)
        menuCollectionView?.center = self.view.center
        menuCollectionView?.changeFrameWidth(width: CGFloat(collectionViewWidth))
        menuCollectionView?.register(MenuSportsCollectionCell_tvOS.self, forCellWithReuseIdentifier: reuseIdentifier)
        menuCollectionView?.delegate = self
        menuCollectionView?.dataSource = self
        menuCollectionView?.backgroundColor = UIColor.clear
        if #available(tvOS 11.0, *) {
            self.menuCollectionView?.contentInsetAdjustmentBehavior = .never
        }
        menuCollectionView?.showsVerticalScrollIndicator = false
        menuCollectionView?.showsHorizontalScrollIndicator = false
        menuCollectionView?.isScrollEnabled = true
        menuCollectionView?.center = self.view.center
        
        backgroundFocusGuide.preferredFocusedView = menuCollectionView

        //Add UICollectionView as sub view.
        if menuCollectionView != nil {
            self.view.addSubview(menuCollectionView!)
            menuCreated = true
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menuCell:MenuSportsCollectionCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuSportsCollectionCell_tvOS
        menuCell.tag = indexPath.row
        menuCell.cellComponents = (collectionGridObject?.trayComponents)!
        menuCell.menuTitle = menuArray[indexPath.row].pageName
        menuCell.menuIcon = menuArray[indexPath.row].pageIcon
        menuCell.updateCellView()
        return menuCell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        if let previousCell = context.previouslyFocusedView as? MenuSportsCollectionCell_tvOS {
            let view = previousCell.viewWithTag(MenuTitleTag) as? SFImageView
            view?.backgroundColor = UIColor.clear
            let tag = previousCell.tag
            let imgString = menuArray[tag].pageIcon
            if imgString.lowercased().range(of:"http") == nil {
                if let textColor = AppConfiguration.sharedAppConfiguration.secondaryButton.textColor {
                    view?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    view?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                }
            }
            
        }
        
        if let nextCell = context.nextFocusedView as? MenuSportsCollectionCell_tvOS {
            let view = nextCell.viewWithTag(MenuTitleTag) as? SFImageView
            view?.backgroundColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryButton.backgroundColor ?? "#000000")
            let tag = nextCell.tag
            let imgString = menuArray[tag].pageIcon
            if imgString.lowercased().range(of:"http") == nil {
                if let textColor = AppConfiguration.sharedAppConfiguration.primaryButton.textColor {
                    view?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    view?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                }
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        lastFocusedMenuIndexPath = indexPath;
        //Item selected at Index path
        delegate?.menuSelected(menuSelectedAtIndex: indexPath.row)
//        NotificationCenter.default.post(name: Constants.kMenuButtonTapped, object: nil , userInfo : nil)
    }
    
    //MARK:- UICollectionViewFlow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let sizeOfItem =  CGSize(width: cellMaxWidth , height: cellHeight)
        return sizeOfItem
    }
    
    func  indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return lastFocusedMenuIndexPath as IndexPath
    }

    
    func calculateWidthOfCollectionView() -> Float
    {
        var frameWidth : Float = 0
        frameWidth = Float(menuArray.count) * Float(cellMaxWidth)
        return frameWidth
    }
 
}

//Class to differentiate between different cells on focus.
class MenuSportsCollectionCell_tvOS : UICollectionViewCell {
    var menuTitleLabel:SFLabel?
    var menuThumbnailImage:SFImageView?
    var cellComponents:Array<Any> = []
    var menuTitle:String?
    var menuIcon:String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCellView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: method to create cell view
    private func createCellView() {
        menuTitleLabel = SFLabel()
        self.addSubview(menuTitleLabel!)
        menuTitleLabel?.isHidden = true
        
        
        menuThumbnailImage = SFImageView()
        self.addSubview(menuThumbnailImage!)
        menuThumbnailImage?.isHidden = true
        menuThumbnailImage?.tag = MenuTitleTag
       
    }
    
    func updateCellView() {
        for cellComponent in cellComponents {
            
            if cellComponent is SFLabelObject {
                
                updateLabelView(labelObject: cellComponent as! SFLabelObject)
            }
            else if cellComponent is SFImageObject {
                
                updateImageView(imageObject: cellComponent as! SFImageObject)
            }
        }
    }
    
    
    //MARK: Update label view
    private func updateLabelView(labelObject:SFLabelObject) {
        
        let labelLayout = Utility.fetchLabelLayoutDetails(labelObject: labelObject)
        if labelObject.key != nil && labelObject.key == "menuTitle" {
            menuTitleLabel?.isHidden = false
            menuTitleLabel?.relativeViewFrame = self.frame
            menuTitleLabel?.labelObject = labelObject
            menuTitleLabel?.labelLayout = labelLayout
            menuTitleLabel?.text = menuTitle?.uppercased()
            menuTitleLabel?.initialiseLabelFrameFromLayout(labelLayout: labelLayout)
            menuTitleLabel?.createLabelView()
            if AppConfiguration.sharedAppConfiguration.appTextColor != nil {
                
                menuTitleLabel?.textColor = Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.appTextColor!)
            }
        }
    }
    
    //MARK: Update label view
    private func updateImageView(imageObject:SFImageObject) {
        
        let imageLayout = Utility.fetchImageLayoutDetails(imageObject: imageObject)
        if imageObject.key != nil && imageObject.key == "menuThumbnailImage" {
            menuThumbnailImage?.relativeViewFrame = self.frame
            menuThumbnailImage?.isHidden = false
            menuThumbnailImage?.initialiseImageViewFrameFromLayout(imageLayout: imageLayout)
            menuThumbnailImage?.imageViewObject = imageObject
            menuThumbnailImage?.updateView()
            menuThumbnailImage?.contentMode = .scaleAspectFit
            menuThumbnailImage?.changeFrameXAxis(xAxis: (self.frame.width - (menuThumbnailImage?.frame.width)!)/2)
            menuThumbnailImage?.layer.borderWidth = 1.0
            menuThumbnailImage?.layer.borderColor = UIColor.white.cgColor
            guard let imgString = menuIcon?.lowercased() else{
                    return            }
            if imgString.lowercased().range(of:"http") != nil {
                var imageURL = imgString
                imageURL = imageURL.trimmingCharacters(in: .whitespaces)
                if imageURL.isEmpty == false {
                    menuThumbnailImage?.af_setImage(
                        withURL: URL(string: imageURL)!,
                        placeholderImage: nil,
                        filter: nil,
                        imageTransition: .crossDissolve(0.2)
                    )
                }
            } else{
                menuThumbnailImage?.image = UIImage(named: imgString)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
                if let textColor = AppConfiguration.sharedAppConfiguration.secondaryButton.textColor {
                    menuThumbnailImage?.tintColor = Utility.hexStringToUIColor(hex: textColor)
                    menuThumbnailImage?.layer.borderColor = Utility.hexStringToUIColor(hex: textColor).cgColor
                }
            }
        }
    }
}

