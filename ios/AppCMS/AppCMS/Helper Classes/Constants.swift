//
//  Constants.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 09/03/17.
//
//

import Foundation
import UIKit

#if os(iOS)
let DEBUGMODE : Bool = false
#else
let DEBUGMODE : Bool = false
#endif

let TEMPLATETYPE : String = AppConfiguration.sharedAppConfiguration.templateType ?? "ENTERTAINMENT"

@objc protocol SFKisweBaseViewControllerDelegate:NSObjectProtocol {
    @objc optional func removeKisweBaseViewController(viewController:UIViewController) -> Void
}

class Constants
{
    //General Constants
    static let kTemplateTypeSports = "SPORTS"
    static let kTemplateTypeEntertainment = "ENTERTAINMENT"
    static let kAutoplayOn = "AUTOPLAY ON"
    static let kAutoplayOff = "AUTOPLAY OFF"
    static let kClosedCaptionOn = "CLOSED CAPTION ON"
    static let kClosedCaptionOff = "CLOSED CAPTION OFF"
    static let kManageSubscriptiontvOS = "MANAGE SUBSCRIPTION"
    static let kSubscribeNowtvOS = "SUBSCRIBE\nNOW"
    static let kSignOut = "SIGN OUT"
    static let kSignUp = "SIGN UP"
    
    static let kFirstTimeUserKey = "FirstTimeKey"
    
    static let IS_IPAD_PRO = (UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad  &&
        UIScreen.main.nativeBounds.size.height == 2732)
    
    static let kSTRING_PAGETYPE_DOWNLOAD = "Download"
    static let kSTRING_PAGETYPE_DEFAULT = "Default"
    static let kSTRING_PAGETYPE_WEBPAGE = "WebPage"
    static let kSTRING_PAGETYPE_NATIVE = "Native"
    static let kSTRING_PAGETYPE_MODULAR = "Modular"
    static let kSTRING_PAGETYPE_WELCOME = "WelcomePage"
    static let kSTRING_AppleTV = "appletv"//"AppleTV"
    static let kSTRING_IPHONE_ORIENTATION_TYPE = "iPhone"
    static let kSTRING_IPAD_LANDSCAPE_ORIENTATION_TYPE = "iPadLandscape"
    static let kSTRING_IPAD_PORTRAIT_ORIENTATION_TYPE = "iPadPortrait"
    static let kSTANDARDUSERDEFAULTS = UserDefaults.standard
    static let kPreviewEndEnforcer = Constants.kAPPDELEGATE.previewEndEnforcer
    static let kNOTIFICATIONCENTER = NotificationCenter.default
    static let kUSERID = "UserId"
    static let kLoginType = "LoginType"
    static let kRefreshToken = "refreshToken"
    static let kAuthorizationToken = "authorizationToken"
    static let kAuthorizationTokenTimeStamp = "authorizationTokenDate"
    static let kAuthorizationTokenValidityTimeStamp = 1800
    static let kAPPDELEGATE:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let kSTRING_IMAGETYPE_VIDEO = "video"
    static let kSTRING_IMAGETYPE_POSTER = "poster"
    static let kSTRING_IMAGETYPE_WIDGET = "widget"
    static let kSTRING_IMAGETYPE_BANNER = "banner"
    static let kSTRING_IMAGETYPE_SQUARE = "square"
    static let kSTRING_IMAGETYPE_32x9 = "_32x9"
    static let kSTRING_IMAGETYPE_16x9 = "_16x9"
    static let kSTRING_IMAGETYPE_4x3 = "_4x3"
    static let kSTRING_IMAGETYPE_3x4 = "_3x4"
    static let kSTRING_IMAGETYPE_1x1 = "_1x1"
    static let kNetWorkStatus = "networkStatus"
    static let kStrCancel = "Cancel"
    static let kStrRetry = "Retry"
    static let kVideoContentType = "video"
    static let kVideosContentType = "videos"
    static let kShowContentType = "series"
    static let kShowsContentType = "shows"
    static let kArticleContentType = "article"
    static let kArticlesContentType = "articles"
    static let kAppUpdateViewDismissAnimation = 0.2
    static let kEpisodicContentType = "EPISODIC"
    static let kSportsTemplateFontFamily = "Lato"
    static let kEntertainmentTemplateFontFamily = "OpenSans"
    
