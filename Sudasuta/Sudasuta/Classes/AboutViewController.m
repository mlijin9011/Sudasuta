//
//  AboutViewController.m
//  Sudasuta
//
//  Created by user on 14-3-25.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)officialWebsite:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:kSudasutaHomeUrl];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)sinaWeibo:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:kSudasutaWeiboUrl];
    [[UIApplication sharedApplication] openURL:url];
}

@end
