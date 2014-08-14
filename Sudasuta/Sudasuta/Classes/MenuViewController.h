//
//  MenuViewController.h
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuHeaderView.h"
#import "PageInfo.h"

typedef enum {
    MenuSection_Theme = 0,
    MenuSection_Favorite,
    MenuSection_Search,
    MenuSection_Setting
}MenuSection;

@protocol MenuViewDelegate <NSObject>

- (void)didSelectMenuHeader:(NSInteger)section;
- (void)didSelectMenuCell:(NSInteger)row withPageInfo:(PageInfo *)pageInfo;

@end

@interface MenuViewController : UITableViewController <MenuHeaderDelegate>

@end

