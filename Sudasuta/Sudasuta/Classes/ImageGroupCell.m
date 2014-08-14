//
//  ImageGridCell.m
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageGroupCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "ImageGroup.h"

@interface ImageGroupCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView      *detailView;
@property (weak, nonatomic) IBOutlet UILabel     *detailTitle;
@property (weak, nonatomic) IBOutlet UILabel     *detailDescription;
@property (weak, nonatomic) IBOutlet UIView      *lineView;
@property (weak, nonatomic) IBOutlet UILabel     *detailTime;

@end

@implementation ImageGroupCell

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
    self.layer.borderColor = [UIColor blackColor].CGColor;
    self.layer.borderWidth = 1;
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    [self refreshLayout];
}

- (void)refreshLayout
{
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 100);
    self.detailView.frame = CGRectMake(0, self.bounds.size.height - 100, self.bounds.size.width, 100);
    [self.detailView layoutSubviews];
    self.detailTitle.frame = CGRectMake(8, 5, self.detailView.frame.size.width - 16, 18);
    self.detailDescription.frame = CGRectMake(8, 25, self.detailView.frame.size.width - 16, 36);
    self.lineView.frame = CGRectMake(10, 70, self.detailView.frame.size.width - 20, 1);
    self.detailTime.frame = CGRectMake(8, 78, self.detailView.frame.size.width - 16, 18);
}

- (void)setImageGroup:(ImageGroup *)imageGroup
{
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.fadeIn = YES;
    [self.imageView setImageWithURL:[NSURL URLWithString:imageGroup.coverUrl]
                   placeholderImage:nil
                            options:0];
    
    self.detailTitle.text = imageGroup.title;
    self.detailDescription.text = imageGroup.description;
    self.detailTime.text = imageGroup.time;
    
    self.selected = NO;
}

@end
