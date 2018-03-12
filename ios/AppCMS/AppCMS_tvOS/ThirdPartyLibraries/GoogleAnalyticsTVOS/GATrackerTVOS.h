//
//  GATracker.h
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


#import <Foundation/Foundation.h>

@interface GATrackerTVOS : NSObject

NS_ASSUME_NONNULL_BEGIN
@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *appName;
@property (strong, nonatomic) NSString *appVersion;
@property (strong, nonatomic) NSString *MPVersion; // Measurement Protocol version
@property (strong, nonatomic) NSString *userAgent;
NS_ASSUME_NONNULL_END

+ (instancetype _Nonnull)sharedInstance;

- (void)setTrackingID:(NSString * _Nonnull)trackingID;

- (void)send:(NSString * _Nonnull)type parameters:(NSDictionary * _Nullable)userParams;

- (void)screenView:(NSString * _Nonnull)screenName customParameters:(NSDictionary * _Nullable)userParams;

- (void)eventWithCategory:(NSString * _Nonnull)category
                   action:(NSString * _Nonnull)action
                    label:(NSString * _Nullable)label
         customParameters:(NSDictionary * _Nullable)userParams;

- (void)exceptionWithDescription:(NSString * _Nonnull)description fatal:(BOOL)fatal customParameters:(NSDictionary * _Nullable)userParams;

@end
