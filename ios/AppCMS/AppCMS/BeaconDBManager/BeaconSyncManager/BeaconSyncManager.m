//
//  BeaconSyncManager.m
//  SnagFilms
//
//  Created by Anirudh Vyas on 10/08/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "BeaconSyncManager.h"
#import "Reachability.h"
#import "BeaconQueryManager.h"
#import "DebugLogger.h"

@interface BeaconSyncManager ()

@property (nonatomic,assign) BOOL isSyncingInProcess;
@property (nonatomic,strong) BeaconQueryManager* queryManager;
@property (nonatomic,assign) NSInteger countOfTotalRequestsMade;
@property (nonatomic,assign) NSInteger countOfSuccessfulResponses;

@end

@implementation BeaconSyncManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self stayAlertForNetworkChanges];
        _queryManager = [BeaconQueryManager sharedQueryManager];
    }
    return  self;
}

+(BeaconSyncManager *)sharedSyncManager
{
    static BeaconSyncManager* sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[BeaconSyncManager alloc]init];
    });
    
    return sharedObj;
}

/*!
 * @discussion Add the observers for network changes.
 */
-(void)stayAlertForNetworkChanges{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionChanged:) name:@"networkStatus" object:nil];
}

-(void)startSyncingTheEventsWithSuccess:(void (^)(BOOL))success
{
    //If syncing is in process, do not sync again!
    if (_isSyncingInProcess) {
        return;
    }
    NSArray* arrayOfBeaconEvents = [_queryManager fetchTheUnsyncronisedBeaconEvents];
    if (arrayOfBeaconEvents && [arrayOfBeaconEvents count] > 0) {
        [self startTheSyncProcessForTheBeaconEventsWithEvents:arrayOfBeaconEvents withSuccess:success];
    }
}

#pragma mark - Private Methods.

/*!
 * @discussion Method called when the notification for connectivity change is received. Checks and starts the sync process, if there are items which need to be synced.
 * @param notification - NSNotification object which is fired.
 */
-(void)networkConnectionChanged:(NSNotification*)notification
{
    //If syncing is in process, do not sync again!
    if (_isSyncingInProcess) {
        return;
    }
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] != NotReachable) {
        NSArray* arrayOfBeaconEvents = [_queryManager fetchTheUnsyncronisedBeaconEvents];
        if (arrayOfBeaconEvents && [arrayOfBeaconEvents count] > 0) {
            [self startTheSyncProcessForTheBeaconEventsWithEvents:arrayOfBeaconEvents withSuccess:nil];
        }
    }
}

/*!
 * @discussion Call this method to sync the cached beacon events to the beacon server. In this the array passed it iterated through and then beacon events are posted 
 * @param beaconEventsToBeSynced - Beacon events array that needs to be synced.
 * @param success - Success callback block.
 */
-(void)startTheSyncProcessForTheBeaconEventsWithEvents:(NSArray*)beaconEventsToBeSynced withSuccess:(void (^)(BOOL))success
{
    _isSyncingInProcess = YES;
    _countOfTotalRequestsMade = [beaconEventsToBeSynced count];
    __weak typeof(self) weakSelf = self;
    for (NSArray* parameterStringArray in beaconEventsToBeSynced) {
        [self postBeaconEventWithParameterString:[parameterStringArray objectAtIndex:0] andSuccess:^(BOOL success) {
            //Check if the success callback is received. If success is YES, then delete that from the DB.
            _countOfSuccessfulResponses++;
            if (success == YES) {
                //Dispatch Sync - As this ensures serial execution of blocks. As accessing the DB after on multi threads, locks the DB.
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [weakSelf.queryManager removeBeaconEventFromTheBeaconDBWithParameterString:[parameterStringArray objectAtIndex:0]];
                });
            }
            if (_countOfSuccessfulResponses == _countOfTotalRequestsMade) {
                _isSyncingInProcess = NO;
                _countOfTotalRequestsMade = 0;
                _countOfSuccessfulResponses = 0;
            }
        }];
    }
}

/*!
 * @discussion Posts beacon events to the server.
 * @param parameterString - Parameter string to be posted.
 * @param success - Callback when reposnse from server is received.
 */
-(void)postBeaconEventWithParameterString:(NSString*)parameterString andSuccess:(void(^)(BOOL success))success{
    NSMutableURLRequest  * request= [[NSMutableURLRequest alloc] init];
    NSString* stringURL = [NSString stringWithFormat:@"https://beacon.viewlift.com/events?%@",parameterString];
    NSURL* urlForRequest = [NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [request setURL:urlForRequest];
    [request setHTTPMethod:@"Post"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * response, NSData *data, NSError *error) {
        if (error) {
            success(NO);
            DebugLog(@"BEACON SYNC-> Failed to log the beacon event!");
            return ;
        }
        else{
            success(YES);
            DebugLog(@"BEACON SYNC-> Successfully logged the beacon event!");
        }
    }];
}

#pragma mark - Dealloc

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"networkStatus" object:nil];
}
@end
