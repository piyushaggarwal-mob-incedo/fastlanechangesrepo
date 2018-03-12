//
//  Discovery.m
//  Copyright (c) 2013 Roku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoveredRokuBox : NSObject
@property (nonatomic) int node;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, copy) NSString *modelName;
@property (nonatomic, copy) NSString *modelNumber;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *friendlyName;
@property (nonatomic, copy) NSString *dialURL;
@property (nonatomic, copy) NSString *manufacturer;
@end


@protocol DiscoveryEventsDelegate <NSObject>
- (void)onFound:(const DiscoveredRokuBox *)box;
- (void)onFinished:(int)count;
@end

@interface Discovery : NSObject
+(Discovery *)sharedDiscovery;
- (void) startSSDPBroadcast:(NSObject<DiscoveryEventsDelegate> *)listener;
@end
