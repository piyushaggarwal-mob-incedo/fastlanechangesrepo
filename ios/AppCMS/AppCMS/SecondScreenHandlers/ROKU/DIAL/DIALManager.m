/*
 * DIALManager.m
 * Copyright (C) 2011 Roku, Inc. All rights reserved.
 */

#import "DIALManager.h"

@interface DIALManager ()
{
    BOOL toDisconnect;
}

@end

@implementation DIALManager : NSObject

// Example URL to launch
//NSString *videoURL = @"http://video.ted.com/talks/podcast/DavidKelley_2002_480.mp4";


- (NSString *) launchApp:(NSString *)URL forAppName:(NSString *)textAppName videoUrl:(NSString *)videoUrl
{
    NSString* getAppListUrl = [NSString stringWithFormat:@"%@/query/apps", URL];
    NSURL *url = [NSURL URLWithString: getAppListUrl];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL: url];
    [request setHTTPMethod:@"GET"];
    NSHTTPURLResponse *response;
    NSError *err;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    return @"";
}

- (NSString *) launchApp: (NSString *)URL appName :(NSString *)textAppName videoUrl:(NSString*)videoUrl
{
    _appURL = URL;
    toDisconnect = NO;
    NSURL *url = [NSURL URLWithString: URL];
    NSDictionary *dictionary;
    _movieID = videoUrl;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL: url];
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    NSError *err;
    NSData *returnData = [ NSURLConnection sendSynchronousRequest: request returningResponse:&response error:&err];
    
    // should poilsh this up so we display a more graceful message that we couldn't find DIAL or w/e
    if (err)
    {
        return @"";
    }
    
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        dictionary = [response allHeaderFields];
    }
    
    if (dictionary == nil)
        return nil;
    
    
    NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
    
    if (content != nil)
    {
        //NSLog(@"Content Payload %@", content);
    }
    
    NSString *launchURL = [NSString stringWithFormat: @"%@", [self returnApplicationUrl:[dictionary valueForKey: @"Application-URL"] WithAppID: textAppName]];
    
    NSLog(@"Launch URL: %@", launchURL);
    
    [self postXML: launchURL : videoUrl];
    
    return launchURL;
}

- (NSString*)returnApplicationUrl:(NSString*)appUrl WithAppID:(NSString*)appID
{
    NSMutableString* appUrlString = [NSMutableString stringWithFormat:@"%@", appUrl];
    if (![[appUrl substringFromIndex:[appUrl length] - 1] isEqualToString:@"/"]) {
        [appUrlString appendString:@"/"];
    }
    [appUrlString appendString:appID];
    return appUrlString;
}

// fetches the details by calling the dd.xml on the device
- (void) fetchDetails: (DiscoveredRokuBox *) box
{
    NSLog(@"PARSE XML FILE AT URL CALLED");
    NSURL* url = [NSURL URLWithString: box.dialURL];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    DetailsFetchListener *listener = [[DetailsFetchListener alloc] initWithOwner:self];
    [parser setDelegate: listener];
    [parser parse];
    
    box.modelName = listener.modelName;
    box.serialNumber = listener.serialNumber;
    box.friendlyName = listener.friendlyName;
    box.manufacturer = listener.manufacturer;
    return;
}

- (BOOL)checkForRokudevice:(DiscoveredRokuBox*)box
{
    BOOL upnpDevice = NO;
    NSArray* urlElements = [box.dialURL componentsSeparatedByString:@"/"];
    if ([urlElements count] > 3) {
        NSString* udpString = [urlElements objectAtIndex:3];
        //Checking for only ROKU device!
        if (![udpString isEqualToString:@"ssdp"] && ([[box.modelName lowercaseString] rangeOfString:@"fire"].location == NSNotFound)) {
            upnpDevice = YES;
        }
    }
    return upnpDevice;
}

