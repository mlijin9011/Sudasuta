//
//  FavoriteViewController.m
//  Sudasuta
//
//  Created by user on 14-3-25.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "FavoriteViewController.h"
#import "ImageGridCell.h"
#import "ImageDBOperator.h"
#import "FavouriteDBOperator.h"
#import "UIImageView+WebCache.h"
#import "SlideShowViewController.h"
#import "ImageDetailViewController.h"

@interface FavoriteViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;

@property (strong, nonatomic) FavouriteDBOperator *favoriteOperator;
@property (strong, nonatomic) NSMutableArray *favoriteImages;

@property (strong, nonatomic) Image *selectedImage;

@end

@implementation FavoriteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.favoriteImages = [@[]mutableCopy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.favoriteOperator = [[FavouriteDBOperator alloc] initWithName:kFavouriteDBName withVersion:kFavouriteDBVersion];
    [self loadFavouriteImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.favoriteImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FavoriteGridCell" forIndexPath:indexPath];
    Image *imageData = self.favoriteImages[indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                   placeholderImage:nil
                            options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedImage = self.favoriteImages[indexPath.row];
    [self performSegueWithIdentifier:@"FavoriteImageDetail" sender:self];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

#pragma mark - Private Methods

- (void)orientationDidChanged:(NSNotification *)notification
{
    [super orientationDidChanged:notification];
    [self.favoriteCollectionView reloadData];
}

- (void)loadFavouriteImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *localFavorite = [[ImageDBOperator sharedInstance] getAllLocalFavourite];
        NSArray *netFavourite  = [self.favoriteOperator getAllFavourite];
        
        NSMutableArray *allfavourite = [[NSMutableArray alloc] init];
        [allfavourite addObjectsFromArray:localFavorite];
        [allfavourite addObjectsFromArray:netFavourite];
        
        if ([self.favoriteImages count] > 0) {
            [self.favoriteImages removeAllObjects];
        }
        self.favoriteImages = allfavourite;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.favoriteCollectionView reloadData];
        });
    });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SlideShow"]) {
        SlideShowViewController *controller = segue.destinationViewController;
        controller.slideData = self.favoriteImages;
    } else if ([segue.identifier isEqualToString:@"FavoriteImageDetail"]) {
        ImageDetailViewController *detailController = (ImageDetailViewController *)segue.destinationViewController;
        detailController.isGroup = NO;
        detailController.images = [[NSArray alloc] initWithObjects:self.selectedImage, nil];
    }
}

@end
