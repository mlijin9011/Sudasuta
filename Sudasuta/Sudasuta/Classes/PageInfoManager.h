//
//  PageInfoManager.h
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageInfoManager : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *pageInfoGroups;

+ (PageInfoManager *)sharedInstance;

- (NSArray *)loadPageInfoGroups;

@end