    #if os(iOS)
    static let kStrOk = "Ok"
    #else
    static let kStrOk = "OK"
    #endif
    static let kStrSign = "Sign In"
    static let kStrSubscription = "Subscribe Now"
    static let kInternetConnection = "Internet Connection"
    static let kInternetConntectionRefresh = "There is an error loading \(Bundle.main.infoDictionary?["CFBundleDisplayName"] ?? ""). Please check your Internet Connection and try again later"
    static let kNoResponseErrorTitle = "No Response Received"
    static let kManageSubscription = "Manage Subscription"
    static let kManageSubscriptionString = "This is %@ %@ subscription. Management is possible with the device used for purchase."
    static let kAutoPlay = "AutoPlay Value"
    static let kCellularDownload = "Cellular Download"
    static let kPasswordValidationError = "Password should contain minimum 5 & maximum 50 characters"
    static let kCoutryDialCodeError = "Please select your mobile dial country code"
    #if os(iOS)
    static let kBeaconUrl = "https://1a7ahu122g.execute-api.us-east-1.amazonaws.com/production_beacon/firehouse-proxy"
    #else
    static let kBeaconUrl = "https://y3702sf2ai.execute-api.us-east-1.amazonaws.com/Beacon/firehouse-proxy"
    #endif
    
    static let kTransactionDetailPlistName = "TransactionDetails"
    static let kUserDetailsPlistName = "UserDetails"
    static let kBlocksFileName = "Block"
    
    #if os(iOS)
    static let IPHONE = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    static let kMOC = NSManagedObjectContext.mr_default()
    #endif
    
    static let kisFloodLightAPICalledForFirstLaunch = "isFloodLightAPICalledForFirstLaunch"
    
    //Beacon Protocol Constants
    static let kBeaconViewingFilmPage = "FilmPlayerView"
    static let kBeaconEventTypePlay = "PLAY"
    static let kBeaconEventTypePing = "PING"
    static let kBeaconEventTypeAdRequest = "AD_REQUEST"
    static let kBeaconEventTypeAdImpression = "AD_IMPRESSION"
    static let kBeaconEventChromecast = "Chromecast"
    static let kBeaconEventFirstFrame = "FIRST_FRAME"
    static let kBeaconEventFailedToStart = "FAILED_TO_START"
    static let kBeaconEventBuffering = "BUFFERING"
    static let kBeaconEventDroppedStream = "DROPPED_STREAM"
    static let kBeaconEventMediaTypeAudio = "mediatype:audio"
    static let kBeaconEventMediaTypeVideo = "mediatype:video"
    static let kBeaconEventNativePlayer = "Native"
    static let kBeaconEventAirplayPlayer = "AirPlay"
    static var kBeaconDp2downloadedViewOffline = "downloaded_view-offline"
    static var kBeaconDp2downloadedViewOnline = "downloaded_view-online"
    
    static let kBeaconAidKey = "aid"
    static let kBeaconCidKey = "cid"
    static let kBeaconPfmKey = "pfm"
    static let kBeaconVidKey = "vid"
    static let kBeaconUidKey = "uid"
    static let kBeaconProfidKey = "profid"
    static let kBeaconPaKey = "pa"
    static let kBeaconPlayerKey = "player"
    static let kBeaconEnvironmentKey = "environment"
    static let kBeaconMedia_typeKey = "media_type"
    static let kBeaconTstampoverrideKey = "tstampoverride"
    static let kBeaconStream_idKey = "stream_id"
    static let kBeaconDp1Key = "dp1"
    static let kBeaconDp2Key = "dp2"
    static let kBeaconDp3Key = "dp3"
    static let kBeaconDp4Key = "dp4"
    static let kBeaconDp5Key = "dp5"
    static let kBeaconRefKey = "ref"
    static let kBeaconAposKey = "apos"
    static let kBeaconApodKey = "apod"
    static let kBeaconVposKey = "vpos"
    static let kBeaconUrlKey = "url"
    static let kBeaconEmbedurlKey = "embedurl"
    static let kBeaconTtfirstframeKey = "ttfirstframe"
    static let kBeaconBitrateKey = "bitrate"
    static let kBeaconConnectionSpeedKey = "connectionspeed"
    static let kBeaconResolutionHeightKey = "resolutionheight"
    static let kBeaconResolutionWidthKey = "resolutionwidth"
    static let kBeaconBufferHealthKey = "bufferhealth"
    
