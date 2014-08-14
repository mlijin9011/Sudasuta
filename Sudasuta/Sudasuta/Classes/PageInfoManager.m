//
//  PageInfoManager.m
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "PageInfo.h"

@interface PageInfoManager ()

@property (strong, nonatomic, readwrite) NSMutableArray *pageInfoGroups;

@end

@implementation PageInfoManager

+ (PageInfoManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (NSArray *)loadPageInfoGroups
{
    if (self.pageInfoGroups) {
        return self.pageInfoGroups;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"PageGroups" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSArray *pages = [data objectForKey:@"default_page"];
    
    NSMutableArray *groups = [@[] mutableCopy];
    
    PageGroupInfo *group = nil;
    PageInfo *page = nil;
    NSArray *items = nil;
    for (NSDictionary *dict in pages) {
        group = [[PageGroupInfo alloc] init];
        group.title = (NSString *)dict.allKeys[0];
        group.pageInfos = [@[] mutableCopy];
        items = dict[group.title];
        
        for (NSString *item in items) {
            page = [[PageInfo alloc] init];
            page.title = item;
            [group.pageInfos addObject:page];
        }
        
        [groups addObject:group];
    }
    
    self.pageInfoGroups = groups;
    
    return self.pageInfoGroups;
}

@end
