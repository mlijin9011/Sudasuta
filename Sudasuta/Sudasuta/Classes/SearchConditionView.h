//
//  SearchConditionView.h
//  Sudasuta
//
//  Created by user on 14-7-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchConditionDelegate <NSObject>

- (void)didSelectSearchConditonAtRow:(NSInteger)row withSubpage:(BOOL)hasSubpage;

@end

@interface SearchConditionView : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *conditions;
@property (weak, nonatomic) id<SearchConditionDelegate> selectDelegate;
@property (nonatomic) BOOL isHasSubpage;

- (void)reloadData;

@end
