//
//  PageGroupInfo.m
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "PageGroupInfo.h"

@implementation PageGroupInfo

- (id)init
{
    self = [super init];
    if (self) {
        self.pageInfos = [@[] mutableCopy];
    }
    
    return self;
}

@end
