//
//  PageInfo.h
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PageGroupInfo;

@interface PageInfo : NSObject

@property (strong, nonatomic) NSString     *title;
@property (weak, nonatomic) PageGroupInfo  *parentGroup;

@end
