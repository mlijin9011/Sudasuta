//
//  ResourceManager.h
//  Sudasuta
//
//  Created by user on 14-4-2.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceManager : NSObject

+ (ResourceManager *)sharedInstance;

- (void)copyDatabaseFile;
- (BOOL)isDatabaseFileExisted;

@end