    //Placeholder Images Constants
    static let kVideoImagePlaceholder = "videoImagePlaceholder"
    static let kPosterImagePlaceholder = "posterImagePlaceholder"
    
    //Watchlist Constants
    static let kStrAddToWatchlistAlertTitle = "Add to Watchlist"
    static let kStrAddToWatchlistAlertMessage = "You have to be signed in to add this to your watchlist"
    static let kStrDeleteWatchlistAlertTitle = "Delete Watchlist"
    static let kStrDeleteAllVideosFromWatchlistAlertMessage = "Do you want to delete all videos from watchlist?"
    static let kStrDeleteSingleVideoFromWatchlistAlertMessage = "Do you want to delete video from watchlist?"
    
    //History Constants
    static let kStrDeleteHistoryAlertTitle = "Delete History"
    static let kStrDeleteAllVideosFromHistoryAlertMessage = "Do you want to delete all videos from history?"
    static let kStrDeleteSingleVideoFromHistoryAlertMessage = "Do you want to delete video from history?"
    
    //Notifications Constants
    static let kToggleMenuBarInteractionNotification = Notification.Name("ToggleMenuBarInteraction")
    static let kToggleMenuBarNotification = Notification.Name("ToggleMenuBarNotification")
    static let kMenuButtonTapped = Notification.Name("MenuButtonTapped")
    static let KRefreshDataOfPage = Notification.Name("RefreshDataOfPage")
    
    static let kUpdateNavigationMenuItems = Notification.Name("UpdateNavigationMenuItems")
    
