//
//  ImageDetailViewController.h
//  Sudasuta
//
//  Created by user on 14-4-2.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageGroup.h"
#import "ZoomImageCell.h"

@interface ImageDetailViewController : UIViewController <UICollectionViewDataSource,
                                                         UICollectionViewDelegate,
                                                         UICollectionViewDelegateFlowLayout,
                                                         UIScrollViewDelegate,
                                                         UIAlertViewDelegate,
                                                         ZoomImageDelegate>

@property (strong, nonatomic) ImageGroup *currentGroup;
@property (strong, nonatomic) NSArray    *images;

@property (nonatomic) BOOL isGroup;

@end
