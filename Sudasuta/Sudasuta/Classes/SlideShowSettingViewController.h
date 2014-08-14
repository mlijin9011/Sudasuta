//
//  SlideShowSettingViewController.h
//  Sudasuta
//
//  Created by user on 14-7-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SlideOrder) {
    SlideOrderOrdinal = 0,
    SlideOrderRandom
};

@interface SlideShowSettingViewController : UITableViewController

@property (strong, nonatomic, readonly) NSString *selectedType;
@property (strong, nonatomic, readonly) NSString *selectedDirection;
@property (nonatomic, readonly) NSTimeInterval selectedInterval;
@property (nonatomic, readonly) NSUInteger selectedOrder;

@end
