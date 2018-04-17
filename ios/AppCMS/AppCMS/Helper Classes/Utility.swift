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
    var isDeviceIphoneX :Bool = false
    private override init() {
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
            
            if viewLayout.leftMargin != nil {
                
                width = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.rightMargin ?? 0.0) - (viewLayout.leftMargin ?? 0.0)), relativeViewCoordinate: relativeViewWidth)
            }
            else if viewLayout.xAxis != nil {
                
                width = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.rightMargin ?? 0.0) - (viewLayout.xAxis ?? 0.0)), relativeViewCoordinate: relativeViewWidth)
            }
        }
        
        if (viewLayout.yAxis != nil) {
            
            yAxis = viewLayout.yAxis!
        }
        else if (viewLayout.topMargin != nil) {
            yAxis = Utility.calculateCoordinateForSubView(marginPercent: viewLayout.topMargin ?? 0.0, relativeViewCoordinate: relativeViewHeight)
        }
        else if (viewLayout.bottomMargin != nil) {
            
            yAxis = relativeViewHeight - Utility.calculateCoordinateForSubView(marginPercent: viewLayout.bottomMargin ?? 0.0, relativeViewCoordinate: relativeViewHeight)
            yAxis = yAxis - viewLayout.height!
        }
        
        if (viewLayout.height != nil) {
            
            height = viewLayout.height!
        }
        else {
            
            if viewLayout.topMargin != nil {
                
                height = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.bottomMargin ?? 0.0) - (viewLayout.topMargin ?? 0.0)), relativeViewCoordinate: relativeViewHeight)
            }
            else if viewLayout.yAxis != nil {
                
                height = Utility.calculateCoordinateForSubView(marginPercent: (100.0 - (viewLayout.bottomMargin ?? 0.0)), relativeViewCoordinate: relativeViewHeight) - (viewLayout.yAxis ?? 0.0)
            }
        }
        
        let viewFrame:CGRect = CGRect(x: CGFloat(xAxis), y: CGFloat(yAxis), width: CGFloat(width), height: CGFloat(height))
        
        return viewFrame
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
    
    
    //MARK: method to create title view
    class func createNavigationTitleView(navBarHeight:CGFloat) -> UIImageView {
        
        let sizeScale = Int(UIScreen.main.scale)
        
        var imageName = "clientnavlogo"
    
        if sizeScale > 1 {
            
            imageName.append("@\(imageName)x")
        }
        
        var image = UIImage(named: imageName)
        
        if image == nil {
            
            image = UIImage(named: "clientnavlogo")
        }
        let titleLogo = UIImageView(image: image)
        titleLogo.contentMode = .scaleAspectFit
        
        let xAxis:CGFloat = UIScreen.main.bounds.size.width / 2 - (image?.size.width)!/2
        let yAxis:CGFloat = navBarHeight/2 - (image?.size.height)!/2 - 5
        
        titleLogo.frame = CGRect(x: xAxis, y: yAxis, width: (image?.size.width)!, height: (image?.size.height)!)
        
        return titleLogo
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
    
    
    //MARK: method to get page id from page name
    func getPageIdFromPagesArray(pageName:String) -> String? {
        
        var pageId:String?
        
        for page in AppConfiguration.sharedAppConfiguration.pages {
            
            if page.pageName == pageName {
                
                pageId = page.pageId
                
                break
            }
        }
        
        return pageId
    }
    
    
    //MARK: Check if user is logged in or not
    func checkIfUserIsLoggedIn() -> Bool {
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) != nil {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.Email.rawValue || Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.Gmail.rawValue || Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.Facebook.rawValue {
                
                #if os(iOS)
                    if self.checkIfGoogleTagMangerAvailable() {
                        
                        self.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                #endif
                return true
            }
            else {
                
                #if os(iOS)
                    if self.checkIfGoogleTagMangerAvailable() {
                        
                        self.setGTMUserProperty(userPropertyValue: Constants.kGTMNotLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                #endif
                return false
            }
        }
        else {
            
            #if os(iOS)
                if self.checkIfGoogleTagMangerAvailable() {
                    
                    self.setGTMUserProperty(userPropertyValue: Constants.kGTMNotLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                }
            #endif
            return false
        }
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
            return "\(components.minute!) mins ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min ago"
            } else {
                return "A min ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) secs ago"
        } else {
            return "Just now"
        }
    }
    
    
    //MARK: Check for Subscribed Guest User
    func checkIfUserIsSubscribedGuest() -> Bool {
        
        if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) != nil {
            
            if Constants.kSTANDARDUSERDEFAULTS.value(forKey: Constants.kLoginType) as! String == UserLoginType.SubscribedGuest.rawValue {
                
                #if os(iOS)
                    if self.checkIfGoogleTagMangerAvailable() {
                        
                        self.setGTMUserProperty(userPropertyValue: Constants.kGTMLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                #endif
                return true
            }
            else {
                
                #if os(iOS)
                    if self.checkIfGoogleTagMangerAvailable() {
                        
                        self.setGTMUserProperty(userPropertyValue: Constants.kGTMNotLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                    }
                #endif
                
                return false
            }
        }
        else {
            
            #if os(iOS)
                if self.checkIfGoogleTagMangerAvailable() {
                    
                    self.setGTMUserProperty(userPropertyValue: Constants.kGTMNotLoggedInPropertyValue, userPropertyKeyName: Constants.kGTMLoggedInProperty)
                }
            #endif
            
            return false
        }
    }
    
    //MARK: Get Device Model Number
    func getDeviceModelNumber() -> String {
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
        
        requestParameters["addEntitlement"] = true
        
        return requestParameters
    }

    
    //MARK - method to calculate parental rating
    func calculateParentalRating(parentalRating:String) -> String? {
        
        var calculatedParentalRating:String?
        
        let parentalRatingArray:Array? = parentalRating.components(separatedBy: "_")
        
        if parentalRatingArray != nil {
            
            if (parentalRatingArray?.count)! > 1 {
                
                switch (parentalRatingArray?[1])! {
                case "Y":
                    calculatedParentalRating = "2+"
                case "Y7":
                    calculatedParentalRating = "7+"
                case "G":
                    calculatedParentalRating = "0+"
                case "PG":
                    calculatedParentalRating = "13+"
                case "14":
                    calculatedParentalRating = "14+"
                default:
                    calculatedParentalRating = "18+"
                }
            }
            else {
                calculatedParentalRating = parentalRating
            }
        }
        else {
            
            calculatedParentalRating = parentalRating
        }
        
        return calculatedParentalRating
    }

    //func getWatchedDurationForVideo -> returns Media Start Time for videos played less than 30 second or remaining time is less than 30 seconds
    func getWatchedDurationForVideo(watchedDuration: Double, totalDurarion: Double) -> Double
    {
        if (watchedDuration < 30 || (totalDurarion - watchedDuration) < 30) {
            
            return 0
        }
        else
        {
            return watchedDuration
        }
    }
    
    
    //MARK: Method to get currency symbol from country code
    func getSymbolForCurrencyCode(countryCode: String) -> String? {
        let locale = NSLocale(localeIdentifier: countryCode)
        return locale.displayName(forKey: NSLocale.Key.currencySymbol, value: countryCode)
    }
    
    
    //MARK :- Generate StreamID
    func generateStreamID(movieName : String) -> String
    {
        let currentTimeStamp = String(Date().timeIntervalSince1970)
        let deviceID = UIDevice.current.identifierForVendor!.uuidString
        var streamID = currentTimeStamp+deviceID+movieName
        streamID=streamID.sha1()
        return streamID
    }
    
    //MARK: Password validation method
    class func isValidPassword(passwordString:String, emailAddress:String?) -> String? {
        
        var passwordValidationText: String?

        if passwordString.characters.count < 5 || passwordString.characters.count > 50 {
            
            passwordValidationText = Constants.kPasswordValidationError
        }
        return passwordValidationText
    }
    
    
    //MARK :- Get dp2 parameter on basis of video state (downloaded/not downloaded)
    func getDp2ParameterForBeaconEvent(fileName : String)->String
    {
        if(self.checkIfMovieIsDownloaded(fileID: fileName))
        {
            let reachability:Reachability = Reachability.forInternetConnection()
            if (reachability.currentReachabilityStatus() == NotReachable) {
                
                return Constants.kBeaconDp2downloadedViewOffline
            }
            else
            {
                return Constants.kBeaconDp2downloadedViewOnline
            }
        }
        return ""
    }
    
    
    //MARK :- Check if "https" exists in base url or not
    func checkIfHttpsAlreadyExistsInBaseUrl()->Bool
    {
        var ishttpsExists = false
        let baseUrl = AppConfiguration.sharedAppConfiguration.beaconObject?.apiBaseUrl ?? ""
        
        if baseUrl.lowercased().range(of:"http") != nil {
            ishttpsExists = true
        }
        else
        {
            ishttpsExists = false
        }
        return ishttpsExists
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
    
    func checkIfMoviePlayable() -> Bool {
        
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            return Constants.kSTANDARDUSERDEFAULTS.bool(forKey: Constants.kIsSubscribedKey)
        }
        else{
            return true
        }
    }

    
    func displayLoginScreen() -> Void {

        let loginViewController: LoginViewController = LoginViewController.init()
        loginViewController.loginPageSelection = 0
        loginViewController.pageScreenName = "Sign In Screen"
        loginViewController.loginType = loginPageType.authentication
        let navigationController: UINavigationController = UINavigationController.init(rootViewController: loginViewController)
        navigationController.present()
    }

    func showAlertForUnsubscribeUser() -> Void {
        var alertTitle = ""
        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            alertTitle = Constants.kEntitlementErrorMessage
        }
        else{
            alertTitle = Constants.kEntitlementLoginErrorMessage
        }

        let alertController = UIAlertController(title:  Constants.kEntitlementErrorTitle, message: alertTitle, preferredStyle: .alert)

        let signInAction = UIAlertAction(title: Constants.kStrSign, style: .default, handler: {(_ action: UIAlertAction) -> Void in

            self.displayLoginScreen()
        })

        let cancelAction = UIAlertAction(title: Constants.kStrCancel, style: .default, handler: {(_ action: UIAlertAction) -> Void in

        })

        alertController.addAction(cancelAction)
        if !Utility.sharedUtility.checkIfUserIsLoggedIn() {
            alertController.addAction(signInAction)
        }

        if AppConfiguration.sharedAppConfiguration.serviceType == serviceType.SVOD {
            let startFreeTrialAction = UIAlertAction(title: Constants.kStartFreetrial, style: .default, handler: {(_ action: UIAlertAction) -> Void in
                let planViewController:SFProductListViewController = SFProductListViewController.init()
                let navigationController: UINavigationController = UINavigationController.init(rootViewController: planViewController)
                navigationController.present()
            })
            alertController.addAction(startFreeTrialAction)
        }
        alertController.show()
    }


    //MARK: Method to create plan price string
    func createPlanPriceString(paymentModelObject:PaymentModel?) -> NSAttributedString? {
        
        let currencySymbol:String? = self.getSymbolForCurrencyCode(countryCode: (paymentModelObject?.recurringPaymentsTotalCurrency)!)
        
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
                
                if billingCyclePeriod == 1 {
                
                    pendingPriceString = " / Month"
                }
            }
        }
        else if paymentModelObject?.billingPeriodType == .YEARLY {
            
            let billingCyclePeriod:Int = Int((paymentModelObject?.billingCyclePeriodMultiplier?.floatValue)!)
            
            if billingCyclePeriod == 1 {
            
                pendingPriceString = " / Year"
            }
        }
        
        if pendingPriceString != nil {
            
            completeString = completeString.appending(pendingPriceString!)
        }
        
        let planPriceString:NSMutableAttributedString? = self.createPlanPriceAttributedString(strikeThroughPriceString: strikeThroughPriceString, originalPriceString: originalPriceString, completeString: completeString, pendingPriceString: pendingPriceString, fontSize: 17, highlightedTextFontName: "\(Utility.sharedUtility.fontFamilyForApplication())-BoldItalic", normalTextFontName: "\(Utility.sharedUtility.fontFamilyForApplication())-Italic", priceSelectedColor: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "000000", priceColor: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff", opacity: 0.55)

        return planPriceString
    }
    
    
    //MARK: Method to create plan price string for grid products
    func createPlanPriceStringForGridProducts(paymentModelObject:PaymentModel?, isIntroductoryPriceAvailable:Bool, fontSize:CGFloat) -> NSAttributedString? {
        
        let currencySymbol:String? = self.getSymbolForCurrencyCode(countryCode: (paymentModelObject?.recurringPaymentsTotalCurrency)!)
        
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
        var fontWeight = "ExtraBold"
        
        if TEMPLATETYPE.lowercased() == Constants.kTemplateTypeSports.lowercased() {
            
            fontWeight = "Black"
        }
        
        let planPriceString:NSMutableAttributedString? = self.createPlanPriceAttributedString(strikeThroughPriceString: strikeThroughPriceString, originalPriceString: originalPriceString, completeString: completeString, pendingPriceString: pendingPriceString, fontSize: fontSize, highlightedTextFontName: "\(fontFamily)-\(fontWeight)", normalTextFontName: "\(Utility.sharedUtility.fontFamilyForApplication())-Semibold", priceSelectedColor: AppConfiguration.sharedAppConfiguration.secondaryButton.selectedColor ?? AppConfiguration.sharedAppConfiguration.appBlockTitleColor ?? "#4A4A4A", priceColor: AppConfiguration.sharedAppConfiguration.appTextColor ?? "ffffff", opacity: 0.8)
        
        return planPriceString
    }
    
    //MARK: Method to create attributed string for plans
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
    
    
    //MARK: Method to dynamically calculate cell height for tray object from cell components
    func calculateCellHeightFromCellComponents(trayObject:SFTrayObject, noOfData:Float) -> Float {
        
        var rowHeight:Float = 0.0
        
        for module in trayObject.trayComponents {
            
            if module is SFLabelObject {
                
                let labelObject = module as! SFLabelObject
                
                let maxYAxis = Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).height ?? 0) + Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).yAxis ?? 0)
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
            else if module is SFSeparatorViewObject {
                
                let separatorViewObject = module as! SFSeparatorViewObject
                
                let maxYAxis = Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).height ?? 0) + Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).yAxis ?? 0)
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
            else if module is SFCollectionGridObject {
                
                let collectionGridObject = module as! SFCollectionGridObject
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
                
                let collectionViewWidth = ceil(Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)).width)
                
                let collectionViewGridWidth:Float = (collectionGridLayout.gridWidth ?? 0) * Float(Utility.getBaseScreenWidthMultiplier()) + (collectionGridLayout.trayPadding ?? 0)

                let noOfGridToBeDisplayedInRow:Int = Int(round(Float(collectionViewWidth) / collectionViewGridWidth))
                
                var collectionGridHeight:Float = 0.0
                
                if noOfGridToBeDisplayedInRow > 0 {
                    
                    let multiplierFactorForGridHeight = Float(round((noOfData / Float(noOfGridToBeDisplayedInRow))))
                    collectionGridHeight = ((collectionGridLayout.gridHeight ?? 0) + (collectionGridLayout.trayPadding ?? 0)) * multiplierFactorForGridHeight
                }

                let maxYAxis = (collectionGridLayout.yAxis ?? 0) + collectionGridHeight
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
        }
        
        return rowHeight
    }
    
    
    //MARK: Method to dynamically calculate cell height for listview object from cell components
    func calculateCellHeightFromCellComponents(listViewObject:SFListViewObject, noOfData:Float) -> Float {
        
        var rowHeight:Float = 0.0
        
        for module in listViewObject.listViewComponents {
            
            if module is SFLabelObject {
                
                let labelObject = module as! SFLabelObject
                
                let maxYAxis = Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).height ?? 0) + Float(Utility.fetchLabelLayoutDetails(labelObject: labelObject).yAxis ?? 0)
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
            else if module is SFSeparatorViewObject {
                
                let separatorViewObject = module as! SFSeparatorViewObject
                
                let maxYAxis = Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).height ?? 0) + Float(Utility.fetchSeparatorViewLayoutDetails(separatorViewObject: separatorViewObject).yAxis ?? 0)
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
            else if module is SFCollectionGridObject {
                
                let collectionGridObject = module as! SFCollectionGridObject
                let collectionGridLayout = Utility.fetchCollectionGridLayoutDetails(collectionGridObject: collectionGridObject)
                
                let collectionViewWidth = ceil(Utility.initialiseViewLayout(viewLayout: collectionGridLayout, relativeViewFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)).width)
                
                let collectionViewGridWidth:Float = (collectionGridLayout.gridWidth ?? 0) * Float(Utility.getBaseScreenWidthMultiplier()) + (collectionGridLayout.trayPadding ?? 0)
                
                let noOfGridToBeDisplayedInRow:Int = Int(round(Float(collectionViewWidth) / collectionViewGridWidth))
                
                var collectionGridHeight:Float = 0.0
                
                if noOfGridToBeDisplayedInRow > 0 {
                    
                    let multiplierFactorForGridHeight = Float(round((noOfData / Float(noOfGridToBeDisplayedInRow))))
                    collectionGridHeight = ((collectionGridLayout.gridHeight ?? 0) + (collectionGridLayout.trayPadding ?? 0)) * multiplierFactorForGridHeight
                }
                
                let maxYAxis = (collectionGridLayout.yAxis ?? 0) + collectionGridHeight
                
                if maxYAxis > rowHeight {
                    
                    rowHeight = maxYAxis
                }
            }
        }
        
        return rowHeight
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
    
    static func getUserAgent() -> String {
        let bundleDict = Bundle.main.infoDictionary!
        let appName = bundleDict["CFBundleName"] as! String
        let appVersion = bundleDict["CFBundleShortVersionString"] as! String
        let appDescriptor = appName + "/" + appVersion
        
        let currentDevice = UIDevice.current
        let osDescriptor = "iOS/" + currentDevice.systemVersion
       
        return appDescriptor + " " + osDescriptor + " (" + UIDevice.current.modelName + ")"
    }
    
    
    //MARK: Method to get image size as per screen resolution
    func getImageSizeAsPerScreenResolution(size:CGFloat) -> CGFloat {
        
        let screenScale = UIScreen.main.scale
        let newSize = size * screenScale
        
        return newSize
    }
}

