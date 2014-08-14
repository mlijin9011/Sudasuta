//
//  ImageDetailViewController.m
//  Sudasuta
//
//  Created by user on 14-4-2.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageDetailViewController.h"
#import "image.h"
#import "UIImageView+WebCache.h"
#import "ImageDBOperator.h"
#import "UIImage+SDSTExtension.h"

@interface ImageDetailViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIScrollView     *groupDescriptionView;
@property (weak, nonatomic) IBOutlet UILabel          *groupTitle;
@property (weak, nonatomic) IBOutlet UIView           *groupSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView      *groupTimeImage;
@property (weak, nonatomic) IBOutlet UILabel          *groupTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView      *groupCategoryImage;
@property (weak, nonatomic) IBOutlet UILabel          *groupCategoryLabel;
@property (weak, nonatomic) IBOutlet UIImageView      *groupTagImage;
@property (weak, nonatomic) IBOutlet UILabel          *groupTagLabel;
@property (weak, nonatomic) IBOutlet UILabel          *groupDescriptionContent;
@property (weak, nonatomic) IBOutlet UIView           *buttonView;
@property (weak, nonatomic) IBOutlet UIButton         *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton         *rotateButton;
@property (weak, nonatomic) IBOutlet UIButton         *downloadButton;
@property (weak, nonatomic) IBOutlet UIButton         *shareButton;

@property (strong, nonatomic) NSIndexPath             *currentIndexPath;
@property (strong, nonatomic) NSTimer                 *controlHideTimer;

@property (nonatomic) BOOL                            isControlHidden;
@property (nonatomic) NSInteger                       currentImageIndex;
@property (nonatomic) UIImageOrientation              currentImageOrientation;

@end

@implementation ImageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.images = [@[] mutableCopy];
        self.isControlHidden = NO;
        self.currentImageIndex = 0;
        self.currentImageOrientation = UIImageOrientationUp;
        self.isGroup = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initGestureRecognizer];
    
    if (self.isGroup) {
        self.images = self.currentGroup.images;
        self.groupDescriptionView.hidden = NO;
        [self setGroupDescription:self.currentGroup];
    } else {
        self.groupDescriptionView.hidden = YES;
    }
    [self updateControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isGroup) {
        [self setDescriptionViewFrame];
        [self resizeDescriptionView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Rotation

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UICollectionViewFlowLayout *imageCollectionViewOldLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *imageCollectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    imageCollectionViewLayout.minimumInteritemSpacing  = imageCollectionViewOldLayout.minimumInteritemSpacing;
    imageCollectionViewLayout.minimumLineSpacing       = imageCollectionViewOldLayout.minimumLineSpacing;
    imageCollectionViewLayout.sectionInset             = imageCollectionViewOldLayout.sectionInset;
    imageCollectionViewLayout.scrollDirection          = imageCollectionViewOldLayout.scrollDirection;
    [self.collectionView setCollectionViewLayout:imageCollectionViewLayout animated:NO];
    
    if (self.isGroup) {
        [self resizeDescriptionView];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentIndexPath = indexPath;
    Image *imageData = self.images[indexPath.row];
    ZoomImageCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZoomGridCell" forIndexPath:indexPath];
    
    if (imageCell) {
        imageCell.zoomDelegate = self;
        __weak ZoomImageCell *cell = imageCell;
        [cell.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                       placeholderImage:nil
                                options:SDWebImageProgressiveDownload
                               progress:^(NSUInteger receivedSize, long long expectedSize) {
                                   cell.indicator.center = cell.imageView.center;
                                   [cell.indicator startAnimating];
                               }
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [cell.indicator stopAnimating];
                              }];
        
        imageCell.imageView.image = [imageCell.imageView.image fixOrientation:self.currentImageOrientation];
    }
    
    return imageCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.currentImageOrientation = UIImageOrientationUp;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visiableIndexs = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *indexPath = [visiableIndexs objectAtIndex:0];
    self.currentImageIndex = indexPath.row;
    [self updateControls];
    [self hideControlsAfterDelay];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex + 1) {
        Image *image = self.images[self.currentImageIndex];
        [self addOrDeleteFavorite:image];
    }
}

#pragma mark - ZoomImageDelegate

