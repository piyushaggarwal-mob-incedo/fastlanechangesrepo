//
//  Utility.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 09/03/17.
//
//

import Foundation
import SSKeychain

class Utility: NSObject
{
    static let sharedUtility = Utility()
    
    private override init() {
    }
    
    //MARK: Method to get currency symbol from country code
    class func getSymbolForCurrencyCode(countryCode: String) -> String? {
        let locale = NSLocale(localeIdentifier: countryCode)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: countryCode)
    }
    
    //MARK: - Helper methods
    func calculateWidthOfText (_ menuTitle : String, _ titleFont: String, _ titleFontSize: CGFloat ) -> CGRect
    {
        let font : UIFont = UIFont(name: titleFont, size: titleFontSize + 2)!
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = menuTitle.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        return  boundingBox
    }
    
    class func getCurrentTypeValue(pageTypeName: String) -> Int
    {
        var pageTypeInt: Int = 0
        
        if pageTypeName == Constants.kSTRING_PAGETYPE_DEFAULT {
            pageTypeInt = 0
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_WEBPAGE {
            pageTypeInt = 1
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_NATIVE
        {
            pageTypeInt = 2
        }
        else if pageTypeName == Constants.kSTRING_PAGETYPE_MODULAR
        {
            pageTypeInt = 3
        }
        return pageTypeInt
    }
    
    class func hexStringToUIColor (hex:String) -> UIColor {
        
        var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(after: cString.startIndex))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.white
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    class func urlEncodedString_ch(emailStr: String) -> String {
        
        let output = NSMutableString()
        guard let source = emailStr.cString(using: String.Encoding.utf8) else {
            return emailStr
        }
        let sourceLen = source.count
        
        var i = 0
        while i < sourceLen - 1 {
            let thisChar = source[i]
            if thisChar == 32 {
                output.append("+")
            }
            else {
                output.appendFormat("%c", thisChar)
            }
            i += 1
        }
        
        return output as String
    }

    class func calculateCoordinateForSubView(marginPercent:Float, relativeViewCoordinate:Float) -> Float {
        
        let relativeCoordinate:Float
        
        relativeCoordinate = marginPercent * relativeViewCoordinate / 100
        
        return relativeCoordinate
    }
    
    class func initialiseViewLayout(viewLayout:LayoutObject, relativeViewFrame:CGRect) -> CGRect {
        
        var xAxis:Float = 0
        var yAxis:Float = 0
        var width:Float = 100
        var height:Float = 100
        
        let relativeViewWidth:Float = Float(relativeViewFrame.size.width)
        let relativeViewHeight:Float = Float(relativeViewFrame.size.height)
        
        if (viewLayout.xAxis != nil) {
            
            xAxis = viewLayout.xAxis!
        }
        else if viewLayout.isVerticallyCentered == true {
            
            xAxis = Float(UIScreen.main.bounds.size.width / 2) - viewLayout.width!/2
        }
        else if (viewLayout.leftMargin != nil) {
            
            xAxis = Utility.calculateCoordinateForSubView(marginPercent: viewLayout.leftMargin!, relativeViewCoordinate: relativeViewWidth)
        }
        else if viewLayout.rightMargin != nil {
            
            xAxis = relativeViewWidth - Utility.calculateCoordinateForSubView(marginPercent: viewLayout.rightMargin!, relativeViewCoordinate: relativeViewWidth)
            xAxis = xAxis - viewLayout.width!
        }
        
        if (viewLayout.width != nil) {
            
            width = viewLayout.width!
        }
        else if (viewLayout.maxWidth != nil)
        {
            width = viewLayout.maxWidth!
        }
        else {
            
            width = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.rightMargin ?? 0.0) - (viewLayout.leftMargin ?? 0.0)), relativeViewCoordinate: relativeViewWidth)
        }
        
        if (viewLayout.yAxis != nil) {
            
            yAxis = viewLayout.yAxis!
        }
        else if (viewLayout.topMargin != nil) {
            yAxis = Utility.calculateCoordinateForSubView(marginPercent: viewLayout.topMargin!, relativeViewCoordinate: relativeViewHeight)
        }
        else if (viewLayout.bottomMargin != nil) {
            
            yAxis = relativeViewHeight - Utility.calculateCoordinateForSubView(marginPercent: viewLayout.bottomMargin!, relativeViewCoordinate: relativeViewHeight)
            yAxis = yAxis - viewLayout.height!
        }
        
        if (viewLayout.height != nil) {
            
            height = viewLayout.height!
        }
        else {
            
            height = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.bottomMargin ?? 0.0) - (viewLayout.topMargin ?? 0.0)), relativeViewCoordinate: relativeViewHeight)
        }
        
        let viewFrame:CGRect = CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(height))
        
        return viewFrame
    }
    
    class func fetchLabelLayoutDetails(labelObject:SFLabelObject) -> LayoutObject {
        
        var labelLayout:LayoutObject?
        labelLayout = labelObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return labelLayout!
    }
    
    class func fetchSwitchViewLayoutDetails(switchViewObject:SFSwitchViewObject) -> LayoutObject {
        
        var switchLayout:LayoutObject?
        switchLayout = switchViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return switchLayout!
    }
    
    class func fetchLoaderViewLayoutDetails(loaderObject:SFTimerLoaderViewObject) -> LayoutObject {
        
        var loaderLayout:LayoutObject?
        loaderLayout = loaderObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return loaderLayout!
    }
    
    class func fetchHeaderLayoutDetails(headerObject:SFHeaderViewObject) -> LayoutObject {
        
        var headerLayout:LayoutObject?
        headerLayout = headerObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return headerLayout!
    }
    
    class func fetchFooterLayoutDetails(footerObject:SFFooterViewObject) -> LayoutObject {
        
        var footerLayout:LayoutObject?
        footerLayout = footerObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return footerLayout!
    }
    
    class func fetchButtonLayoutDetails(buttonObject:SFButtonObject) -> LayoutObject {
        
        var buttonLayout:LayoutObject?
        buttonLayout = buttonObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return buttonLayout!
    }
    
    func fetchTableViewLayoutDetails(tableViewObject:SFTableViewObject) -> LayoutObject {
        
        var tableViewLayout:LayoutObject?
        tableViewLayout = tableViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return tableViewLayout!
    }
    
    class func fetchImageLayoutDetails(imageObject:SFImageObject) -> LayoutObject {
        
        var imageLayout:LayoutObject?
        imageLayout = imageObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return imageLayout!
    }
    
    class func fetchCarouselItemLayoutDetails(carouselObject:SFCarouselItemObject) -> LayoutObject {
        
        var carouselItemLayout:LayoutObject?
        carouselItemLayout = carouselObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return carouselItemLayout!
    }
    
    class func fetchTextViewLayoutDetails(textViewObject:SFTextViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        textViewLayout = textViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return textViewLayout!
    }
    
    
    class func fetchSeparatorViewLayoutDetails(separatorViewObject:SFSeparatorViewObject) -> LayoutObject {
        
        var separatorViewLayout:LayoutObject?
        separatorViewLayout = separatorViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return separatorViewLayout!
    }
    
    class func fetchCollectionGridLayoutDetails(collectionGridObject:SFCollectionGridObject) -> LayoutObject {
        
        var collectionGridLayout:LayoutObject?
        collectionGridLayout = collectionGridObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return collectionGridLayout!
    }
    
    class func fetchTrayLayoutDetails(trayObject:SFTrayObject) -> LayoutObject {
        
        var trayLayout:LayoutObject?
        trayLayout = trayObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return trayLayout!
    }
    
    class func fetchTextFieldLayoutDetails(textFieldObject:SFTextFieldObject) -> LayoutObject {
        
        var textFieldLayout:LayoutObject?
        textFieldLayout = textFieldObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return textFieldLayout!
    }
    
    
    class func fetchVideoDetailLayoutDetails(videoDetailObject: SFVideoDetailModuleObject) -> LayoutObject
    {
        var videoLayout:LayoutObject?
        videoLayout = videoDetailObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return videoLayout!
    }
    
    class func fetchShowDetailLayoutDetails(showDetailObject: SFShowDetailModuleObject) -> LayoutObject
    {
        var videoLayout:LayoutObject?
        videoLayout = showDetailObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return videoLayout!
    }
    
    class func fetchWatchlistLayoutDetails(watchListObject: SFWatchlistAndHistoryViewObject) -> LayoutObject
    {
        var layout:LayoutObject?
        layout = watchListObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return layout!
    }
    class func fetchSubMenuLayoutDetails(teamObject: SFSubNavigationViewObject) -> LayoutObject
    {
        var layout:LayoutObject?
        layout = teamObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return layout!
    }
    class func fetchLoginViewLayoutDetails(loginViewObject: LoginViewObject_tvOS) -> LayoutObject
    {
        var loginViewLayout:LayoutObject?
        loginViewLayout = loginViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return loginViewLayout!
    }
    
    class func fetchAncillaryViewLayoutDetails(ancillaryViewObject: AncillaryViewObject_tvOS) -> LayoutObject
    {
        var ancillaryViewLayout:LayoutObject?
        ancillaryViewLayout = ancillaryViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return ancillaryViewLayout!
    }
    
    class func fetchContactUsViewLayoutDetails(ContactUsViewObject: ContactUsViewObject_tvOS) -> LayoutObject
    {
        var contactUsViewLayout:LayoutObject?
        contactUsViewLayout = ContactUsViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return contactUsViewLayout!
    }
    
    class func fetchRawTextViewLayoutDetails(RawTextViewObject: SFRawTextViewObject) -> LayoutObject
    {
        var contactUsViewLayout:LayoutObject?
        contactUsViewLayout = RawTextViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return contactUsViewLayout!
    }
    
    class func fetchSubscriptionViewLayoutDetails(SubscriptionViewObject: SubscriptionViewObject_tvOS) -> LayoutObject
    {
        var subscriptionViewLayout:LayoutObject?
        subscriptionViewLayout = SubscriptionViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return subscriptionViewLayout!
    }
    class func fetchPlanMetaDataViewLayoutDetails(planMetaDataViewObject:SFPlanMetaDataViewObject) -> LayoutObject {
        
        var planMetaDataLayout:LayoutObject?
        planMetaDataLayout = planMetaDataViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return planMetaDataLayout!
    }

    class func fetchSettingsViewLayoutDetails(settingViewObject: SettingViewObject_tvOS) -> LayoutObject
    {
        var settingViewLayout:LayoutObject?
        settingViewLayout = settingViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return settingViewLayout!
    }
    
    class func fetchVideoPlayerViewLayoutDetails(viewObject: VideoPlayerModuleViewObject) -> LayoutObject
    {
        var viewLayout:LayoutObject?
        viewLayout = viewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return viewLayout!
    }

    class func fetchProgresViewLayoutDetails(progressViewObject:SFProgressViewObject) -> LayoutObject {
        
        var progressViewLayout:LayoutObject?
        progressViewLayout = progressViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return progressViewLayout!
    }
    
    class func fetchCarouselLayoutDetails(carouselViewObject:SFJumbotronObject) -> LayoutObject {
        
        var carouselViewLayout:LayoutObject?
        carouselViewLayout = carouselViewObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return carouselViewLayout!
    }
    
    class func fetchPageControlLayoutDetails(pageControlObject:SFPageControlObject) -> LayoutObject {
        
        var pageControlLayout:LayoutObject?
         pageControlLayout = pageControlObject.layoutObjectDict[Constants.kSTRING_AppleTV]
        return pageControlLayout!
    }
    
    class func addGradientToView(mainView:UIView) {
        
        let size = mainView.bounds.size
        let path:UIBezierPath = UIBezierPath.init()
        path.move(to: CGPoint(x: 0, y: size.height * 0.5))
        path.addLine(to: CGPoint(x: size.width, y: size.height * 0.5))
        path.addLine(to: CGPoint(x: size.width, y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        
        mainView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 10, height: 10)
        mainView.layer.shadowOpacity = 0.7
        mainView.layer.shadowRadius = 50
        mainView.layer.shadowPath = path.cgPath
    }
    
    func presentAlertController(alertTitle: String, alertMessage:String, alertActions:Array<UIAlertAction>) -> UIAlertController {
        
        let alertController:UIAlertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        for action:UIAlertAction in alertActions {
            alertController.addAction(action)
        }
        
        return alertController
    }
    
    class func fetchLayoutDetailsFromDictionary(layoutObjectDict:Dictionary<String, LayoutObject>) -> LayoutObject {
        
        var layoutObject:LayoutObject?
        layoutObject = layoutObjectDict[Constants.kSTRING_AppleTV]
        return layoutObject!
    }
    
    //MARK: method to create title view
    class func createNavigationTitleView(navBarHeight:CGFloat) -> UIImageView {
        
        let image = UIImage(named: "clientnavlogo")
        let titleLogo = UIImageView(image: image)
        titleLogo.contentMode = .scaleAspectFit
        
        let xAxis:CGFloat = UIScreen.main.bounds.size.width / 2 - (image?.size.width)!/2
        let yAxis:CGFloat = navBarHeight/2 - (image?.size.height)!/2 - 5
        
        titleLogo.frame = CGRect(x: xAxis, y: yAxis, width: (image?.size.width)!, height: (image?.size.height)!)
        
        return titleLogo
    }
    
    class func getBaseScreenHeightMultiplier() -> CGFloat {
        
        return 1.0
    }
    
    class func getBaseScreenWidthMultiplier() -> CGFloat {
        
        return 1.0
    }
    
    class func createCustomParallaxEffect(_ value: Int, withTiltValue tiltValue: Double) -> UIMotionEffectGroup {
        let motionEffectGroup = UIMotionEffectGroup()
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = Int(-value)
        horizontalMotionEffect.maximumRelativeValue = Int(value)
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = Int(-value)
        verticalMotionEffect.maximumRelativeValue = Int(value)
        let horizontalTiltMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform.rotation.y", type: .tiltAlongHorizontalAxis)
        horizontalTiltMotionEffect.minimumRelativeValue = Int(-tiltValue)
        horizontalTiltMotionEffect.maximumRelativeValue = Int(tiltValue)
        return motionEffectGroup
    }
    //MARK: Method to fetch star rating view layout details
    class func fetchStarRatingLayoutDetails(starRatingObject:SFStarRatingObject) -> LayoutObject {
        var starRatingLayout:LayoutObject?
        starRatingLayout = starRatingObject.layoutObjectDict["\(Constants.kSTRING_AppleTV)"]
        return starRatingLayout!
    }
    
    class func fetchCastViewLayoutDetails(castViewObject:SFCastViewObject) -> LayoutObject {
        
        var textViewLayout:LayoutObject?
        textViewLayout = castViewObject.layoutObjectDict["\(Constants.kSTRING_AppleTV)"]
        return textViewLayout!
    }
    
    //MARK: method to get page id from page name
    class func getPageIdFromPagesArray(pageName:String) -> String? {
        
        var pageId:String?
        
        for page in AppConfiguration.sharedAppConfiguration.pages {
            
            if page.pageName == pageName {
                
                pageId = page.pageId
                
                break
            }
        }
        
        return pageId
    }
    
    //MARK: method to get uuid from sskeychain
    func getUUID() -> String {
        
        let retrieveUUID = SSKeychain.password(forService: Bundle.main.bundleIdentifier!, account: "user")
        
        if retrieveUUID != nil {
            
            return retrieveUUID!
        }
        else {
            
            return generateUUID()
        }
    }
    
    func generateUUID() -> String {
        
        let theUUID:CFUUID = CFUUIDCreate(kCFAllocatorDefault)
        
        let string:CFString = CFUUIDCreateString(kCFAllocatorDefault, theUUID)
        
        let uuid:String = string as String
        
        SSKeychain.setPassword(uuid, forService: Bundle.main.bundleIdentifier!, account: "user")
        
        return uuid
    }
    
    
    //MARK:Get App version release date from itunes number
    func getCurrentAppVersionDateFromiTunes() -> String? {
        
        guard
            let info = Bundle.main.infoDictionary,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json?["results"] as? [[String: Any]],
            results.count > 0,
            let currentVersionReleaseDate = results[0]["currentVersionReleaseDate"] as? String
            else {
                return nil
        }
        
        return currentVersionReleaseDate
    }
    
    //MARK :- Get App Environment
    func getEnvironment()->String
    {
        let baseURLString : String = AppConfiguration.sharedAppConfiguration.apiBaseUrl ?? ""
        let environment : String
        
        if baseURLString.lowercased().range(of:"prod") != nil {
            environment = "production"
        }
        else if baseURLString.lowercased().range(of:"release") != nil
        {
            environment = "release"
        }
        else if baseURLString.lowercased().range(of:"preprod") != nil
        {
            environment = "preprod"
        }
        else if baseURLString.lowercased().range(of:"develop") != nil
        {
            environment = "develop"
        }
        else if baseURLString.lowercased().range(of:"staging") != nil
        {
            environment = "staging"
        }
        else if baseURLString.lowercased().range(of:"qa") != nil
        {
            environment = "qa"
        }
        else
        {
            environment = " "
        }
        return environment
    }
    
    
    //MARK: Check if user is logged in or not
    func checkIfUserIsLoggedIn() -> Bool {
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) != nil {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String != UserLoginType.none.rawValue {
                
                return true
            }
            else {
                
                return false
            }
        }
        else {
            
            return false
        }
    }
    
    //MARK: Get Device Model Number
    class func getDeviceModelNumber() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let size = Int(_SYS_NAMELEN) // is 32, but posix AND its init is 256....
        
        let s = withUnsafeMutablePointer(to: &systemInfo.machine) {p in
            
            p.withMemoryRebound(to: CChar.self, capacity: size, {p2 in
                return String(cString: p2)
            })
            
        }
        return s
    }
    
    //MARK: Reformatting date format
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        
        let calendar = NSCalendar.current
        let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
        let now = NSDate()
        let earliest = now.earlierDate(date as Date)
        let latest = (earliest == now as Date) ? date : now
        let components = calendar.dateComponents(unitFlags, from: earliest as Date,  to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) seconds ago"
        } else {
            return "Just now"
        }
    }
    
    //MARK: Check for Subscribed Guest User
    func checkIfUserIsSubscribedGuest() -> Bool {
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) != nil {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.SubscribedGuest.rawValue {
                
                return true
            }
            else {
                
                return false
            }
        }
        else {
            
            return false
        }
    }
    
    //func getWatchedDurationForVideo -> returns Media Start Time for videos played less than 30 second or remaining time is less than 30 seconds
    class func getWatchedDurationForVideo(watchedDuration: Double, totalDurarion: Double) -> Double
    {
        if (watchedDuration < 30 || (totalDurarion - watchedDuration) < 30) {
            
            return 0
        }
        else
        {
            return watchedDuration
        }
    }
    
    func getRequestParametersForSubscription(receiptData: NSData?, emailId:String?, paymentModelObject:PaymentModel?, productIdentifier:String?, transactionIdentifier:String?) -> Dictionary<String, Any>{
        
        var receiptString:String?
        if receiptData != nil {
            
            receiptString = (receiptData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)))!
            
        }
        
        var requestParameters:Dictionary<String, Any> = [:]
        
        if AppConfiguration.sharedAppConfiguration.sitename != nil {
            
            requestParameters["siteInternalName"] = AppConfiguration.sharedAppConfiguration.sitename!
        }
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID) != nil {
            
            requestParameters["userId"] = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kUSERID)!
        }
        
        if AppConfiguration.sharedAppConfiguration.siteId != nil {
            
            requestParameters["siteId"] = AppConfiguration.sharedAppConfiguration.siteId!
        }
        
        requestParameters["subscription"] = "ios"
        
        if paymentModelObject != nil {
            
            if paymentModelObject?.planID != nil {
                
                requestParameters["planId"] = paymentModelObject?.planID!
                
                var userInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
                
                if userInfo != nil {
                    
                    userInfo?["planId"] = paymentModelObject?.planID!
                }
                
                Constants.kSTANDARDUSERDEFAULTS.setValue(userInfo, forKey: Constants.kTransactionInfo)
                Constants.kSTANDARDUSERDEFAULTS.synchronize()
            }
        }
        else {
            
            let userInfo:Dictionary<String, Any>? = Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kTransactionInfo) as? Dictionary<String, Any>
            
            if userInfo != nil {
                
                let planId:String? = userInfo?["planId"] as? String
                
                if planId != nil {
                    
                    requestParameters["planId"] = planId!
                }
            }
        }
        
        if productIdentifier != nil {
            
            requestParameters["planIdentifier"] = productIdentifier!
        }
        
        requestParameters["platform"] = "ios_phone"
        
        if emailId != nil {
            
            requestParameters["email"] = emailId!
        }
        
        if receiptString != nil {
            
            requestParameters["receipt"] = receiptString!
        }
        
        if transactionIdentifier != nil {
            
            requestParameters["paymentUniqueId"] = transactionIdentifier!
        }
        
        return requestParameters
    }
    
    class func getTextAlignment(textAlignmentString: String) -> NSTextAlignment{
        switch textAlignmentString {
        case "center":
            return .center
        case "left":
            return .left
        case "right":
            return .right
        default:
            return .left
        }
    }
    
    class func addMotionEffectToViewWithStrength (viewItem : UIView, strength : Float) {
        removeMotionEffectFromView(viewItem: viewItem)
        viewItem.addMotionEffect(UIMotionEffect.twoAxesShift(strength: strength))
    }
    
    class func removeMotionEffectFromView (viewItem : UIView) {
        var ii = 0
        while ii < (viewItem.motionEffects.count) {
            var motionEffect = viewItem.motionEffects[ii]
            if motionEffect is UIMotionEffectGroup {
                motionEffect = motionEffect as! UIMotionEffectGroup
                viewItem.removeMotionEffect(motionEffect)
            }
            ii = ii + 1
        }
    }
    
    //MARK :- Generate StreamID
    class func generateStreamID(movieName : String) -> String
    {
        let currentTimeStamp = String(Date().timeIntervalSince1970)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        var streamID = currentTimeStamp+deviceID+movieName
        streamID = streamID.sha1()
        return streamID
    }
    
    class func getPlatformNameFromPaymentProcessorString(_ paymentProcessorString: String) -> String {
        var platformString = "different platform/device"
        if (paymentProcessorString.lowercased() == "web_browser")
        {
            platformString = "Web"
        }
        else if (paymentProcessorString.lowercased() == "android_phone") || (paymentProcessorString.lowercased() == "android_tablet") || (paymentProcessorString.lowercased() == "android_wear") || (paymentProcessorString.lowercased() == "android_tv")
        {
            platformString = "Google Play"
        }
        else if (paymentProcessorString.lowercased() == "amazon_fire") || (paymentProcessorString.lowercased() == "amazon_tv") || (paymentProcessorString.lowercased() == "amazon_stick")
        {
            platformString = "Amazon"
        }
        else if (paymentProcessorString.lowercased() == "roku_box") || (paymentProcessorString.lowercased() == "roku_stick")
        {
            platformString = "Roku"
        }
        else if (paymentProcessorString.lowercased() == "windows_phone") || (paymentProcessorString.lowercased() == "windows_tablet") || (paymentProcessorString.lowercased() == "windows_xbox")
        {
            platformString = "Window Device"
        }
        else if (paymentProcessorString.lowercased() == "sony_playstation4") || (paymentProcessorString.lowercased() == "sony_playstation_vita") || (paymentProcessorString.lowercased() == "sony_playstation_tv")
        {
            platformString = "PS4"
        }
        else if (paymentProcessorString.lowercased() == "smart_tv_lg")
        {
            platformString = "Google Play"
        }
        else if (paymentProcessorString.lowercased() == "smart_tv_samsung")
        {
            platformString = "Google Play"
        }
        else if (paymentProcessorString.lowercased() == "smart_tv_sony")
        {
            platformString = "Google Play"
        }
        else if (paymentProcessorString.lowercased() == "smart_tv_panasonic")
        {
            platformString = "Google Play"
        }
        else if (paymentProcessorString.lowercased() == "smart_tv_opera_tv")
        {
            platformString = "Google Play"
        }
        return platformString
    }
    
    //MARK: Method to create plan price string
    func createPlanPriceString(paymentModelObject:PaymentModel?) -> NSAttributedString? {
        
        let currencySymbol:String? = Utility.getSymbolForCurrencyCode(countryCode: (paymentModelObject?.recurringPaymentsTotalCurrency)!)
        
        var completeString:String = ""
        var strikeThroughPriceString:String?
        var originalPriceString:String?
        
        let numberFormatter:NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 10
        
        if paymentModelObject?.planDiscountedPrice != nil {
            
            let strikeThroughPrice:String? = numberFormatter.string(from: (paymentModelObject?.planDiscountedPrice)!)
            
            if strikeThroughPrice != nil {
                
                strikeThroughPriceString = "\(currencySymbol ?? "")\(strikeThroughPrice!)"
                completeString = completeString.appending("\(strikeThroughPriceString!) ")
            }
        }
        
        if paymentModelObject?.recurringPaymentsTotal != nil {
            
            let planOriginalPrice:String? = numberFormatter.string(from: (paymentModelObject?.recurringPaymentsTotal)!)
            
            if planOriginalPrice != nil {
                
                originalPriceString = "\(currencySymbol ?? "")\(planOriginalPrice!)"
                
                if originalPriceString != nil {
                    
                    completeString = completeString.appending("\(originalPriceString!)")
                }
            }
        }
        
        var pendingPriceString:String?
        
        if paymentModelObject?.billingPeriodType == .MONTHLY {
            
            if paymentModelObject?.billingCyclePeriodMultiplier != nil {
                
                let billingCyclePeriod:Int = Int((paymentModelObject?.billingCyclePeriodMultiplier?.floatValue)!)
                
                //                if billingCyclePeriod < 1 {
                //
                //                    pendingPriceString = " / \(billingCyclePeriod) Months"
                //                }
                //                else
                if billingCyclePeriod == 1 {
                    
                    pendingPriceString = " / Month"
                }
            }
        }
        else if paymentModelObject?.billingPeriodType == .YEARLY {
            
            let billingCyclePeriod:Int = Int((paymentModelObject?.billingCyclePeriodMultiplier?.floatValue)!)
            
            //            if billingCyclePeriod > 1 {
            //
            //                pendingPriceString = " / \(billingCyclePeriod) Years"
            //            }
            //            else
            if billingCyclePeriod == 1 {
                
                pendingPriceString = " / Year"
            }
        }
        
        if pendingPriceString != nil {
            
            completeString = completeString.appending(pendingPriceString!)
        }
        
        let fontFamily = Utility.sharedUtility.fontFamilyForApplication()

        let planPriceString:NSMutableAttributedString? = self.createPlanPriceAttributedString(strikeThroughPriceString: strikeThroughPriceString, originalPriceString: originalPriceString, completeString: completeString, pendingPriceString: pendingPriceString, fontSize: 26, highlightedTextFontName: "\(fontFamily)-BoldItalic", normalTextFontName: "\(fontFamily)-Italic", priceSelectedColor: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000", priceColor: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff", opacity: 0.55)
        
        return planPriceString
    }
    
    
    //MARK: Method to create plan price string
    func createPlanPriceStringForGridProducts(paymentModelObject:PaymentModel?, isIntroductoryPriceAvailable:Bool, fontSize:CGFloat) -> NSAttributedString? {
        
        let currencySymbol:String? = Utility.getSymbolForCurrencyCode(countryCode: (paymentModelObject?.recurringPaymentsTotalCurrency)!)
        
        var completeString:String = ""
        var strikeThroughPriceString:String?
        var originalPriceString:String?
        
        let numberFormatter:NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 10
        
        if paymentModelObject?.planDiscountedPrice != nil {
            
            let strikeThroughPrice:String? = numberFormatter.string(from: (paymentModelObject?.planDiscountedPrice)!)
            
            if strikeThroughPrice != nil {
                
                strikeThroughPriceString = "\(currencySymbol ?? "")\(strikeThroughPrice!)"
                completeString = completeString.appending("\(strikeThroughPriceString!) ")
            }
        }
        
        if paymentModelObject?.recurringPaymentsTotal != nil {
            
            let planOriginalPrice:String? = numberFormatter.string(from: (paymentModelObject?.recurringPaymentsTotal)!)
            
            if planOriginalPrice != nil {
                
                originalPriceString = "\(currencySymbol ?? "")\(planOriginalPrice!)"
                
                if originalPriceString != nil {
                    
                    completeString = completeString.appending("\(originalPriceString!)")
                }
            }
        }
        
        var pendingPriceString:String?
        
        if isIntroductoryPriceAvailable {
            
            pendingPriceString = " *"
            
        }
        
        if pendingPriceString != nil {
            
            completeString = completeString.appending(pendingPriceString!)
        }
        
        let fontFamily = Utility.sharedUtility.fontFamilyForApplication()
        
        let planPriceString:NSMutableAttributedString? = self.createPlanPriceAttributedString(strikeThroughPriceString: strikeThroughPriceString, originalPriceString: originalPriceString, completeString: completeString, pendingPriceString: pendingPriceString, fontSize: fontSize, highlightedTextFontName: "\(fontFamily)-Bold", normalTextFontName: "\(fontFamily)-Semibold", priceSelectedColor: "#4A4A4A", priceColor: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff", opacity: 0.8)
        
        return planPriceString
    }
    
    func createPlanPriceAttributedString(strikeThroughPriceString:String?, originalPriceString:String?, completeString:String, pendingPriceString:String?, fontSize:CGFloat, highlightedTextFontName:String, normalTextFontName:String, priceSelectedColor:String, priceColor:String, opacity:CGFloat) -> NSMutableAttributedString? {
        
        var planPriceString:NSMutableAttributedString?
        
        if strikeThroughPriceString != nil {
            
            planPriceString = NSMutableAttributedString(string: completeString)
            
            if strikeThroughPriceString != nil {
                
                planPriceString?.addAttributes([NSBaselineOffsetAttributeName: 0, NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue), NSStrikethroughColorAttributeName: Utility.hexStringToUIColor(hex: priceSelectedColor), NSFontAttributeName: UIFont(name: highlightedTextFontName, size: fontSize)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: priceColor).withAlphaComponent(opacity)], range: (completeString as NSString).range(of: strikeThroughPriceString!))
            }
            
            planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: highlightedTextFontName, size: fontSize)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: priceColor)], range: (completeString as NSString).range(of: originalPriceString!))
            
            if pendingPriceString != nil {
                
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: normalTextFontName, size: fontSize)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: priceColor)], range: (completeString as NSString).range(of: pendingPriceString!))
            }
        }
        else {
            
            planPriceString = NSMutableAttributedString(string: completeString)
            
            if originalPriceString != nil {
                
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: highlightedTextFontName, size: fontSize)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: priceColor)], range: (completeString as NSString).range(of: originalPriceString!))
            }
            
            if pendingPriceString != nil {
                
                planPriceString?.addAttributes([NSFontAttributeName: UIFont(name: normalTextFontName, size: fontSize)!, NSForegroundColorAttributeName: Utility.hexStringToUIColor(hex: priceColor)], range: (completeString as NSString).range(of: pendingPriceString!))
            }
        }
        
        return planPriceString
    }
    
    static func getUserAgent() -> String {
        let bundleDict = Bundle.main.infoDictionary!
        let appName = bundleDict["CFBundleName"] as! String
        let appVersion = bundleDict["CFBundleShortVersionString"] as! String
        let appDescriptor = appName + "/" + appVersion
        
        let currentDevice = UIDevice.current
        let osDescriptor = "iOS/" + currentDevice.systemVersion
        
        return appDescriptor + " " + osDescriptor + " (" + UIDevice.current.modelName + ")"
    }
    
    //MARK: Method to check if forced update to be displayed
    func shouldDisplayForceUpdate() -> Bool {
        
        let appVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        let currentVersion = "\(appVersion).\(appBuild)"
        let minimumSupportedVersion = AppConfiguration.sharedAppConfiguration.appMinimumVersionNumber
        
        if minimumSupportedVersion != nil {
            if currentVersion.compare(minimumSupportedVersion!, options: .numeric) == .orderedAscending {
                return true
            }
        }
        return false
    }
    
    //MARK: Method to check if forced update to be displayed
    func shouldDisplaySoftUpdate() -> Bool {
        
        let appVersion:String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let appBuild:String = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        let currentVersion = "\(appVersion).\(appBuild)"
        let appStoreVersion = AppConfiguration.sharedAppConfiguration.appAppStoreVersionNumber
        
        if appStoreVersion != nil {
            if currentVersion.compare(appStoreVersion!, options: .numeric) == .orderedAscending {
                return true
            }
        }
        return false
    }
    
    func getDateStringFromInterval(timeInterval: Double) -> String {
        let date = Date(timeIntervalSince1970: (timeInterval / 1000.0))//(timeInterval / 1000.0))
        let dateString = "\(date.getMonthName()) \(date.getDateString())"
        return dateString
    }
    
    func getDateStringFromIntervalWithPunctuationMark(timeInterval: Double) -> String {
        let date = Date(timeIntervalSince1970: (timeInterval / 1000.0))//(timeInterval / 1000.0))
        let dateString = "\(date.getMonthName()) \(date.getDateString()), \(date.getYearString())"
        return dateString
    }
    
    func getImageSizeAsPerScreenResolution(size:CGFloat) -> CGFloat {
        //TODO: Update this.
        return size
    }
    
    func getCollectionViewHeightForSportsTemplate(rowHeight: CGFloat, gridObject: SFCollectionGridObject, pageAPIModuleObject:SFModuleObject) -> CGFloat{
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased(){
            if let isHorizontalScroll = gridObject.isHorizontalScroll{
                if !isHorizontalScroll{
                    let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: gridObject)
                    let screenWidth = (Float)(UIScreen.main.bounds.width)
                    var viewWidth = (collectionGridLayout.leftMargin!/100 * screenWidth) + ((collectionGridLayout.rightMargin!/100 * screenWidth))
                    viewWidth = screenWidth - viewWidth
                    let itemsPerRow = (Int)((Float)(viewWidth)/(collectionGridLayout.gridWidth!))
                    var rowCount = 0
                    if ((Float)((pageAPIModuleObject.moduleData?.count)!).truncatingRemainder(dividingBy: (Float)(itemsPerRow))) == 0{
                        rowCount = ((pageAPIModuleObject.moduleData?.count)!)/itemsPerRow
                    }else{
                        rowCount = ((pageAPIModuleObject.moduleData?.count)!)/itemsPerRow
                        rowCount = rowCount + 1
                    }
                    let rowHeight = (CGFloat)(rowCount) * (CGFloat)(collectionGridLayout.gridHeight! + 40)
                    return rowHeight + 80
                }
                else{
                    return rowHeight
                }
            }
            else{
                return rowHeight
            }
        }
        else{
            return rowHeight
        }
        
    }
    
    //MARK: Method to pick font family for application
    func fontFamilyForApplication()->String {
        
        var fontFamily:String? = AppConfiguration.sharedAppConfiguration.appFontFamily
        
        if fontFamily == nil {
            
            if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
                
                fontFamily = Constants.kSportsTemplateFontFamily
            }
            else {
                
                fontFamily = Constants.kEntertainmentTemplateFontFamily
            }
        }
        
        return fontFamily!
    }
}
