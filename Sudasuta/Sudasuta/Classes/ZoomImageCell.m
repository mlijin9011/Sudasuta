//
//  ZoomImageCell.m
//  Sudasuta
//
//  Created by user on 14-6-19.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ZoomImageCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ZoomImageCell

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
        self.zoomView.scrollEnabled = YES;
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if (scale > 1) {
        if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(zoomViewZooming)]) {
            [self.zoomDelegate zoomViewZooming];
        }
    } else {
        if (self.zoomDelegate && [self.zoomDelegate respondsToSelector:@selector(zoomViewDidEndZooming)]) {
            [self.zoomDelegate zoomViewDidEndZooming];
        }
    }
}

@end
