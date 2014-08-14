//
//  AbsDBOperator.m
//  Sudasuta
//
//  Created by user on 14-3-24.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "AbsDBOperator.h"

@interface AbsDBOperator ()

@property (strong, nonatomic, readwrite) SQLiteOpenHelper *dbHelper;

@end

@implementation AbsDBOperator

- (id)initWithName:(NSString *)dbName version:(NSInteger)dbVersion
{
    self = [super init];
    if (self) {
        // Initialize DB helper
        if (nil == self.dbHelper) {
            self.dbHelper = [[SQLiteOpenHelper alloc] initWithName:dbName withVersion:dbVersion];
            [self establishDB];
        }
    }
    return self;
}

- (void)closeDB
{
    [self.dbHelper close];
    self.dbHelper = nil;
}

- (void)establishDB
{
    if(_dbHelper) {
        [_dbHelper getDatabase];
    }
}

- (void)closeCursor:(FMResultSet*) cursor
{
    if(nil != cursor) {
        [cursor close];
        cursor = nil;
    } else {
        NSLog(@"NOTE: cursor is null!!!");
    }
}

@end
