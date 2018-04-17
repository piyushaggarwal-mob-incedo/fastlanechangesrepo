//
//  BeaconSyncManager.h
//  SnagFilms
//
//  Created by Anirudh Vyas on 10/08/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief BeaconSyncManager- Class used to sync the Offline Beacon Events. Has methods exposed to sync the beacon events to the server.
 */
@interface BeaconSyncManager : NSObject

/*!
 * @discussion Shared Instance of Sync Manager.
 * @return BeaconSyncManager instance.
 */
+(BeaconSyncManager*)sharedSyncManager;

/*!
 * @discussion Syncronizes the beacon events to the beacon server.
 * @param success - Callback when events get synced successfully.
 */
-(void)startSyncingTheEventsWithSuccess:(void(^)(BOOL success))success;


@end
