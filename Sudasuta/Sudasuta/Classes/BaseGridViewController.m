//
//  BaseGridViewController.m
//  Sudasuta
//
//  Created by user on 14-5-13.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "BaseGridViewController.h"

@interface BaseGridViewController ()

@end

@implementation BaseGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientationDidChanged:(NSNotification *)notification
{
    [self initLayout];
}

- (void)initLayout
{
    // Get the user selected UILayout.
    self.columnCount = [self calcuateColumnCount];
    self.cellSize = [self calcuateCellSize:self.columnCount];
}

- (NSInteger)calcuateColumnCount
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    return isPortrait ? kColumnCount_Portrait : kColumnCount_Landscape;
}

- (CGSize)calcuateCellSize:(NSInteger)columnCount
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    
    // The width is not correct if current orientation is Landscape,
    // so we use screen width to calcuate the cell width.
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat frameWidth = isPortrait ? screenSize.width : screenSize.height;
    CGFloat cellWidth= frameWidth / columnCount;
    
    return CGSizeMake(cellWidth, cellWidth);
}

@end
