//
//  MenuViewController_tvOS.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 15/06/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit

private let cellFrameSize : Float =  250.0
private let cellHeight : CGFloat =  140.0
private let  MenuTitleTag = 102


class MenuViewController_tvOS: MenuBaseViewController_tvOS, UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private let padding : CGFloat =  70.0
    
    private let reuseIdentifier = "cell"
    //Property menuCollectionView renders collection of menu.
    var  menuCollectionView :   UICollectionView?
    
    //Property menuArray holds collection of menu.
    var  menuArray : Array<PageTuple>
    
    
    /// UIView instance which shows the selected cell.
    var menuSelectedBar : UIView?
    
    var tagOfMenu: Int?
     //MARK: - Private properties
    //Property collectionViewWidth property holds width of Collection View .
    private  var collectionViewWidth : Float = 0
    
    //Property focusedMenuTitleFont holds font NAME when cell is in focused state.
    private   var focusedMenuTitleFont  : String
    
    //Property unFocusedMenuTitleFont holds font NAME when cell is in unfocused state.
    private  var unFocusedMenuTitleFont  : String
    
    //Property focusedMenuTitleFontSize holds font SIZE when cell is in focused state.
    private  var focusedMenuTitleFontSize  : CGFloat
    
    //Property unFocusedMenuTitleFontSize holds font SIZE when cell is in unfocused state.
    private  var unFocusedMenuTitleFontSize  : CGFloat
    
    private var menuCreated : Bool = false
    //Property used for storing last focus Item.
    //private var  lastFocusedMenuIndex : IndexPath?
    private var  lastFocusedMenuIndexPath = IndexPath(row: 0, section: 0)
    
    var FocusedNeedToBeUpdated = false
    
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
    
    //    override var preferredFocusEnvironments : [UIFocusEnvironment] {
    //        //Condition
    //        return [self.menuCollectionView!]
    //    }
    
    
    //MARK: - init Method
    //initialise properties of class in init method.
    init(menuArray : Array<PageTuple>) {
        var fontFamily:String?
        if let _fontFamily = AppConfiguration.sharedAppConfiguration.appFontFamily {
            fontFamily = _fontFamily
        }
        if fontFamily == nil {
            fontFamily = "OpenSans"
        }
        self.menuArray = menuArray
        var fontWeight = "ExtraBold"
        
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Black"
        }
        
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Bold"
        }

        self.focusedMenuTitleFont = "\(fontFamily!)-\(fontWeight)"
        self.unFocusedMenuTitleFont = "\(fontFamily!)-Semibold"
        self.focusedMenuTitleFontSize = 28
        self.unFocusedMenuTitleFontSize = 28
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
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func fetchPageModuleList() {
        self.createMenuCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Crate menu collection and add it on current view.
    func createMenuCollectionView() -> Void {
        self.view.backgroundColor = Utility.hexStringToUIColor(hex: "#24282b")
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
        
        //Create collection View frame
        let  menuCollectionViewFrame = CGRect(x: 0, y: 0, width: Int(collectionViewWidth) , height: 140)
        
        //Create UICollectionViewFlowLayout layout instance.
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        //layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        //Create UICollection View.
        menuCollectionView = UICollectionView.init(frame: menuCollectionViewFrame, collectionViewLayout: layout);
        menuCollectionView?.register(MenuCollectionCell_tvOS.self, forCellWithReuseIdentifier: reuseIdentifier)
        menuCollectionView?.delegate = self
        menuCollectionView?.dataSource = self
        menuCollectionView?.backgroundColor = UIColor.clear
        
        if #available(tvOS 11.0, *) {
            self.menuCollectionView?.contentInsetAdjustmentBehavior = .never
        }
        
        //menuCollectionView?.clipsToBounds = false
        menuCollectionView?.showsVerticalScrollIndicator = false
        menuCollectionView?.showsHorizontalScrollIndicator = false
        menuCollectionView?.isScrollEnabled = true
        menuCollectionView?.center = self.view.center;
        
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
        let menuCell : MenuCollectionCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MenuCollectionCell_tvOS
        
        let lbl = menuCell.viewWithTag(MenuTitleTag) as? UILabel
        if let lbl = lbl {
            lbl.removeFromSuperview()
        }
        
        let lblFrame = CGRect(x: 0, y: 0, width: menuCell.contentView.bounds.size.width, height: 38)
        
        //Create custom label
        let menuTitleLabel = UILabel.init(frame: lblFrame)
        menuTitleLabel.text = menuArray[indexPath.row].pageName.uppercased()
        menuTitleLabel.font = UIFont(name: self.unFocusedMenuTitleFont, size: self.unFocusedMenuTitleFontSize)
        menuTitleLabel.textColor = UIColor.white
        menuTitleLabel.tag = MenuTitleTag
        menuTitleLabel.textAlignment = .center
        menuTitleLabel.center = menuCell.contentView.center;
        menuCell.contentView.addSubview(menuTitleLabel);
        menuCell.tag = indexPath.row
        menuCell.menuTag = tagOfMenu
        return menuCell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        
            if let previousCell = context.previouslyFocusedView as? MenuCollectionCell_tvOS {
                removeMenuSelectedBar()
                let lbl = previousCell.viewWithTag(MenuTitleTag) as? UILabel
                lbl?.font = UIFont(name: self.unFocusedMenuTitleFont, size: self.unFocusedMenuTitleFontSize)
            }
            
            if let nextCell = context.nextFocusedView as? MenuCollectionCell_tvOS {
                nextCell.contentView.addSubview(getMenuSelectedBar(nextCell))
                let lbl = nextCell.viewWithTag(MenuTitleTag) as? UILabel
                lbl?.font = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize)
                
            }
    }
    
    func getMenuSelectedBar(_ cell : UICollectionViewCell) -> UIView {
        
        if menuSelectedBar == nil {
            let borderFrame =  CGRect(x: 0, y: 0, width: cell.contentView.frame.size.width, height: 10)
            menuSelectedBar = UIView.init(frame: borderFrame)
            menuSelectedBar?.backgroundColor =  Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
        }
        menuSelectedBar?.changeFrameWidth(width: cell.contentView.frame.size.width)
        return menuSelectedBar!
    }
    
    func removeMenuSelectedBar() {
        if menuSelectedBar != nil {
            menuSelectedBar?.removeFromSuperview()
            menuSelectedBar = nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        FocusedNeedToBeUpdated = true;
        lastFocusedMenuIndexPath = indexPath;
        //Item selected at Index path
        delegate?.menuSelected(menuSelectedAtIndex: indexPath.row)
//        NotificationCenter.default.post(name: Constants.kMenuButtonTapped, object: nil , userInfo : nil)
    }
    
    //MARK:- UICollectionViewFlow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let menuItem =  menuArray[indexPath.row].pageName
        guard let font = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize + 2) else {
            return .zero
        }
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuItem.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        let widthOfItem = boundingBox.width + padding
        let sizeOfItem =  CGSize(width: widthOfItem , height: cellHeight)
        
        return sizeOfItem;
    }
    
    func  indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        return lastFocusedMenuIndexPath as IndexPath
    }
    
    
    //MARK: - Helper methods
    func calculateWidthOfText (_ menuTitle : String ) -> CGRect
    {
        guard let font = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize + 2) else {
            return CGRect.zero
        }
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuTitle.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return  boundingBox
    }
    
    func calculateWidthOfCollectionView() -> Float
    {
        var frameWidth : Float = 0
        for item in  menuArray {//menuArray  {
            let tempStr : String =    item.pageName//(item as? String)!
            let rectSize : CGRect = self.calculateWidthOfText(tempStr)
            frameWidth += Float(rectSize.width)
            frameWidth += Float(padding)
        }
        return frameWidth;
    }
    
   
    
}

