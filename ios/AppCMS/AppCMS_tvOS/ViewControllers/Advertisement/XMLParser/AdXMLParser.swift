//
//  XMLParser.swift
//  AppCMS
//
//  Created by Dheeraj Singh Rathore on 18/07/17.
//  Copyright © 2017 Viewlift. All rights reserved.
//

import UIKit


private let MEDIA_FILE = "MediaFile"


protocol AdXMLParserDelegate: class {
    func advURlToBePlayed(adURLToPlay: String?, skipDuration:Int?)
}

class AdXMLParser: NSObject , XMLParserDelegate {
    
    ///XML URL to parse.
    var xmlUrlToParse : String
    
    var isMediaFileElementFound : Bool = false
    
    var isSkipDurationFound : Bool = false
    
    var  adUrlString : String?
    
    var  skipDurationString : String?
    
    var  skipDuration: Int?
    
    /// Timer used for tracking the response time for parsing an ad URL.
    weak var timerForXMLResponse : Timer?
    
    
    ///stored property parser used for XML Parsing.
    var parser : XMLParser?
    
    //Create  delegate property of MenuViewControllerDelegate.
    weak var delegate:AdXMLParserDelegate?
   
    init(xmlURl : String) {
        
        self.xmlUrlToParse = xmlURl
        super.init()
    }
    
    deinit {
//        print("deinit called for AdXMLParser  class.")
    }
    
    func configureParserAndStartParsing() -> Void {
        
        let url = URL.init(string: self.xmlUrlToParse)
        ///Cretae XMLParser object.
        parser = XMLParser.init(contentsOf: url!)!
        
        ///Set Parser delegate
        parser?.delegate = self
        
        setTimerForXMLParsing()

        ///Start Parsing
        parser?.parse()
        
    }
    
    
    /**
     setTimerForXMLParsing method start timer for 10 sec which is used to handle request time out for XML Parser.
     */
    private func setTimerForXMLParsing() {
        timerForXMLResponse = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(stopParsingAndFireError), userInfo: nil, repeats: false)
    }
    
    
    @objc private func stopParsingAndFireError() {
        timerForXMLResponse?.invalidate()
        parser?.abortParsing()
        delegate?.advURlToBePlayed(adURLToPlay: nil, skipDuration: nil)
    }
    
    
    //MARK:- XMLParser Delegate methods
    
    /**
       parserDidStartDocument delegate method is called when XMLParser start parsing the XML document
      - Parameter XMLParser: instance of xml Parser that is used for parsing xml file.
     */
    func parserDidStartDocument(_: XMLParser){
        //print("<--------XMLParser begins parsing a document.---------->")
    }
    
    
    func parser(_: XMLParser, didStartElement: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String] = [:]){
        if (didStartElement == MEDIA_FILE && attributes["type"] == "video/mp4"){
            isMediaFileElementFound = true
        }
        if didStartElement == "Linear" && attributes["skipoffset"] != nil {
            skipDurationString = attributes["skipoffset"] as String?
            let last2 = skipDurationString?.suffix(2)
            if let duration = last2 {
                skipDuration = Int(duration)
            }
            isSkipDurationFound = true
        }
    }
    
    func parser(_: XMLParser, foundCharacters: String){
        if isMediaFileElementFound {
            //print("<------------representing all or part of the characters of the current element. \(foundCharacters).------->")
            adUrlString = foundCharacters as String?
            isMediaFileElementFound = false
        }
    }
    
   
    func parser(_: XMLParser, didEndElement: String, namespaceURI: String?, qualifiedName: String?){
        if (didEndElement == MEDIA_FILE ){
            //print("<------------XMLParser encounters a end tag for a given element\(didEndElement).------->")
        }
    }
    
    
    func parserDidEndDocument(_: XMLParser){
        //print("<--------XMLParser has successfully completed parsing.---------->")
        timerForXMLResponse?.invalidate()
        delegate?.advURlToBePlayed(adURLToPlay: adUrlString, skipDuration: skipDuration)
    }
    
    func parser(_: XMLParser, parseErrorOccurred: Error){
        timerForXMLResponse?.invalidate()
        delegate?.advURlToBePlayed(adURLToPlay: nil, skipDuration: nil)
    }
    
    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        timerForXMLResponse?.invalidate()
    }
}
