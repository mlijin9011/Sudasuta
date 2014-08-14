//
//  ImageGroupCache.h
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageGroupCache : NSObject

@property (strong, nonatomic) NSArray        *cachedIds;
@property (strong, nonatomic) NSMutableArray *currentGroups;
@property (nonatomic)         NSRange        currentRange;

- (NSArray *)getCurrentRangeIds;
- (NSArray *)getRange:(BOOL)isOld inStep:(NSInteger)step;

@end
