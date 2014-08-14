//
//  ResourceManager.m
//  Sudasuta
//
//  Created by user on 14-4-2.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ResourceManager.h"

@implementation ResourceManager

+ (ResourceManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}

- (void)copyDatabaseFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destImageDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_FULL_NAME];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:destImageDBPath]) {
        NSString *imageDBPath =[[NSBundle mainBundle] pathForResource:DATABASE_FILE_NAME ofType:DATABASE_FILE_SUFFIX];
        [[NSFileManager defaultManager] copyItemAtPath:imageDBPath toPath:destImageDBPath error:nil];
    } else {
        NSLog(@"File is existed!");
    }
}

- (BOOL)isDatabaseFileExisted
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destImageDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_FULL_NAME];
    
    return [[NSFileManager defaultManager] fileExistsAtPath:destImageDBPath];
}

@end
