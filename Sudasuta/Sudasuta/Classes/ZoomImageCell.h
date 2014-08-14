//
//  ZoomImageCell.h
//  Sudasuta
//
//  Created by user on 14-6-19.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZoomImageDelegate <NSObject>

- (void)zoomViewZooming;
- (void)zoomViewDidEndZooming;

@end

@interface ZoomImageCell : UICollectionViewCell <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *zoomView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) id<ZoomImageDelegate> zoomDelegate;

@end
