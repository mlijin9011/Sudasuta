//
//  FeedbackViewController.m
//  Sudasuta
//
//  Created by user on 14-3-25.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "FeedbackViewController.h"
#import "UMFeedback.h"

@interface FeedbackViewController ()

@property (strong, nonatomic) UMFeedback *feedBackClient;

@end

@implementation FeedbackViewController

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
    self.feedBackClient = [UMFeedback sharedInstance];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
