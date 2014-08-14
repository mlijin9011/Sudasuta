//
//  MenuHeaderView.m
//  Sudasuta
//
//  Created by user on 14-3-20.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "MenuHeaderView.h"

@interface MenuHeaderView ()

@property (strong, nonatomic) UIButton    *backgroundView;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UILabel     *headerTitleView;

@end

@implementation MenuHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundView = [[UIButton alloc] initWithFrame:self.bounds];
    UIImage *backgroundHighlighted = [UIImage imageNamed:@"IMG_MENU_HEADER_BACKGROUND_N"];
    UIImage *backgroundNormal = [UIImage imageNamed:@"IMG_MENU_HEADER_BACKGROUND_P"];
    [self.backgroundView setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
    [self.backgroundView setBackgroundImage:backgroundHighlighted forState:UIControlStateHighlighted];
    [self.backgroundView setBackgroundImage:backgroundHighlighted forState:UIControlStateSelected];
    [self.backgroundView addTarget:self action:@selector(selectHeader:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backgroundView];
    
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 9, 26, 26)];
    self.headerImageView.contentMode = UIViewContentModeCenter;
    [self.backgroundView addSubview:self.headerImageView];
    
    self.headerTitleView = [[UILabel alloc] initWithFrame:CGRectMake(90, 9, 100, 26)];
    self.headerTitleView.textColor = [UIColor whiteColor];
    [self.backgroundView addSubview:self.headerTitleView];
}

- (void)setHeaderImage:(UIImage *)headerImage
{
    self.headerImageView.image = headerImage;
}

- (void)setHeaderTitle:(NSString *)headerTitle
{
    self.headerTitleView.text = headerTitle;
}

- (void)setSelectedEnabled:(BOOL)isEnabled
{
    self.backgroundView.userInteractionEnabled = isEnabled;
}

- (IBAction)selectHeader:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMenuHeaderView:)]) {
        [self.delegate didSelectMenuHeaderView:self];
    }
}

@end
