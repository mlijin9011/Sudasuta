//
//  BaseGridViewController.h
//  Sudasuta
//
//  Created by user on 14-5-13.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseGridViewController : UIViewController

@property (nonatomic) NSInteger columnCount;
@property (nonatomic) CGSize cellSize;

- (void)orientationDidChanged:(NSNotification *)notification;
- (void)initLayout;
- (NSInteger)calcuateColumnCount;
- (CGSize)calcuateCellSize:(NSInteger)columnCount;

@end
