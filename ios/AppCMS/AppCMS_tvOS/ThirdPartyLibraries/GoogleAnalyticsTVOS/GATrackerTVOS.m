//
//  GATracker.m
//
//  Created by Jota Melo on 12/13/15.
//  Copyright © 2015 Jota. All rights reserved.
//
//Copyright (c) 2015, Jota Melo
//
//
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


#import "GATrackerTVOS.h"

#define CLIENT_ID_KEY @"_GAClientID"

@interface GATrackerTVOS ()

@property (strong, nonatomic) NSString *propertyID;

@end

@implementation GATrackerTVOS

+ (instancetype _Nonnull)sharedInstance
{
    static GATrackerTVOS *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

- (void)setTrackingID:(NSString * _Nonnull)trackingID
{
#if DEBUG
    NSLog(@"Initializing GATracker");
#endif
    
    self.propertyID = trackingID;
    self.appName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    self.appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    self.userAgent = @"Mozilla/5.0 (Apple TV; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13T534YI";
    self.MPVersion = @"1";
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:CLIENT_ID_KEY])
        self.clientID = [defaults objectForKey:CLIENT_ID_KEY];
    else {
        self.clientID = [NSUUID UUID].UUIDString;
        
        [defaults setObject:self.clientID forKey:CLIENT_ID_KEY];
        [defaults synchronize];
    }
}

- (void)send:(NSString * _Nonnull)type parameters:(NSDictionary * _Nullable)userParams
{
    NSAssert(self.propertyID, @"Tracking ID not set. Call -[GATracker setTrackingID:] to initialize");
    
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://ssl.google-analytics.com/collect?"];
    
    NSString *deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];//added device language
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableDictionary *params = @{@"v": self.MPVersion,
                                    @"an": self.appName,
                                    @"tid": self.propertyID,
                                    @"av": self.appVersion,
                                    @"cid": self.clientID,
                                    @"ul": deviceLanguage,
                                    @"t": type,
                                    @"ua": self.userAgent,
                                    @"sr":@"1920x1080", //added screen resolution
                                    @"aid":bundleIdentifier,
                                    @"ds": @"tv"}.mutableCopy;
    [params addEntriesFromDictionary:userParams];
    
    NSMutableArray *queryItems = @[].mutableCopy;
    for (NSString *key in params) {
//        NSString *encodedValue = [params[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:params[key]]];
    }
    
    components.queryItems = queryItems;
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:components.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
#if DEBUG
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        NSLog(@"%ld", HTTPResponse.statusCode);
#endif
    }];
    [task resume];
}

- (void)screenView:(NSString * _Nonnull)screenName customParameters:(NSDictionary * _Nullable)userParams
{
    NSMutableDictionary *params = @{@"cd": screenName}.mutableCopy;
    
    if (userParams)
        [params addEntriesFromDictionary:userParams];
    
    [self send:@"screenView" parameters:params];
}

- (void)eventWithCategory:(NSString * _Nonnull)category
                   action:(NSString * _Nonnull)action
                    label:(NSString * _Nullable)label
         customParameters:(NSDictionary * _Nullable)userParams
{
    NSMutableDictionary *params = @{@"ec": category, @"ea": action, @"el": label ? label : @""}.mutableCopy;
    
    if (userParams)
        [params addEntriesFromDictionary:userParams];
    
    [self send:@"event" parameters:params];
}

- (void)exceptionWithDescription:(NSString * _Nonnull)description fatal:(BOOL)fatal customParameters:(NSDictionary * _Nullable)userParams
{
    NSMutableDictionary *params = @{@"exd": description, @"exf": fatal ? @"1" : @"0"}.mutableCopy;
    
    if (userParams)
        [params addEntriesFromDictionary:userParams];
    
    [self send:@"exception" parameters:params];
}

@end
