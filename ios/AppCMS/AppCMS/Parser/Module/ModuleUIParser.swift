//
//  ModuleUIParser.swift
//  SwiftPOCConfiguration
//
//  Created by Abhinav Saldi on 10/03/17.
//
//

import Foundation

class ModuleUIParser: NSObject {
    
    func parseModuleConfigurationJson(modulesConfigurationArray: Array<Dictionary<String, Any>>) -> Array<Any>
    {
        var modulesArray = Array<AnyObject>()
        
        for moduleDictionary: Dictionary<String, Any> in modulesConfigurationArray {
            
            var typeOfModule: String? = moduleDictionary["type"] as? String
            
            if typeOfModule == nil {
                
                typeOfModule = moduleDictionary["view"] as? String
            }
            
            if typeOfModule == "AC Carousel 01"
            {
                let carouselObjectParser = SFJumbotronModuleParser()
                let carouselObject = carouselObjectParser.parseJumbotronJson(jumbotronDict: moduleDictionary as Dictionary<String, AnyObject>)
                if carouselObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(carouselObject)
                }
            }
            else if typeOfModule == "AC SubNav 01" { 
                #if os(tvOS)
                    let viewParser = SFSubNavigationViewParser()
                    let viewObject = viewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if viewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(viewObject)
                    }
                #else
                    let listViewParser = SFListViewParser()
                    let listViewObject = listViewParser.parseListViewJson(listViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if listViewObject.layoutObjectDict.isEmpty == false {
                        
                        modulesArray.append(listViewObject)
                    }
                #endif
            }
            else if typeOfModule == "button" {
                
                let buttonParser = SFButtonParser()
                let buttonObject = buttonParser.parseButtonJson(buttonDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if buttonObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(buttonObject)
                }
            }
            else if typeOfModule == "image" {
                
                let imageParser = SFImageParser()
                let imageObject = imageParser.parseImageJson(imageDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if imageObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(imageObject)
                }
            }
            else if typeOfModule == "label" {
                
                let labelParser = SFLabelParser()
                let labelObject = labelParser.parseLabelJson(labelDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if labelObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(labelObject)
                }
            }
            else if typeOfModule == "textView" {
                
                let textViewParser = SFTextViewParser()
                let textViewObject = textViewParser.parseTextViewJson(textViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if textViewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(textViewObject)
                }
            }
            else if typeOfModule == "separatorView" {
                
                let separatorViewParser = SFSeparatorViewParser()
                let separatorViewObject = separatorViewParser.parseSeparatorViewJson(separatorViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if separatorViewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(separatorViewObject)
                }
            }
            else if typeOfModule == "AC ContentRatingWarning 01"  || typeOfModule == "AC ContentRating 01"{
                #if os(tvOS)
                let viewParser = SFCRWModuleViewParser()
                let viewObject = viewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if viewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(viewObject)
                }
                #endif
            }
            else if typeOfModule == "AC Tray 01" || typeOfModule == "AC SplashScreen 01" || typeOfModule == "AC ContinueWatching 01" || typeOfModule == "AC RichText 01"  || typeOfModule == "AC History 01" || typeOfModule == "AC Watchlist 01" || typeOfModule == "AC Grid 01" || typeOfModule == "AC Tray 02" || typeOfModule == "AC Tray 03" || typeOfModule == "AC Watchlist 02" || typeOfModule == "AC History 02" || typeOfModule == "AC BannerAd 01" || typeOfModule == "AC ArticleTray 01" {
                
                #if os(iOS)
                    let trayParser = SFTrayParser()
                    let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if trayObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(trayObject)
                    }
                #else
                    if typeOfModule == "AC Watchlist 01" || typeOfModule == "AC History 01" || typeOfModule == "AC Watchlist 02" || typeOfModule == "AC History 02" {
                        let watchlistParser = SFWatchlistAndHistoryViewParser()
                        let watchlistObject = watchlistParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        watchlistObject.contentPageType = (typeOfModule == "AC Watchlist 01" ? .watchlist : .history)
                        if watchlistObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(watchlistObject)
                        }
                    } else if typeOfModule == "AC RichText 01"{
                        let ancillaryParser = AncillaryViewParser()
                        let ancillaryObject = ancillaryParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        if ancillaryObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(ancillaryObject)
                        }
                    }
                    else {
                        let trayParser = SFTrayParser()
                        let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        if trayObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(trayObject)
                        }
                    }
                #endif
            }

            else if typeOfModule == "AC ArticlePage 01" || typeOfModule == "AC ArticleDetail 01"{
                #if os (iOS)
                let articleDetailModuleParser = SFArticleDetailModuleParser()
                let articleDetailObject = articleDetailModuleParser.parseArticleDetailJson(articleDetailDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if articleDetailObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(articleDetailObject)
                }
                #endif
            }
            else if typeOfModule == "AC Tray XX"
            {
                #if os(iOS)
                    let trayParser = SFTrayParser()
                    let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if trayObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(trayObject)
                    }
                #endif
            }
            else if typeOfModule == "AC Downloads 01"{
                
                let trayParser = SFTrayParser()
                let trayObject = trayParser.parseTrayJson(trayDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if trayObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(trayObject)
                }
            }
            else if typeOfModule == "AC VideoPlayerWithInfo 01" || typeOfModule == "AC VideoPlayerWithInfo 02" {
                
                let videoDetailModuleParser = SFVideoDetailModuleParser()
                let videoDetailModuleObject = videoDetailModuleParser.parseVideoDetailModuleJson(videoDetailModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if videoDetailModuleObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(videoDetailModuleObject)
                }
            }
            else if typeOfModule == "AC ShowDetail 01"
            {
                //#if os(iOS)
                let showDetailModuleParser = SFShowDetailModuleParser()
                let showDetailModuleObject = showDetailModuleParser.parseShowDetailModuleJson(showDetailModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if showDetailModuleObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(showDetailModuleObject)
                }
               // #endif
            }
            else if typeOfModule == "AC Episode Module"
            {
                #if os(iOS)
                let showGridDetailModuleParser = SFShowGridDetailModuleParser()
                let showGridDetailModuleObject = showGridDetailModuleParser.parseShowGridsModuleJson(showGridModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if showGridDetailModuleObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(showGridDetailModuleObject)
                }
                #endif
            }
            else if typeOfModule == "starRating"
            {
                let ratingViewParser = SFStarRatingParser()
                let ratingViewObject = ratingViewParser.parseStarRatingJson(starRatingDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if ratingViewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(ratingViewObject)
                }
            }
            else if typeOfModule == "tableView"
            {
                let tableViewParser = SFTableViewParser()
                let tableViewCellObject = tableViewParser.parseTableViewJson(tableViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if tableViewCellObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(tableViewCellObject)
                }
            }
            else if typeOfModule == "AC Authentication 01"
            {
                #if os(iOS)
                    let loginUIParser = LoginUIParser()
                    let loginViewObject = loginUIParser.parseLoginModuleJson(loginModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if loginViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(loginViewObject)
                    }
                #else
                    let loginViewParser = LoginViewParser_tvOS()
                    let loginViewObject = loginViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if loginViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(loginViewObject)
                    }
                #endif
            }
            else if typeOfModule == "AC SignUp 01"
            {
                #if os(tvOS)
                    let loginViewParser = LoginViewParser_tvOS()
                    let loginViewObject = loginViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if loginViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(loginViewObject)
                    }
                #endif
            }
            else if typeOfModule == "AC ResetPassword 01" || typeOfModule == "AC ResetPassword 02"
            {
                #if os(iOS)
                let loginUIParser = LoginUIParser()
                let loginViewObject = loginUIParser.parseLoginModuleJson(loginModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if loginViewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(loginViewObject)
                }
                #else
                    let loginViewParser = LoginViewParser_tvOS()
                    let loginViewObject = loginViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if loginViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(loginViewObject)
                }
                #endif
            }
            else if typeOfModule == "AC UserManagement 01" || typeOfModule == "AC UserManagement 02"
            {
                #if os(iOS)
                    let userAccountParser = UserAccountParser()
                    let userAccountObject = userAccountParser.parseUserComponentJson(userComponentDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if userAccountObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(userAccountObject)
                    }
                #else
                    if TEMPLATETYPE.uppercased() == Constants.kTemplateTypeSports {
                        let viewParser = SFSubNavigationViewParser()
                        let viewObject = viewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        if viewObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(viewObject)
                        }
                    } else {
                        let settingViewParser = SettingViewParser_tvOS()
                        let settingViewObject = settingViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        if settingViewObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(settingViewObject)
                        }
                    }
                #endif
            }
            else if typeOfModule == "AC ContactUs 01"
            {
                #if os(tvOS)
                    let contactUsViewParser = ContactUsViewParser_tvOS()
                    let contactUsViewObject = contactUsViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if contactUsViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(contactUsViewObject)
                    }
                #endif
            }
            else if typeOfModule == "AC SelectPlan 01" || typeOfModule == "AC SelectPlan 02"
            {
                #if os(iOS)
                    let productListParser = SFProductListParser()
                    let productListObject = productListParser.parseProductListJson(productListDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if productListObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(productListObject)
                    }
                #else
                    let loginViewParser = SubscriptionViewParser_tvOS()
                    let loginViewObject = loginViewParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if loginViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(loginViewObject)
                    }

                #endif
            }
            else if typeOfModule == "AC ImageTextRow 01"
            {
                #if os(iOS)
                    let productFeatureListParser = SFProductFeatureListParser()
                    let productFeatureListObject = productFeatureListParser.parseProductFeatureListJson(productFeatureListDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if productFeatureListObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(productFeatureListObject)
                    }
                #endif
            } else if typeOfModule == "AC Footer 01" || typeOfModule == "AC Footer 02"
            {
                #if os(tvOS)
                    let footerParser = SFFooterViewParser()
                    let footerViewObject = footerParser.parserLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if footerViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(footerViewObject)
                    }
                #endif
            }
            else if typeOfModule == "AC AutoPlay 01" || typeOfModule == "AC AutoPlayLandscape 01" || typeOfModule == "AC AutoPlay 02" || typeOfModule == "AC AutoPlay 03"
            {
                #if os(iOS)
                    let autoPlayParser = SFAutoplayParser()
                    let autoPlayObject = autoPlayParser.parseAutoplayModuleJson(autoplayModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    
                    if autoPlayObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(autoPlayObject)
                    }
                #else
                        let autoPlayParser = SFAutoPlayViewModuleViewParser()
                        let autoPlayViewObject = autoPlayParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                        if autoPlayViewObject.layoutObjectDict.isEmpty == false {
                            modulesArray.append(autoPlayViewObject)
                        }
                #endif
            }
            else if typeOfModule == "AC DownloadSettings 01"
            {
                #if os(iOS)
                    let downloadQualityParser = SFDownloadQualityParser()
                    let downloadQualityObject = downloadQualityParser.parseDownloadQualityModuleJson(downloadQualityModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if downloadQualityObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(downloadQualityObject)
                    }
                #endif
            } else if typeOfModule == "AC StandaloneVideoPlayer 01" {
                let viewParser = VideoPlayerModuleViewParser()
                let viewObject = viewParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                if viewObject.layoutObjectDict.isEmpty == false {
                    modulesArray.append(viewObject)
                }
            }
            else if typeOfModule == "AC Banner 01" {
                #if os(iOS)
                    let bannerViewParser = SFBannerViewParser()
                    let bannerViewObject = bannerViewParser.parseBannerViewJson(bannerViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if bannerViewObject.layoutObjectDict.isEmpty == false {
                        
                        modulesArray.append(bannerViewObject)
                    }
                #endif
            }else if typeOfModule == "AC RawHtml 01" 
            {
                #if os(tvOS)
                    let footerParser = SFRawTextViewParser()
                    let footerViewObject = footerParser.parseLayoutJson(viewModuleDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    if footerViewObject.layoutObjectDict.isEmpty == false {
                        modulesArray.append(footerViewObject)
                    }
                #endif
            }
            else if typeOfModule == "AC ArticleFeed 01" {
                #if os(iOS)
                    let verticalArticleViewParser = SFVerticalArticleViewParser()
                    let verticalArticleViewObject = verticalArticleViewParser.parseVerticalArticleViewJson(verticalArticleViewDictionary: moduleDictionary as Dictionary<String, AnyObject>)
                    
                    if verticalArticleViewObject.layoutObjectDict.isEmpty == false {
                        
                        modulesArray.append(verticalArticleViewObject)
                    }
                #endif
            }
        }
        
        return modulesArray
    }
    
}