- (void)zoomViewZooming
{
    self.collectionView.scrollEnabled = NO;
}

- (void)zoomViewDidEndZooming
{
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - Private Method

- (void)initGestureRecognizer
{
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(toggleControls)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.cancelsTouchesInView = NO;
    [self.collectionView addGestureRecognizer:singleTapRecognizer];
}

- (void)toggleControls
{
    [self setControlsHidden:!self.isControlHidden animated:YES permanent:NO];
}

- (void)hideControls
{
    [self setControlsHidden:YES animated:YES permanent:NO];
}

- (void)updateControls
{
    if (self.isGroup) {
        self.navigationItem.title = [NSString stringWithFormat:@"%d/%d", self.currentImageIndex + 1, self.images.count];
    }
    Image *imageData = self.images[self.currentImageIndex];
    [self setFavoriteStatus:imageData.isFavorite];
}

- (void)hideControlsAfterDelay
{
	if (!self.isControlHidden) {
        [self cancelHidingTimer];
        if (!self.controlHideTimer) {
            self.controlHideTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                     target:self
                                                                   selector:@selector(hideControls)
                                                                   userInfo:nil
                                                                    repeats:NO];
        }
	}
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated permanent:(BOOL)permanent
{
    [self cancelHidingTimer];
	self.isControlHidden = hidden;
	
	// Animate
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
    }
    
    self.groupDescriptionView.alpha = hidden ? 0 : 1;
    self.buttonView.alpha = hidden ? 0 : 1;
    
	if (animated) {
        [UIView commitAnimations];
    }
    
	if (!permanent && !hidden) {
        [self hideControlsAfterDelay];
    }
}

- (void)setFavoriteStatus:(BOOL)isFavorite
{
    NSString *imageName;
    imageName = isFavorite ? @"BTN_FAVORITE_HEART" : @"BTN_FAVORITE";
    
    if (self.favoriteButton) {
        [self.favoriteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

- (void)cancelHidingTimer
{
	if (self.controlHideTimer) {
		[self.controlHideTimer invalidate];
		self.controlHideTimer = nil;
	}
}

- (void)setDescriptionViewFrame
{
    CGFloat viewHeight = 100;
    CGFloat subViewHeight = 20;
    CGFloat horizontalEdge = 20;
    CGFloat verticalEdge = 5;
    CGFloat space = 1;
    self.groupDescriptionView.frame = CGRectMake(0,
                                                self.view.bounds.size.height - viewHeight,
                                                self.view.bounds.size.width,
                                                viewHeight);
    self.groupTitle.frame = CGRectMake(horizontalEdge,
                                       verticalEdge,
                                       self.view.bounds.size.width - horizontalEdge * 2,
                                       subViewHeight);
    self.groupSubtitle.frame = CGRectMake(horizontalEdge,
                                          verticalEdge + subViewHeight + space,
                                          self.view.bounds.size.width - horizontalEdge * 2 - 10,
                                          subViewHeight);
    self.groupTimeImage.frame = CGRectMake(0, 4, 15, 15);
    self.groupTimeLabel.frame = CGRectMake(15, 0, 75, subViewHeight);
    self.groupCategoryImage.frame = CGRectMake(90, 4, 15, 15);
    self.groupCategoryLabel.frame = CGRectMake(105, 0, 80, subViewHeight);
    self.groupTagImage.frame = CGRectMake(185, 4, 15, 15);
    self.groupTagLabel.frame = CGRectMake(200, 0, self.view.bounds.size.width -horizontalEdge - 200, subViewHeight);
    
    self.groupDescriptionContent.frame = CGRectMake(horizontalEdge,
                                                    verticalEdge + subViewHeight * 2 + space * 2,
                                                    self.view.bounds.size.width - horizontalEdge * 2,
                                                    subViewHeight);
}

- (void)resizeDescriptionView
{
    NSDictionary *subtitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:self.groupCategoryLabel.font, NSFontAttributeName, nil];
    CGSize categorySize = [self.groupCategoryLabel.text boundingRectWithSize:CGSizeMake(500, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:subtitleAttributes context:nil].size;
    CGRect categoryFrame = self.groupCategoryLabel.frame;
    categoryFrame.size.width = categorySize.width;
    self.groupCategoryLabel.frame = categoryFrame;
    
    CGFloat tagOriginX = self.groupCategoryLabel.frame.origin.x + self.groupCategoryLabel.frame.size.width + 20;
    self.groupTagImage.frame = CGRectMake(tagOriginX, 3, 14, 14);
    self.groupTagLabel.frame = CGRectMake(tagOriginX + 15, 0, self.view.bounds.size.width - 20 - tagOriginX - 15, 20);
    
    
    NSDictionary *contentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:self.groupDescriptionContent.font, NSFontAttributeName, nil];
    CGSize descriptionSize = [self.groupDescriptionContent.text boundingRectWithSize:CGSizeMake(self.groupDescriptionContent.frame.size.width, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:contentAttributes context:nil].size;
    CGRect descriptionFrame = self.groupDescriptionContent.frame;
    descriptionFrame.size.height = descriptionSize.height;
    self.groupDescriptionContent.frame = descriptionFrame;
}

- (void)setGroupDescription:(ImageGroup *)group
{
    self.groupTitle.text = group.title;
    self.groupTimeLabel.text = group.time;
    self.groupCategoryLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"group_description_category", @""), group.categories];
    self.groupTagLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"group_description_tag", @""), group.tags];
    self.groupDescriptionContent.text = group.description;
}

