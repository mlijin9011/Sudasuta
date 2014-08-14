//
//  SDSTViewController.m
//  Sudasuta
//
//  Created by user on 14-3-14.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SDSTRootViewController.h"
#import "ImageGridViewController.h"

static SDSTRootViewController *singleInstance;

@interface SDSTRootViewController ()

@property (nonatomic) BOOL panSwitchMenuEnabled;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIBarButtonItem *menuButton;
@property (nonatomic, assign) CGPoint draggingPoint;
@property (nonatomic) CGFloat slideOffset;
@property (nonatomic) BOOL isMenuOpened;

@end

@implementation SDSTRootViewController

+ (SDSTRootViewController *)sharedInstance
{
    if (!singleInstance) {
        singleInstance = [[SDSTRootViewController alloc] init];
    }
    
	return singleInstance;
}

- (id)init
{
	if (self = [super init]) {
		[self initialize];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self initialize];
	}
	
	return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if (self = [super initWithRootViewController:rootViewController]) {
		[self initialize];
	}
	
	return self;
}

- (void)initialize
{
    singleInstance = self;
    self.panSwitchMenuEnabled = YES;
    self.slideOffset = kMenuSlideOffset;
    self.isMenuOpened = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImage *navigationBarImage = [UIImage imageNamed:@"IMG_NAVIGATIONBAR_BACKGROUND"];
    [self.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    if (self.panSwitchMenuEnabled) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                        initWithTarget:self
                                                        action:@selector(handlePanGesture:)];
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerRotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    // When menu open we disable user interaction
	// When rotates we want to make sure that userInteraction is enabled again
	[self setTapToCloseMenuEnabled:NO];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	// Update rotation animation
	[self updateMenuFrameAndTransform];
}

#pragma mark - MenuHeaderDelegate

- (void)didSelectMenuHeader:(NSInteger)section
{
    [self closeMenuWithCompletion:nil];
    switch (section) {
        case MenuSection_Favorite:
            [self.topViewController performSegueWithIdentifier:@"FavoriteView" sender:nil];
            break;
        case MenuSection_Search:
            [self.topViewController performSegueWithIdentifier:@"SearchView" sender:nil];
            break;
            
        default:
            break;
    }
}

#pragma mark - MenuViewDelegate

- (void)didSelectMenuCell:(NSInteger)row withPageInfo:(PageInfo *)pageInfo
{
    ImageGridViewController *controller = (ImageGridViewController *)self.topViewController;
    controller.pageInfo = pageInfo;
    controller.navigationItem.title = pageInfo.title;
    [controller refreshData];
    [self closeMenuWithCompletion:nil];
}

#pragma mark - Privates

- (void)setMenuEnabled:(BOOL)isEnabled
{
    self.panSwitchMenuEnabled = isEnabled;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if (self.panSwitchMenuEnabled) {
        CGPoint velocity = [sender velocityInView:sender.view];
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (velocity.x > 0) {
                [self openMenuWithDuration:kMenuSlideDuration withCompletion:nil];
            } else {
                [self closeMenuWithDuration:kMenuSlideDuration withCompletion:nil];
            }
        }
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self closeMenuWithCompletion:nil];
}

- (void)setTapToCloseMenuEnabled:(BOOL)enabled
{
    if (enabled) {
        self.topViewController.view.userInteractionEnabled = NO;
        if (!self.tapGestureRecognizer) {
            self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        }
        [self.view addGestureRecognizer:self.tapGestureRecognizer];
    } else {
        self.topViewController.view.userInteractionEnabled = YES;
        [self.view removeGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)openMenuWithCompletion:(void(^)())completion
{
    [self openMenuWithDuration:kMenuSlideDuration withCompletion:completion];
}

- (void)closeMenuWithCompletion:(void(^)())completion
{
    [self closeMenuWithDuration:kMenuSlideDuration withCompletion:completion];
}

- (void)openMenuWithDuration:(float)duration withCompletion:(void(^)())completion
{
    [self setTapToCloseMenuEnabled:YES];
    [self prepareMenuForced:NO];
    
    [UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect = self.view.frame;
						 rect.origin.x = self.slideOffset;
						 [self moveToLocation:rect.origin.x];
					 }
					 completion:^(BOOL finished) {
                         if (finished) {
                             self.isMenuOpened = YES;
                             if (completion) {
                                 completion();
                             }
                         }
					 }];
}

- (void)closeMenuWithDuration:(float)duration withCompletion:(void(^)())completion
{
    [self setTapToCloseMenuEnabled:NO];
    
    [UIView animateWithDuration:duration
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 CGRect rect = self.view.frame;
						 rect.origin.x = 0;
						 [self moveToLocation:rect.origin.x];
					 }
					 completion:^(BOOL finished) {
                         if (finished) {
                             self.isMenuOpened = NO;
                             if (completion) {
                                 completion();
                             }
                         }
					 }];
}

- (void)prepareMenuForced:(BOOL)forcePrepare
{
    if (self.isMenuOpened && !forcePrepare) {
        return;
    }
    
    [self.view.window insertSubview:self.menuController.view atIndex:0];
    [self updateMenuFrameAndTransform];
}

- (void)updateMenuFrameAndTransform
{
    // Animate rotatation when menu is open and device rotates
	CGAffineTransform transform = self.view.transform;
	self.menuController.view.transform = transform;
	self.menuController.view.frame = [self initialFrameForMenu];
}

- (CGRect)initialFrameForMenu
{
	CGRect rect = self.view.frame;
	rect.origin.x = 0;
	rect.origin.y = 0;
	
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            // For some reasons in landscape belos the status bar is considered y=0, but in portrait it's considered y=20
			rect.origin.x = (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) ? 0 : kStatusBarHeight;
			rect.size.width = self.view.frame.size.width - kStatusBarHeight;
        } else {
            // For some reasons in landscape belos the status bar is considered y=0, but in portrait it's considered y=20
			rect.origin.y = (self.interfaceOrientation == UIInterfaceOrientationPortrait) ? kStatusBarHeight : 0;
			rect.size.height = self.view.frame.size.height - kStatusBarHeight;
        }
    }
	
	return rect;
}

- (void)moveToLocation:(CGFloat)location
{
    CGRect rect = self.view.frame;
	
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		rect.origin.x = 0;
		rect.origin.y = (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) ? location : -location;
	} else {
		rect.origin.x = (self.interfaceOrientation == UIInterfaceOrientationPortrait) ? location : -location;
		rect.origin.y = 0;
	}
	
	self.view.frame = rect;
}

- (void)menuButtonTapped
{
	if (self.isMenuOpened) {
        [self closeMenuWithCompletion:nil];
    } else {
        [self openMenuWithCompletion:nil];
    }
}

@end
