//
//  ImageGridCell.m
//  Sudasuta
//
//  Created by user on 14-7-15.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageGridCell.h"

@interface ImageGridCell ()

@end

@implementation ImageGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    self.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    [self setBorderColorInternal:[UIColor blackColor] withWidth:1];
}

- (void)setBorderColorInternal:(UIColor *)color withWidth:(CGFloat)width
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.clipsToBounds = YES;
}

@end
