//
//  FavoriteViewController.h
//  Sudasuta
//
//  Created by user on 14-3-25.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGridViewController.h"

@interface FavoriteViewController : BaseGridViewController <UICollectionViewDataSource,
                                                            UICollectionViewDelegate,
                                                            UICollectionViewDelegateFlowLayout>

@end
