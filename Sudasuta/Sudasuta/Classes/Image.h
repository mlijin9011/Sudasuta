//
//  Image.h
//  Sudasuta
//
//  Created by user on 14-3-24.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageGroup.h"

@interface Image : NSObject

#pragma mark - Network properties

@property (nonatomic) NSInteger imageId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *url;

#pragma mark - Local property

@property (weak, nonatomic)   ImageGroup *parentGroup;
@property (nonatomic) BOOL isFavorite;

@end
