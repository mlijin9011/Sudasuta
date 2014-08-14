//
//  FavouriteDBOperator.m
//  Sudasuta
//
//  Created by user on 14-7-15.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "FavouriteDBOperator.h"
#import "FMDatabase.h"
#import "CommonConstant.h"

static const NSString *tempColumn[] =
{
    kFavouriteColumnAutoId,
    kFavouriteColumnUrl,
    kFavouriteColumnKeyword,
    kFavouriteColumnTime
};

@implementation FavouriteDBOperator

- (id)initWithName:(NSString *)name withVersion:(NSInteger)version
{
    self = [super init];
    if (nil != self) {
        if (version < 1) {
            version =  1;
        }
        self.favouriteHelper = [[FavouriteOpenHelper alloc]initWithName:name withVersion:version];
        if (nil != self.favouriteHelper) {
            [self.favouriteHelper getDatabase];
            
            self.tempImage = nil;
        }
    }
    return self;
}

- (NSArray *)getAllFavourite
{
    __block NSMutableArray *allFavourite = [[NSMutableArray alloc] init];
    
    [self.favouriteHelper inDatabase:^(FMDatabase *db){
        FMResultSet *cursor;
        @try {
            cursor = [db executeQueryWithTable:kTableFavourite
                                   withColumns:tempColumn
                               withColumnCount:_countof(tempColumn)
                                 withSelection:nil
                             withSelectionArgs:nil
                                   withGroupBy:nil
                                    withHaving:nil
                                   withOrderBy:kFavouriteColumnAutoId
                                     withLimit:nil];
            if (nil != cursor) {
                while ([cursor next]) {
                    Image *image = [[Image alloc] init];
                    image.url = [cursor stringForColumn:kFavouriteColumnUrl];
                    [allFavourite addObject:image];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"exception: %@", exception);
        }
        @finally {
            [cursor close];
        }
    }];
    
    return allFavourite;
}

@end
