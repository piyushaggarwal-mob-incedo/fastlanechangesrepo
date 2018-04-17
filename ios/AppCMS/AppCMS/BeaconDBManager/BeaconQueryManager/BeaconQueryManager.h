//
//  BeaconQueryManager.h
//  SnagFilms
//
//  Created by Anirudh Vyas on 09/08/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief BeaconQueryManager- Class used to handle queries for interacting with the DB.
 */
@interface BeaconQueryManager : NSObject

#pragma mark - Methods.

/*!
 * @discussion Shared Instance of Query Manager.
 * @return BeaconQueryManager instance.
 */
+(BeaconQueryManager*)sharedQueryManager;

/*!
 * @discussion Tells whether the beacon events exist in DB or not.
 * @return BOOL YES - If there are; NO - If there aren't any.
 */
-(BOOL)areThereAnyBeaconEventsToBeSynced;

/*!
 * @discussion Fetches the Unsynced beacon events for a given user.
 * @return NSArray* - Returns of the unsynced beacon events.
 */
-(NSArray*)fetchTheUnsyncronisedBeaconEvents;

/*!
 * @discussion Adds beacon event parameter string to the DB.
 * @param beaconParameterString - beaconParameterString: Beacon event parameter string to be added to the DB.
 */
-(void)addBeaconEventParameterStringToTheBeaconDB:(NSString*)beaconParameterString;

/*!
 * @discussion Remove beacon event from the DB.
 * @param beaconParameterString - beaconParameterString: Beacon event parameter string to be removed from the DB.
 */
-(void)removeBeaconEventFromTheBeaconDBWithParameterString:(NSString*)beaconParameterString;

@end
