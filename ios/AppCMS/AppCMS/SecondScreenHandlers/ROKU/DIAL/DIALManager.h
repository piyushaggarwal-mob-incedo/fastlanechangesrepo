/*
 * DIALManager.h
 * Copyright (C) 2013 Roku, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "Discovery.h"

// delegate for XML fetches
@protocol FetchEventsDelegate <NSXMLParserDelegate>

- (void) parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string;

- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName;

-(void) parserDidEndDocument: (NSXMLParser *)parser;

@end

// listener for the device description details query
@interface DetailsFetchListener : NSObject<FetchEventsDelegate>

@property NSObject *owner;
@property (nonatomic, copy) NSString *element;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *manufacturer;
- (id)initWithOwner:(NSObject *) owner;

@end


// DIALManager interface
@interface DIALManager : NSObject

@property(nonatomic, strong) NSString* movieID;
@property(nonatomic, strong) NSString* appURL;
- (NSString *) launchApp:(NSString *)URL forAppName:(NSString *)textAppName videoUrl:(NSString *)videoUrl;
- (NSString *) launchApp: (NSString *)URL appName :(NSString *)textAppName videoUrl:(NSString*)videoUrl;
- (void) fetchDetails: (DiscoveredRokuBox *)box;
- (void) postXML: (NSString *)URL :(NSString *) postURL;
- (void) sendDelete: (NSString *) URL;
- (BOOL)checkForRokudevice:(DiscoveredRokuBox*)box;
@end

