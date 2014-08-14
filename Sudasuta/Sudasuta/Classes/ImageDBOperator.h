//
//  ImageDBOperator.h
//  Sudasuta
//
//  Created by user on 14-3-24.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "AbsDBOperator.h"
#import "Image.h"

@interface ImageDBOperator : AbsDBOperator

+ (ImageDBOperator *)sharedInstance;

- (NSArray *)getAllGroupIds:(NSString *)withCategory;
- (NSArray *)getGroupsWith:(NSArray *)ids;
- (NSArray *)getImagesBy:(NSInteger)groupId;
- (void)fillImage:(ImageGroup *)imageGroup;
- (BOOL)updateFavoriteImage:(Image *)image;
- (NSArray *)getArticlesIdByTag:(NSString *)tag;
- (NSArray *)getArticlesIdByTitle:(NSString *)title;
- (NSArray *)getAllLocalFavourite;

@end
