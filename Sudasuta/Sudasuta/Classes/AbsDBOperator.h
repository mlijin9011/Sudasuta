//
//  AbsDBOperator.h
//  Sudasuta
//
//  Created by user on 14-3-24.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "SQLiteOpenHelper.h"

@interface AbsDBOperator : NSObject

@property (strong, nonatomic, readonly) SQLiteOpenHelper *dbHelper;

/**
 * Initialize the specified database with specified name and version.
 *
 * @param dbName    The specified database name.
 * @param dbVersion The specified database version.
 *
 * @return The database operation instance.
 */
- (id)initWithName:(NSString *)dbName version:(NSInteger)dbVersion;

/**
 * Establish the Database.
 */
- (void)establishDB;

/**
 * Close the database and finish the complement job.
 */
- (void)closeDB;

/**
 * Closes the Cursor, releasing all of its resources and making it completely invalid.
 * Unlike {@link #deactivate()} a call to {@link #requery()} will not make the Cursor valid
 * again.
 */
- (void)closeCursor:(FMResultSet*) cursor;

@end
