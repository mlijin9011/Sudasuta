//
//  SearchViewController.h
//  Sudasuta
//
//  Created by user on 14-7-16.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "BaseGridViewController.h"
#import "SearchConditionView.h"

@interface SearchViewController : BaseGridViewController <UICollectionViewDataSource,
                                                          UICollectionViewDelegate,
                                                          UICollectionViewDelegateFlowLayout,
                                                          UISearchBarDelegate,
                                                          SearchConditionDelegate>

@end