    //Subscription Constants
    static let startSubscriptionString = "SUBSCRIBE NOW"
    static let kSubscriptionNoResponseErrorMessage = "Unable to fetch plan details!\nDo you wish to Try Again?"
    static let kTransactionInfo = "transactionInfo"
    static let kIsAccountLinked = "IS_ACCOUNT_LINKED"
    static let kSubscribedGuest = "SUBSCRIBED_GUEST"
    static let kGuest = "Guest"
    static let kSubscribed = "Subscribed"
    static let kUpdateSubscriptionStatusToServer = "UpdateSubscriptionStatusToServer"
    static let kEmail = "Email"
    static let kEmailAddress = "EmailAddress"
    static let kUserLogInSuccess = "UserLogInSuccess"
    static let kSuccess = "Success"
    static let kError = "Error"
    static let kCreateLoginSuccessMessage = "You have created your account successfully."
    static let kAlreadyLinkedTitle = "Account Already Linked"
    static let kAlreadyLinkedMessage = "Your account is already linked with some email id. Please sign in with"
    static let kAccountCreationErrorTitle = "Account Creation"
    static let kAccountCreationErrorMessage = "Failed to Create Account. Please try Again."
    static let kStrUserSubscribed = "Subscribed"
    static let kSFiTunesConnectErrorNotification = "SFiTunesConnectErrorNotification"
    static let kSFRestorePurchaseCompletionNotification = "SFRestorePurchaseCompletionNotification"
    static let kSFPurchaseCompletionNotification = "SFPurchaseCompletionNotification"
    static let kSFPurchaseFailedNotification = "SFPurchaseFailedNotification"
    static let kSFRestorePurchaseFailedNotification = "SFRestorePurchaseFailedNotification"
    static let kSFPurchaseInProcessNotification = "SFPurchaseInProcessNotification"
    static let kSFPurchaseProductNotAvailableNotification = "SFPurchaseProductNotAvailableNotification"
    static let kShowAlertNotification = "ShowAlertNotification"
    static let kSFPurchaseRestoreNotification = "SFPurchaseRestoreNotification"
    static let kSFPurchaseRestoreWithZeroTransaction = "SFPurchaseRestoreWithZeroTransaction"
    static let kPaymentFailedCode = "PaymentServiceException"
    static let kFailedPaymentErrorTitle = "Payment failed!"
    static let kDuplicateUserErrorCode = "DuplicateKeyException"
    static let kSubscriptionServiceFailedErrorCode = "SubscriptionServiceException"
    static let kUserNotFoundInSubscripionFailedErrorCode = "NotFoundException"
    static let kIllegalArugmentExceptionFailedErrorCode = "IllegalArugmentException"
    static let PAYMENT_NOTIFICATION_CODE_KEY = "code"
    static let PAYMENT_NOTIFICATION_MESSAGE_KEY = "message"
    static let PAYMENT_NOTIFICATION_SUCCESS_KEY = "success"
    static let RESTORE_NO_PRODUCT_TITLE = "No Purchase Found"
    static let RESTORE_NO_PRODUCT_MESSAGE = "We were unable to found previous purchase with this account. Please check your iTunes credentials and try again."
    static let kIsSubscribedKey = "ISSUBSCRIBED"
    static let kCreateAccountTitle = "Sign Up"
    static let kSkipCreateAccountTitle = "Skip Sign Up"
    static let kRestoreSuccessTitle = "Restored Your Purchase Successfully"
    static let kRestoreSuccessMessageForNonLinkedAccount = "Your purchase has been successfully restored. Please create your login for syncing across platforms."
    static let kEntitlementErrorTitle = "Restricted Content"
    static let kEntitlementErrorMessage = "You need to be a subscriber to watch it."
    static let kEntitlementLoginErrorMessage = "You have to login to watch this movie."
    static let kRestorePurchaseFailureTitle = "Restore Purchase"
    static let kRestorePurchaseFailureMessage = "Unable to restore your purchase this time. Please make sure you are using same Apple ID that was used while purchase. Still facing issues please contact Apple."
    static let kiTunesConnectErrorMessage = "Unable to connect to iTunes Store"
    static let kCheckSubscriptionFailureMessage = "Unable to check subscription, Please connect to internet"
    static let IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE1  =    "ChromeCast_Animate-1_iOS"
    static let IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE2  =    "ChromeCast_Animate-2_iOS"
    static let IMAGE_NAV_BUTTON_CHROMECAST_ANIMATE3   =   "ChromeCast_Animate-3_iOS"
    static let IMAGE_NAV_BUTTON_CHROMECAST_NORMAL    =    "ChromeCast_Normal_Off"
    static let IMAGE_NAV_BUTTON_CHROMECAST_CONNECTED  =   "ChromeCast_HeaderTitle_iOS"
    static let IMAGE_NAV_BUTTON_CHROMECAST_HEADERTITLE  =  "ChromeCast_HeaderTitle_iOS"
    /** AppsFlyer Events **/
    static let APPSFLYER_EVENT_REGISTRATION = "Registration"
    static let APPSFLYER_EVENT_SUBSCRIPTION = "Subscription"
    static let APPSFLYER_EVENT_APPOPEN = "App open"
    static let APPSFLYER_EVENT_LOGIN = "Login"
    static let APPSFLYER_EVENT_FILMVIEWING = "Film viewing"
    static let APPSFLYER_EVENT_VIEWERSTATE = "Viewer state"
    static let APPSFLYER_EVENT_LOGOUT = "Logout"
    static let APPSFLYER_UNINSTALL = "Uninstall"
    
    
    
    static let APPSFLYER_KEY_EMAIL =  "af_email"
    static let APPSFLYER_KEY_COURSE_SUB_CATEGORY  =  "af_film_sub_category"
    static let APPSFLYER_KEY_UUID  = "UUID"
    static let APPSFLYER_KEY_DEVICEID = "Device ID"
    static let APPSFLYER_KEY_UNINSTALL = "Uninstall"
    static let APPSFLYER_KEY_FILMID =  "Film ID"
    static let APPSFLYER_KEY_COURSEID = "Course ID"
    static let APPSFLYER_KEY_COURSE_CATEGORY = "Category"
    static let APPSFLYER_KEY_REGISTER = "Registered"
    static let APPSFLYER_KEY_ENTITLED = "Entitled"
    static let  APPSFLYER_KEY_PLAN_NAME = "Product Name"
    
