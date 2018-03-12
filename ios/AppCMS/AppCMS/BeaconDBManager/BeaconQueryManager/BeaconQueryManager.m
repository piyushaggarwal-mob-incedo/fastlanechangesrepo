//
//  BeaconQueryManager.m
//  SnagFilms
//
//  Created by Anirudh Vyas on 09/08/16.
//  Copyright © 2016 None. All rights reserved.
//

#import "BeaconQueryManager.h"
#import "DBManager.h"
#import "BeaconSyncManager.h"
#import "DebugLogger.h"

#define DBNAME @"beaconEvents.sql"
#define TABLENAME @"beaconEventTable"
#define TABLE_COLUMNS_QUERY @"beaconEventId INTEGER PRIMARY KEY AUTOINCREMENT, parameterString TEXT"

@interface BeaconQueryManager ()

#pragma mark - Properties
@property (nonatomic,strong) DBManager* dbManagerObj;
@property (nonatomic,assign) BOOL areThereAnyBeaconEventsToBeSynced;

@end

@implementation BeaconQueryManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        if(_dbManagerObj == nil)
        {
            [self createDBForBeaconEvents];
        }
    }
    return  self;
}

+(BeaconQueryManager *)sharedQueryManager
{
    static BeaconQueryManager* sharedObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[BeaconQueryManager alloc]init];
    });
    
    return sharedObj;
}

-(BOOL)areThereAnyBeaconEventsToBeSynced
{
    NSArray* arrayOfEventsToBeFetched = [self fetchTheUnsyncronisedBeaconEvents];
    if (arrayOfEventsToBeFetched && [arrayOfEventsToBeFetched count] > 0) {
        _areThereAnyBeaconEventsToBeSynced = YES;
    } else {
        _areThereAnyBeaconEventsToBeSynced = NO;
    }
    return _areThereAnyBeaconEventsToBeSynced;
}

/*!
 * @discussion Creates the DB for beacon events.
 */
-(void)createDBForBeaconEvents
{
    _dbManagerObj = [[DBManager alloc]initWithDatabaseFilename:DBNAME tableName:TABLENAME andTableColumnsQuery:TABLE_COLUMNS_QUERY];
}

-(NSArray *)fetchTheUnsyncronisedBeaconEvents
{
    NSString* queryToLoadAllData = [NSString stringWithFormat:@"select parameterString from %@",TABLENAME];
    return [_dbManagerObj loadDataFromDB:queryToLoadAllData];
}

-(void)addBeaconEventParameterStringToTheBeaconDB:(NSString *)beaconParameterString
{
    NSString* queryToAddBeaconEvent = [NSString stringWithFormat:@"insert into %@ values(null, '%@')",TABLENAME,beaconParameterString];
    [_dbManagerObj executeQuery:queryToAddBeaconEvent];
    if (_dbManagerObj.affectedRows == 0) {
        DebugLog(@"BEACON-> Failed to update DB after adding an event!");
    } else {
        DebugLog(@"BEACON-> Added Beacon Event to DB successfully!");
    }
}

-(void)removeBeaconEventFromTheBeaconDBWithParameterString:(NSString *)beaconParameterString
{
    NSString* queryToRemoveBeaconEvent = [NSString stringWithFormat:@"delete from %@ where parameterString='%@'",TABLENAME,beaconParameterString];
    [_dbManagerObj executeQuery:queryToRemoveBeaconEvent];
    if (_dbManagerObj.affectedRows == 0) {
        DebugLog(@"BEACON-> Failed to update DB after deleting an event!");
    } else {
        DebugLog(@"BEACON-> Removed Beacon Event from DB successfully!");
    }
}

@end
