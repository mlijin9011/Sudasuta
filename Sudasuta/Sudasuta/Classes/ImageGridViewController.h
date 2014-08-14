//
//  ImageGridViewController.h
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGridViewController.h"
#import "PageInfo.h"

@interface ImageGridViewController : BaseGridViewController <UICollectionViewDataSource,
                                                             UICollectionViewDelegate,
                                                             UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) PageInfo *pageInfo;

- (void)refreshData;

@end
