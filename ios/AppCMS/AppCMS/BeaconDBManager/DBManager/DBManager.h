//
//  DBManager.h
//  SnagFilms
//
//  Created by Anirudh Vyas on 09/08/16.
//  Copyright © 2016 None. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 * @brief DBManager- Class used to manage the sqlite DB. Wrapper for managing the DB.
 */
@interface DBManager : NSObject

/*!
 * @brief Column names present in a table in DB.
 */
@property (nonatomic, strong) NSMutableArray *arrColumnNames;

/*!
 * @brief Depicts the number of affected rows. Use this in order to check whether any rows were successfully inserted or not. Use this after the executeQuery method call.
 */
@property (nonatomic) int affectedRows;

/*!
 * @brief Access to the last inserted Row ID.
 */
@property (nonatomic) long long lastInsertedRowID;

/*!
 * @discussion Custom init method in order to provide DB Name, table Name and .
 * @param dbFilename - Name of the DB to be created.
 * @param tableName - Name of the Table to be created.
 * @param tableColumnsQuery - Query for creation of columns in table.
 * @return instancetype - Instance of DBManager class.
 */
-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename tableName:(NSString*)tableName andTableColumnsQuery:(NSString*)tableColumnsQuery;

/*!
 * @discussion Loads the data from the DB.
 * @param query - Query that needs to be executed.
 * @return NSArray* - Array of the results fetched.
 */
-(NSArray *)loadDataFromDB:(NSString *)query;

/*!
 * @discussion Executes the query provided by the calling method.
 * @param query - Query that needs to be executed.
 */
-(void)executeQuery:(NSString *)query;

@end
