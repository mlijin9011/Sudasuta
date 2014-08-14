//
//  SDSTMenuViewController.m
//  Sudasuta
//
//  Created by user on 14-3-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SDSTMenuViewController.h"

@interface SDSTMenuViewController ()

@end

@implementation SDSTMenuViewController

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
    
    UIImage *navigationBarImage = [UIImage imageNamed:@"IMG_NAVIGATIONBAR_BACKGROUND"];
    [self.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
