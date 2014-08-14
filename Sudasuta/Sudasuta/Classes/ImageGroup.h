//
//  ImageGroup.h
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageGroup : NSObject

@property (nonatomic) NSInteger groupId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *coverUrl;
@property (strong, nonatomic) NSString *categories;
@property (strong, nonatomic) NSString *tags;
@property (strong, nonatomic) NSString *homePageUrl;

@property (strong, nonatomic) NSArray  *images;

@end