// posts the application parameters to launch the app
- (void) postXML: (NSString *)URL :(NSString *) postURL
{
    
    NSMutableString *post = [[NSMutableString alloc] init];
    
    // videoURL is not a required parameter,
    // it's just what we use for our DIAL example BrightScript app
//    [post appendString: @"videoURL="];
    
//    // escape the URL for post parameters
//    NSString *escapedString = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
//                                                                                                     NULL,
//                                                                                                     (__bridge CFStringRef) postURL,
//                                                                                                     NULL,
//                                                                                                     CFSTR("!*'();:@&=+$,/?%#[]"),
//                                                                                                     kCFStringEncodingUTF8));
    [post appendString: postURL];
    NSLog(@"DIALManager: postXML: post parameters: %@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL: [NSURL URLWithString: URL]];
    [request setHTTPMethod: @"POST"];
    [request setValue: postLength forHTTPHeaderField: @"Content-Length"];
    [request setValue: @"text/plain; charset=\"utf-8\"" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: postData];
    
    
    NSURLResponse *response;
    NSError *err;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request
                                          returningResponse: &response
                                          error: &err];
    
    // should polish this up so we display a more graceful message
    // that we couldn't find DIAL or w/e
    if (err)
    {
//        [self showAlertForAppNotAvailable];
        return;
    }
    
    NSInteger responseCode = [(NSHTTPURLResponse*)response statusCode];
    switch (responseCode) {
        case 200:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FireTVConnected" object:nil];
            break;
        case 201:
            if (!toDisconnect) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:FIRETV_CONNECTED_NOTIFICATION object:nil];
            }
            else
            {
//                [[NSNotificationCenter defaultCenter] postNotificationName:FIRETV_DISCONNECTED_NOTIFICATION object:nil];
            }
            NSLog(@"Application running");
            break;
        case 404:
//            [[NSNotificationCenter defaultCenter] postNotificationName:FIRETV_DISCONNECTED_NOTIFICATION object:nil];
//            [self showAlertForAppNotAvailable];
            break;
        case 413:
            NSLog(@"Request entity too large");
            break;
        case 503:
//            [self showAlertForAppNotAvailable];
            NSLog(@"Service unavailable");
            break;
        default:
            break;
    }
    
    /// debug
    if (returnData != nil)
    {
        NSString *content = [NSString stringWithUTF8String:[returnData bytes]];
        NSLog(@"DIALManager: postXML: responseData: %@", content);
    }
}

//-(void)showAlertForAppNotAvailable
//{
//    //Make the attributed string for alert title as title of alert has to be shown in a single line.
//    NSDictionary *attributedDict = [NSDictionary dictionaryWithObject:FONT_WATCHLIST_ALERT_TITLE forKey:NSFontAttributeName];
//    NSMutableAttributedString *attributedTitleString = [[NSMutableAttributedString alloc] initWithString:@"Error Connecting to Roku." attributes: attributedDict];
//    UIAlertController* alert=[UIAlertController alertControllerWithTitle:[attributedTitleString string] message:@"Error connecting to Roku! Please check the internet connection and try again. Please check if the The Great Courses Plus Application is installed on the device as well." preferredStyle:UIAlertControllerStyleAlert];
//    [alert setValue:attributedTitleString forKey:@"attributedTitle"];
//    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:STR_BUTTON_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [alert addAction:alertAction];
//    DrawerController* drawerController = (DrawerController*)[UIApplication sharedApplication].keyWindow.rootViewController;
//    if (drawerController) {
//        UIViewController* viewController = drawerController.centerViewController;
//        if (viewController) {
//            [viewController presentViewController:alert animated:YES completion:nil];
//        }
//    }
//}

// sends the HTTP DELETE command to stop playing the app
- (void) sendDelete: (NSString *) URL
{
    toDisconnect = YES;
    
    if (URL == nil)
        return;
    
    NSLog(@"DIALManager sendDelete: %@", URL);
    
    // the "stop" command requires an HTTP DELETE method be sent
    // also, the url is the app launch url + /run
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"%@/run", URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    [request setHTTPMethod: @"DELETE"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: nil];
}


@end


@implementation DetailsFetchListener

// sets the parent
- (id)initWithOwner:(NSObject *)owner
{
    self = [super init];
    if (self != nil) {
        self.owner = owner;
    }
    return self;
}

// parses out the data between the element tags
- (void) parser:(NSXMLParser *) parser
foundCharacters:(NSString *) elementValue
{
    if (self.element == nil)
        self.element = [[NSMutableString alloc] init];
    
    self.element = elementValue;
}

// processes the closing tag for the element
- (void) parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qName
{
    if ([elementName isEqual: @"serialNumber"])
    {
        self.serialNumber = self.element;
    }
    else if ([elementName isEqual: @"modelName"])
    {
        self.modelName = self.element;
    }
    else if ([elementName isEqualToString:@"friendlyName"])
    {
        self.friendlyName = self.element;
    }
    else if ([elementName isEqualToString:@"manufacturer"])
    {
        self.manufacturer = self.element;
    }
}

// just lets us know the document has finished
-(void) parserDidEndDocument: (NSXMLParser *)parser
{
    NSLog(@"DetailsFetchListener parserDidEndDocument");
}

@end
