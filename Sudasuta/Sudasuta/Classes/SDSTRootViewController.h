//
//  SDSTViewController.h
//  Sudasuta
//
//  Created by user on 14-3-14.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface SDSTRootViewController : UINavigationController <UINavigationControllerDelegate, MenuViewDelegate>

@property (strong, nonatomic) UIViewController *menuController;

+ (SDSTRootViewController *)sharedInstance;

- (void)menuButtonTapped;

- (void)setMenuEnabled:(BOOL)isEnabled;

@end