//Class to differentiate between different cells on focus.
class MenuCollectionCell_tvOS : UICollectionViewCell {
    
    var menuTag : Int?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = 9999
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tag = 9999
    }
}

class SubMenuViewController_tvOS: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    private let padding : CGFloat =  70.0
    private let reuseIdentifier = "subMenuCell"
    
    var sizeOfItemsArray:Array<CGSize>?
    
    //Property menuCollectionView renders collection of menu.
    var  menuCollectionView :   UICollectionView?
    
    //Property menuArray holds collection of menu.
    var  menuArray : Array<PageTuple>
    
    
    /// UIView instance which shows the selected cell.
    var menuSelectedBar : UIView?
    
    var tagOfMenu: Int?
    
    //MARK: - Delegate property
    //Create  delegate property of MenuViewControllerDelegate.
    weak var delegate:MenuViewControllerDelegate?
    
    //Property focusedMenuTitleFont holds font NAME when cell is in focused state.
    private   var focusedMenuTitleFont  : String
    
    //Property unFocusedMenuTitleFont holds font NAME when cell is in unfocused state.
    private  var unFocusedMenuTitleFont  : String
    
    //Property focusedMenuTitleFontSize holds font SIZE when cell is in focused state.
    private  var focusedMenuTitleFontSize  : CGFloat
    
    //Property unFocusedMenuTitleFontSize holds font SIZE when cell is in unfocused state.
    private  var unFocusedMenuTitleFontSize  : CGFloat
    
    private var menuCreated : Bool = false
    //Property used for storing last focus Item.
    //private var  lastFocusedMenuIndex : IndexPath?
    private var  lastFocusedMenuIndexPath = IndexPath(row: 0, section: 0)
        
    var FocusedNeedToBeUpdated = false
    
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
    
    //    override var preferredFocusEnvironments : [UIFocusEnvironment] {
    //        //Condition
    //        return [self.menuCollectionView!]
    //    }
    
    
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
        self.menuArray = menuArray
        var fontWeight = "ExtraBold"
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Black"
        }
        
        if let _ = UIFont(name: "\(fontFamily!)-\(fontWeight)", size: 28) {} else {
            fontWeight = "Bold"
        }
        
        self.focusedMenuTitleFont = "\(fontFamily!)-\(fontWeight)"
        self.unFocusedMenuTitleFont = "\(fontFamily!)-Semibold"
        self.focusedMenuTitleFontSize = 28
        self.unFocusedMenuTitleFontSize = 28
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
    
    override func viewDidAppear(_ animated: Bool) {
        self.createMenuCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateCollectionView() {
        menuCollectionView?.setNeedsFocusUpdate()
        menuCollectionView?.updateFocusIfNeeded()
    }
    
    func updateSelectedMenuOption(_ index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        lastFocusedMenuIndexPath = indexPath
        updateCollectionView()
    }
    
    func refreshMenuWithArray(menuArray : Array<PageTuple>) {
        self.menuArray = menuArray
        self.updateCollectionViewFrame()
        self.menuCollectionView?.reloadData()
    }
    
    //Crate menu collection and add it on current view.
    func createMenuCollectionView() -> Void {
        
        // Handling multiple menu creation issue.
        if menuCreated == true {
            return
        }
        
        //Create UICollectionViewFlowLayout layout instance.
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        //layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let backgroundFocusGuide : UIFocusGuide = UIFocusGuide()
        self.view.addLayoutGuide(backgroundFocusGuide)
        backgroundFocusGuide.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundFocusGuide.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundFocusGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        backgroundFocusGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        //Create UICollection View.
        menuCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout);
        menuCollectionView?.register(SubMenuCollectionCell_tvOS.self, forCellWithReuseIdentifier: reuseIdentifier)
        menuCollectionView?.delegate = self
        menuCollectionView?.dataSource = self
        menuCollectionView?.backgroundColor = UIColor.clear
        
        //menuCollectionView?.clipsToBounds = false
        menuCollectionView?.showsVerticalScrollIndicator = false
        menuCollectionView?.showsHorizontalScrollIndicator = false
        menuCollectionView?.isScrollEnabled = true
        
        backgroundFocusGuide.preferredFocusedView = menuCollectionView
        
        //Add UICollectionView as sub view.
        if menuCollectionView != nil {
            self.view.addSubview(menuCollectionView!)
            menuCreated = true
        }
        
        self.updateCollectionViewFrame()
    }
    
    private func updateCollectionViewFrame() {
        sizeOfItemsArray = nil
        let menuCollectionViewFrame = CGRect(x: 0, y: 0, width: Int(self.calculateWidthOfCollectionView()) , height: 140)
        menuCollectionView?.frame = menuCollectionViewFrame
        menuCollectionView?.center = self.view.center
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let menuCell : SubMenuCollectionCell_tvOS = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SubMenuCollectionCell_tvOS
        
        let lbl = menuCell.viewWithTag(MenuTitleTag) as? UILabel
        if let lbl = lbl {
            lbl.removeFromSuperview()
        }
        
        let sizeOfLabel = sizeOfItemsArray?[indexPath.row]
        let lblFrame = CGRect(x: 0, y: 72, width: (sizeOfLabel?.width)!, height: 38)
        
        //Show highlighted cell first time.
        updateOnFocusShift()
        
        //Create custom label
        let menuTitleLabel = UILabel()
        menuTitleLabel.frame = lblFrame
        menuTitleLabel.text = menuArray[indexPath.row].pageName.uppercased()
        menuTitleLabel.font = UIFont(name: self.unFocusedMenuTitleFont, size: self.unFocusedMenuTitleFontSize)
        menuTitleLabel.textColor = UIColor.white
        menuTitleLabel.tag = MenuTitleTag
        menuTitleLabel.textAlignment = .center
        menuCell.contentView.addSubview(menuTitleLabel);
        menuCell.tag = indexPath.row
        menuCell.menuTag = tagOfMenu
        return menuCell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    {
        
        if let previousCell = context.previouslyFocusedView as? SubMenuCollectionCell_tvOS {
            if context.nextFocusedView is SubMenuCollectionCell_tvOS == true {
                setUnfocusedStateForCell()
            }
            let lbl = previousCell.viewWithTag(MenuTitleTag) as? UILabel
            lbl?.font = UIFont(name: self.unFocusedMenuTitleFont, size: self.unFocusedMenuTitleFontSize)
        }
        
        if let nextCell = context.nextFocusedView as? SubMenuCollectionCell_tvOS {
            nextCell.contentView.addSubview(getMenuSelectedBar(nextCell))
            let lbl = nextCell.viewWithTag(MenuTitleTag) as? UILabel
            lbl?.font = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize)
            
        } else {
            updateOnFocusShift()
        }
    }
    
    func updateOnFocusShift() {
        setUnfocusedStateForCell()
        let focusedCell = menuCollectionView?.cellForItem(at: lastFocusedMenuIndexPath)
        if (focusedCell != nil) {
            focusedCell?.contentView.addSubview(getMenuSelectedBar(focusedCell!))
            let lbl = focusedCell?.viewWithTag(MenuTitleTag) as? UILabel
            lbl?.font = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize)
        }
    }
    
    func getMenuSelectedBar(_ cell : UICollectionViewCell) -> UIView {
        
        let titleLabel = cell.viewWithTag(MenuTitleTag) as! UILabel
        let widthOfMenuBar = calculateWidthOfText(titleLabel.text!).size.width
        let borderFrame =  CGRect(x: ((cell.bounds.size.width - widthOfMenuBar)/2), y: 121, width: widthOfMenuBar, height: 8)
        if menuSelectedBar == nil {
            menuSelectedBar = UIView.init(frame: borderFrame)
            menuSelectedBar?.backgroundColor =  Utility.hexStringToUIColor(hex: AppConfiguration.sharedAppConfiguration.primaryHoverColor ?? "000000")
        } else {
            menuSelectedBar?.frame = borderFrame
        }
        return menuSelectedBar!
    }
    
    func setUnfocusedStateForCell() {
        if menuSelectedBar != nil {
            menuSelectedBar?.removeFromSuperview()
            menuSelectedBar = nil
        }
//        let focusedCell = menuCollectionView?.cellForItem(at: lastFocusedMenuIndexPath)
//        if (focusedCell != nil) {
//            let lbl = focusedCell?.viewWithTag(MenuTitleTag) as? UILabel
//            lbl?.font = UIFont(name: self.unFocusedMenuTitleFont, size: self.unFocusedMenuTitleFontSize)
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        FocusedNeedToBeUpdated = true;
        lastFocusedMenuIndexPath = indexPath;
        //Item selected at Index path
        delegate?.menuSelected(menuSelectedAtIndex: indexPath.row)
        NotificationCenter.default.post(name: Constants.kMenuButtonTapped, object: nil , userInfo : nil)
    }
    
    //MARK:- UICollectionViewFlow Delegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if sizeOfItemsArray == nil {
            sizeOfItemsArray = Array<CGSize>()
        }
        if (sizeOfItemsArray?.count)! ==  menuArray.count {
            return sizeOfItemsArray![indexPath.row]
        } else {
            let menuItem =  menuArray[indexPath.row].pageName
            let font : UIFont = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize + 2)!
            let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            let boundingBox = menuItem.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            let widthOfItem = boundingBox.width + padding
            let sizeOfItem =  CGSize(width: widthOfItem , height: cellHeight)
            sizeOfItemsArray?.append(sizeOfItem)
            return sizeOfItem
        }
    }
    
    func  indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        if let currentFocusedView = UIScreen.main.focusedView as? SubMenuCollectionCell_tvOS {
            let indexPath = menuCollectionView?.indexPath(for: currentFocusedView)
            if indexPath != lastFocusedMenuIndexPath {
                menuCollectionView?.reloadData()
            }
        }
        return lastFocusedMenuIndexPath as IndexPath
    }
    
    
    //MARK: - Helper methods
    func calculateWidthOfText (_ menuTitle : String ) -> CGRect
    {
        let font : UIFont = UIFont(name: self.focusedMenuTitleFont, size: self.focusedMenuTitleFontSize + 2)!
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuTitle.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return  boundingBox
    }
    
    func calculateWidthOfCollectionView() -> Float
    {
        var frameWidth : Float = 0
        for item in  menuArray {//menuArray  {
            let tempStr : String =    item.pageName//(item as? String)!
            let rectSize : CGRect = self.calculateWidthOfText(tempStr)
            frameWidth += Float(rectSize.width)
            frameWidth += Float(padding)
        }
        //Get screen view width
        let screenWidth : Float = Float(self.view.frame.size.width)
        
        //If collection view width is more than screen size width then set
        //width of collection view as screen width
        if( frameWidth  >  screenWidth) {
            frameWidth = screenWidth
        }
        return frameWidth
    }
    
    //MARK: - Make User Interaction enable/disable for collectionView
    func toggleUserInteraction(_ value : Bool) -> Void {
        self.view?.isUserInteractionEnabled = value
    }
    
//    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//        menuCollectionView?.setNeedsFocusUpdate()
//        menuCollectionView?.updateFocusIfNeeded()
//    }
    
}

//Class to differentiate between different cells on focus.
class SubMenuCollectionCell_tvOS : UICollectionViewCell {
    
    var menuTag : Int?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tag = 9999
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.tag = 9999
    }
}

