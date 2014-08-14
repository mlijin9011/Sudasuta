//
//  ImageGroupCache.m
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageGroupCache.h"
#import "ImageDBOperator.h"
#import "ImageGroup.h"

#define kMoreDataStep   5

@implementation ImageGroupCache

- (id)init
{
    self = [super init];
    if (self) {
        self.cachedIds = [[NSMutableArray alloc] init];
        self.currentGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)setCurrentRange:(NSRange)currentRange
{
    _currentRange = currentRange;
    if (self.cachedIds) {
        NSInteger size = self.cachedIds.count;
        
        NSInteger start = currentRange.location;
        NSInteger end = currentRange.location + currentRange.length;
        
        start = MAX(0, start);
        end = MIN(size, end);
        
        _currentRange.location = start;
        _currentRange.length = end - start;;
    }
}

- (NSArray *)getCurrentRangeIds
{
    NSMutableArray *outIds = [[NSMutableArray alloc] init];
    NSInteger start  = self.currentRange.location;
    NSInteger end    = start + self.currentRange.length;
    
    for (NSInteger ix = start; ix < end; ++ix) {
        [outIds addObject:self.cachedIds[ix]];
    }
    
    return outIds;
}

- (NSArray *)getRange:(BOOL)isOld inStep:(NSInteger)step
{
    NSInteger count = self.cachedIds.count;
    if (0 == count) {
        NSLog(@"Cache Data Invalid!");
        return nil;
    }
    
    NSMutableArray *outIds = [[NSMutableArray alloc] init];
    
    NSInteger newStart  = self.currentRange.location;
    NSInteger newEnd    = newStart + self.currentRange.length;
    
    NSInteger tempStart = newStart;
    NSInteger tempEnd   = newEnd;
    
    if (isOld) {
        newEnd += step;
        newEnd = MIN(newEnd, count);
        
        tempStart = tempEnd;
        tempEnd = newEnd;
    } else {
        newStart -= step;
        newStart = MAX(newStart, 0);
        
        tempEnd = tempStart;
        tempStart = newStart;
    }
    
    for (int ix = tempStart; ix < tempEnd; ++ix) {
        [outIds addObject:self.cachedIds[ix]];
    }
    
    // Reset current range
    _currentRange.location = newStart;
    _currentRange.length   = newEnd - newStart;
    
    return outIds;
}

@end
