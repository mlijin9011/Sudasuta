//
//  SlideShowViewController.m
//  Sudasuta
//
//  Created by user on 14-7-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SlideShowViewController.h"
#import "SlideShowSettingViewController.h"
#import "Image.h"
#import "UIImageView+WebCache.h"

@interface SlideShowViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) SlideShowSettingViewController *slideSettingController;
@property (strong, nonatomic) NSTimer *changeTimer;
@property (nonatomic) NSUInteger currentIndex;
@property (nonatomic) NSUInteger previousIndex;
@property (nonatomic) BOOL       isControlHidden;

@end

@implementation SlideShowViewController

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
    
    if (!self.slideSettingController) {
        self.slideSettingController = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideShowSettingViewController"];
    }
    
    Image *imageData = (Image *)self.slideData[self.currentIndex];
    [self.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                   placeholderImage:nil
                            options:self.currentIndex == 0 ? SDWebImageRefreshCached : 0];
    
    [self slideShowAfterDelay];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopSlide];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)slideSetting:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.slideSettingController];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingDone)];
    self.slideSettingController.navigationItem.rightBarButtonItem = rightItem;
    NSDictionary *navigationTitleAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    navigationController.navigationBar.titleTextAttributes = navigationTitleAttributes;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)settingDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Privates

- (void)slideShowAfterDelay
{
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:self.slideSettingController.selectedInterval
                                                    target:self
                                                  selector:@selector(startSlide)
                                                  userInfo:nil
                                                   repeats:YES];
}

- (void)startSlide
{
	CATransition *transition = [CATransition animation];
	transition.type = self.slideSettingController.selectedType;
	transition.subtype = self.slideSettingController.selectedDirection;
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    [self nextImage];
    [self.imageView.layer addAnimation:transition forKey:@"Transition"];
}

- (void)stopSlide
{
    if (self.changeTimer) {
		[self.changeTimer invalidate];
		self.changeTimer = nil;
	}
}

- (void)nextImage
{
    if (self.slideSettingController.selectedOrder == SlideOrderOrdinal) {
        self.currentIndex++;
        if (self.currentIndex >= [self.slideData count]) {
            self.currentIndex = 0;
        }
    } else if (self.slideSettingController.selectedOrder == SlideOrderRandom) {
        while (self.currentIndex == self.previousIndex || self.currentIndex >= [self.slideData count] - 1) {
            self.currentIndex = arc4random() % [self.slideData count];
        }
    }
    
    Image *imageData = (Image *)self.slideData[self.currentIndex];
    [self.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                   placeholderImage:nil
                            options:self.currentIndex == 0 ? SDWebImageRefreshCached : 0];
    
    self.previousIndex = self.currentIndex;
}

@end
