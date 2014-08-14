//
//  PageGroupInfo.h
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageInfo;

@interface PageGroupInfo : NSObject

@property (strong, nonatomic) NSString       *title;
@property (strong, nonatomic) NSMutableArray *pageInfos;

@end
