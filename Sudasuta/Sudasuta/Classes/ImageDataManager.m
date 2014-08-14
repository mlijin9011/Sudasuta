//
//  ImageDataManager.m
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageDataManager.h"
#import "ImageGroupCache.h"
#import "PageGroupInfo.h"
#import "PageInfoManager.h"
#import "PageInfo.h"
#import "ImageGroup.h"
#import "ImageDBOperator.h"

@interface ImageDataManager ()
{
    NSObject *lock;
}

// The image list
@property (nonatomic, strong, readwrite) NSMutableArray *imageList;
@property (nonatomic, strong, readwrite) NSMutableArray *imageGroups;

@property (nonatomic, strong) NSMutableDictionary *loadedGroupsCache;

@property (nonatomic) NSRange currentRange;

@end

@implementation ImageDataManager

+ (ImageDataManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        lock = [[NSObject alloc] init];
        self.imageList = [@[] mutableCopy];
        self.imageGroupsCache = [[NSMutableDictionary alloc] init];
        self.loadedGroupsCache = [[NSMutableDictionary alloc] init];
        
        NSArray *pageInfoGroups = [[PageInfoManager sharedInstance] loadPageInfoGroups];
        PageGroupInfo *group = ((PageGroupInfo *)pageInfoGroups[0]);
        
        for (PageInfo *page in group.pageInfos) {
            [self.imageGroupsCache setObject:[[ImageGroupCache alloc] init] forKey:page.title];
        }
    }
    
    return self;
}

- (NSArray *)getImageGroupsByCategory:(NSString *)category
{
    ImageGroupCache *cacheItem = self.imageGroupsCache[category];
    if (cacheItem) {
        return cacheItem.currentGroups;
    }
    
    return nil;
}

- (void)loadImageGroupsByCategory:(NSString *)category withCompletion:(LoadCompleteBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(lock)
        {
            NSLog(@"loadImageGroupsByCategory:%@", category);
            NSArray *groups = nil;
            NSMutableArray *loadedGroups = [[NSMutableArray alloc] init];
            
            // Get the cache object from dictionary.
            ImageGroupCache *cache = self.imageGroupsCache[category];
            if (cache) {
                
                // Load the cached ids first.
                if (0 == cache.cachedIds.count) {
                    NSString *withCategory = category;
                    
                    // Make the specified category [All] can search all data.
                    if (!category || [category isEqualToString:NSLocalizedString(@"image_category_all", @"")]) {
                        withCategory = nil;
                    }
                    
                    // Load all group ids by category.
                    cache.cachedIds = [[ImageDBOperator sharedInstance] getAllGroupIds:withCategory];
                }
                
                // Set default range.
                NSNumber *start = [[NSUserDefaults standardUserDefaults] objectForKey:category];
                NSUInteger startIndex = cache.cachedIds.count * 1 / 5;
                if (nil != start) {
                    startIndex = start.integerValue;
                }
                NSRange defaultRange = { startIndex, 24 };
                cache.currentRange = defaultRange;
                
                NSMutableArray *rangeIds = [[NSMutableArray alloc] initWithArray:[cache getCurrentRangeIds]];
                NSMutableArray *removedIds = [[NSMutableArray alloc] init];
                NSUInteger count = rangeIds.count;
                for (int i = 0; i < count; i++) {
                    NSInteger rangeId = [rangeIds[i] integerValue];
                    ImageGroup *group = [_loadedGroupsCache objectForKey:[NSNumber numberWithInt:rangeId]];
                    if (group) {
                        NSLog(@"loadImageGroupsByCategory: group:%d is existed in loaded groups cache", group.groupId);
                        [removedIds addObject:rangeIds[i]];
                        [loadedGroups addObject:group];
                    }
                }
                [rangeIds removeObjectsInArray:removedIds];
                
                groups = [[ImageDBOperator sharedInstance] getGroupsWith:rangeIds];
                for (ImageGroup *group in groups) {
                    [[ImageDBOperator sharedInstance] fillImage:group];
                    [self.loadedGroupsCache setObject:group forKey:[NSNumber numberWithInt:group.groupId]];
                    [loadedGroups addObject:group];
                }
                
                // Sort array in loaded groups.
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_groupId" ascending:YES];
                [loadedGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                // Insert the new item in the header of the Array
                // NOTE: it seems inefficiency
                for (int ix = loadedGroups.count - 1; ix >=0; --ix) {
                    [cache.currentGroups insertObject:loadedGroups[ix] atIndex:0];
                }
            }
            
            if (completion) {
                completion(loadedGroups, nil);
            }
        }
    });
}

- (void)loadMoreImageGroupsAsync:(NSString *)withCategory
                       withCount:(int)requestCount
                     loadOldData:(BOOL)isOld
                       completed:(LoadCompleteBlock)completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(lock)
        {
            NSLog(@"loadMoreImageGroupsAsync:withCategory:%@, requestCount: %d, isOld = %d", withCategory, requestCount, isOld);
            
            NSArray *groups = nil;
            NSMutableArray *loadedGroups = [[NSMutableArray alloc] init];
            
            // Get the cache object from dictionary.
            ImageGroupCache *cache = _imageGroupsCache[withCategory];
            if (cache) {
                
                // Load the cached ids first.
                if (0 == cache.cachedIds.count) {
                    NSLog(@"Have you loadImageGroupsByCategory for first???");
                    completionBlock(groups, nil);
                    
                    return;
                }
                
                // Load the initialized cache data
                NSMutableArray *rangeIds = [[NSMutableArray alloc] initWithArray:[cache getRange:isOld inStep:requestCount]];
                NSMutableArray *removedIds = [[NSMutableArray alloc] init];
                NSUInteger count = rangeIds.count;
                for (int i = 0; i < count; i++) {
                    int rangeId = [rangeIds[i] intValue];
                    ImageGroup *group = [_loadedGroupsCache objectForKey:[NSNumber numberWithInt:rangeId]];
                    if (group) {
                        NSLog(@"loadMoreImageGroupsAsync: group:%d is existed in loaded groups cache", group.groupId);
                        [removedIds addObject:rangeIds[i]];
                        [loadedGroups addObject:group];
                    }
                }
                [rangeIds removeObjectsInArray:removedIds];
                
                groups = [[ImageDBOperator sharedInstance] getGroupsWith:rangeIds];
                for (ImageGroup *group in groups) {
                    [[ImageDBOperator sharedInstance] fillImage:group];
                    [self.loadedGroupsCache setObject:group forKey:[NSNumber numberWithInt:group.groupId]];
                    [loadedGroups addObject:group];
                }
                
                // Sort array in loaded groups.
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"_groupId" ascending:YES];
                [loadedGroups sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                
                // Insert the new item in the header of the Array
                // NOTE: it seems inefficiency
                if (isOld) {
                    [cache.currentGroups addObjectsFromArray:loadedGroups];
                } else {
                    for (int ix = loadedGroups.count - 1; ix >=0; --ix) {
                        [cache.currentGroups insertObject:loadedGroups[ix] atIndex:0];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:cache.currentRange.location]
                                                              forKey:withCategory];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            
            if (completionBlock) {
                completionBlock(loadedGroups, nil);
            }
        }
    });
}

@end
