//
//  FavouriteOpenHelper.m
//  Sudasuta
//
//  Created by user on 14-7-15.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "FavouriteOpenHelper.h"
#import "FMDatabase.h"

@interface FavouriteOpenHelper ()

- (void)createFavouriteTable:(FMDatabase *)db;
- (void)dropFavouriteTable:(FMDatabase *)db;

@end

@implementation FavouriteOpenHelper

- (void)createFavouriteTable:(FMDatabase *)db
{
    NSMutableString *sqlString = [[NSMutableString alloc] init];
    
    [sqlString appendFormat:@"CREATE TABLE IF NOT EXISTS %@(", kTableFavourite];
    [sqlString appendFormat:@"%@ INTEGER PRIMARY KEY,", kFavouriteColumnAutoId];
    [sqlString appendFormat:@"%@ TEXT,", kFavouriteColumnUrl];
    [sqlString appendFormat:@"%@ TEXT,", kFavouriteColumnKeyword];
    [sqlString appendFormat:@"%@ INTEGER", kFavouriteColumnTime];
    [sqlString appendFormat:@");"];
    
    if ([db executeUpdate:sqlString]) {
        NSLog(@"Create Favorite Table Success...");
    }
}

- (void)dropFavouriteTable:(FMDatabase *)db
{
    NSString *sqlString = [[NSString alloc] initWithFormat:@"DROP TABLE IF EXISTS %@", kTableFavourite];
    [db executeUpdate:sqlString];
}

- (void)onCreate:(FMDatabase *)db
{
    [super onCreate:db];
    [self createFavouriteTable:db];
}

- (void)onOpen:(FMDatabase *)db
{
    [super onOpen:db];
    [databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"PRAGMA foreign_keys=ON"];
    }];
}

- (void)onUpgrade:(FMDatabase *)db
{
    [super onUpgrade:db];
    [self dropFavouriteTable:db];
}

- (void)onDowngrade:(FMDatabase *)db
{
    [super onDowngrade:db];
}

@end
