//
//  ImageDataManager.h
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

// Define the callback when load images completed.
typedef void(^LoadCompleteBlock)(NSArray *resultImageList, NSError *error);

@interface ImageDataManager : NSObject

@property (strong, nonatomic, readonly) NSArray   *imageGroups;
@property (strong, nonatomic) NSMutableDictionary *imageGroupsCache;

+ (ImageDataManager *)sharedInstance;

- (NSArray *)getImageGroupsByCategory:(NSString *)category;
- (void)loadImageGroupsByCategory:(NSString *)category withCompletion:(LoadCompleteBlock)completion;
- (void)loadMoreImageGroupsAsync:(NSString *)withCategory withCount:(int)requestCount loadOldData:(BOOL)isOld completed:(LoadCompleteBlock)completionBlock;

@end