- (IBAction)addToFavorite:(id)sender
{
    [self cancelHidingTimer];
    Image *image = self.images[self.currentImageIndex];
    
    if (image.isFavorite) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_cancel_favorite", @"")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
        [alert show];
    } else {        
        [self addOrDeleteFavorite:image];
    }
}

- (void)addOrDeleteFavorite:(Image *)image
{
    if ([[ImageDBOperator sharedInstance] updateFavoriteImage:image]) {
        image.isFavorite = !image.isFavorite;
    }
    
    [self setFavoriteStatus:image.isFavorite];
    [self hideControlsAfterDelay];
}

- (IBAction)rotateImage:(id)sender
{
    [self cancelHidingTimer];
    ZoomImageCell *currentCell = (ZoomImageCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    
    CATransition *transition = [CATransition animation];
	transition.type = @"rotate";
	transition.subtype = @"90cw";
    transition.duration = 0.15;
    [currentCell.imageView.layer addAnimation:transition forKey:@"Transition"];
    currentCell.imageView.image = [currentCell.imageView.image imageRotatedByDegrees:-90];
    
    self.currentImageOrientation = [currentCell.imageView.image
                                    rotateImageOrientation:self.currentImageOrientation
                                    isClockWise:NO];
    [self hideControlsAfterDelay];
}

- (IBAction)downloadImage:(id)sender
{
    [self cancelHidingTimer];
    ZoomImageCell *currentCell = (ZoomImageCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    UIImageWriteToSavedPhotosAlbum(currentCell.imageView.image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   nil);
    
    [self hideControlsAfterDelay];
}

- (IBAction)shareImage:(id)sender
{
    [self cancelHidingTimer];
    
    // Create share content
    ZoomImageCell *currentCell = (ZoomImageCell *)[self.collectionView cellForItemAtIndexPath:self.currentIndexPath];
    UIImage *image = currentCell.imageView.image;
    NSArray *arrayOfActivityItems = [NSArray arrayWithObjects:NSLocalizedString(@"image_share", @""), image, nil];
    
    // ViewController
    UIActivityViewController *activityController = [[UIActivityViewController alloc]
                                                    initWithActivityItems:arrayOfActivityItems
                                                    applicationActivities:nil];
    
    // Completion Handler
    UIActivityViewControllerCompletionHandler block = ^(NSString *activityType, BOOL completed) {
        if (completed) {
            NSLog(@"Completed!");
        } else {
            NSLog(@"Cancel!");
        }
        [self hideControlsAfterDelay];
    };
    
    activityController.completionHandler = block;
    [self presentViewController:activityController animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *title = NSLocalizedString(@"alert_save_image_success_title", @"");
    NSString *message = NSLocalizedString(@"alert_save_image_success_content", @"");
    
    if (error) {
        title = NSLocalizedString(@"alert_save_image_failed_title", @"");
        message = NSLocalizedString(@"alert_save_image_failed_content", @"");
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