    static let  APPSFLYER_VALUE_ENTITLED = "true"
    static let  APPSFLYER_VALUE_NOTENTITLED = "false"
    static let  APPSFLYER_VALUE_REGISTER = "registered"
    
    
    static let kIsCCEnabled  = "isCCEnabled"
    
    static var buffercount = 0
    
    
    static let kUserOnlineTime = "UserOnlineTime"
    static let kUserOnlineTimeAlert = "This device has been disconnected from the internet for more than 30 days. To watch downloaded content on this device, we need to re-verify your account status. Please exit this app, connect to the internet and restart the app."
    
    
    //DownLoad Constants
    static let kStrDeleteDownloadAlertTitle = "Delete Download"
    static let kStrDeleteAllVideosFromDownloadAlertMessage = "Do you want to delete all videos from downloads?"
    static let kStrDeleteSingleVideoFromDownloadAlertMessage = "Do you want to delete video from downloads?"
    
    static let kDownloadQualitySelectionkey = "DownloadQualitySelectionkey"
    static let kDownloadCellularSelectionkey = "DownloadCellularSelectionkey"
    static let kDownloadingFromCellularData = "DownloadingFromCellularData"
    
    static let AFNetworkingReachabilityDidChangeNotification = "com.alamofire.networking.reachability.change"
    static let kMaxDownloadCapacity = 10
    static let kStartFreetrial = "Subscribe Now"
    static let kStartFreetrialMessage = "You must be a subscriber to download this movie."
    static let kUpgradeYourPlanMessage = "To download this movie you need to upgrade your plan"
    static let kGetMemberShipMessage = "Want more access to your DC sports teams? Become a member now so you don’t miss another play!"
    static let kStartFreetrialButton = "Start Free Trial"
    static let kManageSubsubcription = "Manage Subscription"
    static let kStoreURL = "https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"
    static let kDownloadAlertTitle = "Save Movie to Device"
    static let kDownloadAlertMessage = "Are you sure you want to download this movie for offline viewing?"
    static let kStrNO = "No"
    static let kStrYes = "Yes"
    static let kStrClose = "Close"
    static let kUseCellularData = "Use Cellular Data"
    static let kDownloadCapacityError = "You have already downloaded 10 movies. In order to download this movie delete any movie(s) from downloads first"
    static let kMemoryCapacityErrorTiltle = "Cannot Download"
    static let kMemoryCapacityErrorMesaage = "Your device does not have enough space to download the content! In order to free some memory: \n\n 1. Go to Settings\n2. Tap General\n3. Tap Storage & iCloud Usage\n4. Manage Storage"
    static let kStrOfflineWatchVideoError = "There is no network connection. While offline, you must go to My Downloads to watch downloaded"
    static let kStrMyDownloads = "MY DOWNLOADS"
    
    
    //GTM Events Constants
    static let kGTMLoginEvent = "login"
    static let kGTMLogoutEvent = "logout"
    static let kGTMSignUpEvent = "sign_up"
    static let kGTMSearchEvent = "search"
    static let kGTMSubmitSearchEvent = "submit_search"
    static let kGTMFinishSubscriptionEvent = "ecommerce_purchase"
    static let kGTMSelectSubscriptionPlanEvent = "add_to_cart"
    static let kGTMViewPlansPageEvent = "begin_checkout"
    static let kGTMStreamStartEvent = "stream_start"
    static let kGTMStream25PercentEvent = "stream_25_pct"
    static let kGTMStream50PercentEvent = "stream_50_pct"
    static let kGTMStream75PercentEvent = "stream_75_pct"
    static let kGTMStream100PercentEvent = "stream_100_pct"
    
    static let kGTMVideoIDAttribute = "video_id"
    static let kGTMVideoNameAttribute = "video_name"
    static let kGTMSeriesIDAttribute = "series_id"
    static let kGTMSeriesNameAttribute = "series_name"
    static let kGTMVideoPlayerTypeAttribute = "player"
    static let kGTMVideoMediaTypeAttribute = "media_type"
    static let kGTMProductIDAttribute = "item_id"
    static let kGTMProductNameAttribute = "item_name"
    static let kGTMProductCurrencyAttribute = "currency"
    static let kGTMProductValueAttribute = "value"
    static let kGTMProductTransactionIDAttribute = "transaction_id"
    static let kGTMSignUpMethodAttribute = "sign_up_method"
    static let kGTMSearchTermAttribute = "search_term"
    static let kGTMLoginMethodAttribute = "sign_in_method"
    static let kGTMEmailLoginMethod = "email"
    static let kGTMGmailLoginMethod = "Google"
    static let kGTMFacebookLoginMethod = "Facebook"
    
