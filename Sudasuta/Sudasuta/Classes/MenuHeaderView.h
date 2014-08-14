//
//  MenuHeaderView.h
//  Sudasuta
//
//  Created by user on 14-3-20.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuHeaderView;

@protocol MenuHeaderDelegate <NSObject>

- (void)didSelectMenuHeaderView:(MenuHeaderView *)menuHeaderView;

@end

@interface MenuHeaderView : UIView

@property (strong, nonatomic) UIImage  *headerImage;
@property (strong, nonatomic) NSString *headerTitle;
@property (weak, nonatomic) id<MenuHeaderDelegate> delegate;

- (void)setSelectedEnabled:(BOOL)isEnabled;

@end

