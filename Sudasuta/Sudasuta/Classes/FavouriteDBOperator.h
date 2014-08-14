//
//  FavouriteDBOperator.h
//  Sudasuta
//
//  Created by user on 14-7-15.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FavouriteOpenHelper.h"
#import "Image.h"

@interface FavouriteDBOperator : NSObject

@property (strong, nonatomic) FavouriteOpenHelper *favouriteHelper;
@property (strong, nonatomic) NSMutableDictionary *tempImage;

- (id)initWithName:(NSString *)name withVersion:(NSInteger)version;
- (NSArray *)getAllFavourite;

@end