    static let kGTMUserIDProperty = "user_id"
    static let kGTMSubscriptionStatusProperty = "subscription_status"
    static let kGTMLoggedInProperty = "logged_in_status"
    static let kGTMCurrentSubscriptionIDProperty = "current_subscription_plan_id"
    static let kGTMCurrentSubscriptionNameProperty = "current_subscription_plan_name"
    static let kGTMSubscribedPropertyValue = "subscribed"
    static let kGTMNotSubscribedPropertyValue = "unsubscribed"
    static let kGTMLoggedInPropertyValue = "logged_in"
    static let kGTMNotLoggedInPropertyValue = "not_logged_in"
    
    static let kGTMNativePlayer = "Native"
    static let kGTMAirplayPlayer = "AirPlay"
    static let kGTMSecondScreenPlayer = "Chromecast"
    static let kGTMAudioContent = "Audio"
    static let kGTMVideoContent = "Video"
    static let RESUME_DOWNLOAD = "Resume Download"
    
    //Download Notification observer name
    static let kUpdateDownloadProgress = "UpdateDownloadProgress"
    static let kDownloadFinished = "DownloadFinished"
    static let kDownloadStatusUpdate = "DownloadStatusUpdate"
    static let kDownloadFailed = "DownloadFailed"
    static let kManageProgressViewState = "ManageProgressViewState"
    static let kDownloadObject = "downloadObject"
    static let kDownloadProgress = "downloadProgress"
    
    //App update  Notification observer
    static let kUpdateAppNotification = "App Updated"
    static let kAppConfigureNotification = "App Configured"
    
    //Kiswe constants
    static let kKisweFilmId  = "KISWEFILMID"
    
    //Watchlist constants
    static let kAddToWatchlist = "ADD TO WATCHLIST"
    static let kRemoveFromWatchlist = "REMOVE FROM WATCHLIST"

    //Readlist constants
    static let kAddToReadlist = "ADD TO READLIST"
    static let kRemoveFromReadlist = "REMOVE FROM READLIST"
    
    //Download constants
    static let kDownloaded = "DOWNLOADED"
    static let kPauseDownload = "PAUSE DOWNLOAD"
    static let kDownload = "DOWNLOAD"
    static let kResumeDownload = "RESUME DOWNLOAD"
    static let kQueuedDownload = "DOWNLOAD IN QUEUE"
    static let kDismissPIP = "dismissPIP"
    static let kPIPWidth_iPhone : CGFloat = 180
    static let kPIPHeight_iPhone : CGFloat = 100
    static let kPIPWidth_iPad : CGFloat = 270
    static let kPIPHeight_iPad : CGFloat = 150

    //Urban Airship Constants
    static let kChannelIdKeyName = "channel_id"
    static let kDeviceTypeKeyName = "device_type"
    static let kAudienceKeyName = "audience"
    static let kNameUserIdKeyName = "named_user_id"
    static let kAddTagKeyName = "add"
    static let kRemoveTagKeyName = "remove"
    static let kUserLoggedInStatusKeyName = "user_logged_in_status"
    static let kUserLoggedInStatusValue = "logged_in"
    static let kUserLoggedOutStatusValue = "logged_out"
    static let kUserSubscriptionStatusKeyName = "user_subscription_status"
    static let kUserSubscribedValue = "subscribed"
    static let kUserUnSubscribedValue = "unsubscribed"
    static let kUserSubscriptionEndDateKeyName = "subscription_end_date"
    static let kUserSubscriptionPlanKeyName = "plan_name"
    static let kUrbanAirshipAPIBaseUrl = "https://go.urbanairship.com"
    static let kUrbanAirshipUserAssociationEndPoint = "/api/named_users/associate"
    static let kUrbanAirshipUserDisAssociationEndPoint = "/api/named_users/disassociate"
    static let kUrbanAirshipNamedUserTagEndPoint = "/api/named_users/tags"
}
