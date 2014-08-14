//
//  ImageGridViewController.m
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "ImageGridViewController.h"
#import "ImageGroupCell.h"
#import "ImageDataManager.h"
#import "MBProgressHUD.h"
#import "SDSTRootViewController.h"
#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "ImageDetailViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "UIView+SDSTExtension.h"

@interface ImageGridViewController ()

@property (strong, nonatomic) IBOutlet UICollectionView *imageCollectionView;
@property (strong, nonatomic) MBProgressHUD             *indicator;

@property (strong, nonatomic) NSMutableArray            *imageGroups;

@property (nonatomic) BOOL      hasMoreData;
@property (nonatomic) NSInteger selectedGroup;

@end

@implementation ImageGridViewController

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
    
    [self.imageCollectionView addHeaderWithTarget:self action:@selector(loadMoreNewData)];
    [self.imageCollectionView addFooterWithTarget:self action:@selector(loadMoreOldData)];
    
    UIImage *image = [UIImage imageNamed:@"IMG_MENU_BUTTON"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(menuButtonTapped)];
    self.navigationItem.leftBarButtonItem = item;
    
    PageGroupInfo *pageGroup = (PageGroupInfo *)[[PageInfoManager sharedInstance] loadPageInfoGroups][0];
    self.pageInfo = pageGroup.pageInfos[0];
    self.navigationItem.title = self.pageInfo.title;
    
    [self loadDefaultDataByCategory:self.pageInfo.title];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[SDSTRootViewController sharedInstance] setMenuEnabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[SDSTRootViewController sharedInstance] setMenuEnabled:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageGroups.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageGroupCell" forIndexPath:indexPath];
    cell.imageGroup = self.imageGroups[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedGroup = indexPath.row;
    [self performSegueWithIdentifier:@"ImageDetail" sender:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kColumnMargin, kColumnMargin, kColumnMargin, kColumnMargin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return kColumnMargin;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kColumnMargin;
}

#pragma mark - UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ImageDetail"]) {
        ImageDetailViewController *detailController = (ImageDetailViewController *)segue.destinationViewController;
        detailController.isGroup = YES;
        detailController.currentGroup = self.imageGroups[self.selectedGroup];
    }
}

#pragma mark - Private Methods

- (void)loadDefaultDataByCategory:(NSString *)category
{
    self.imageGroups = @[].mutableCopy;
    NSArray *groups = [[ImageDataManager sharedInstance] getImageGroupsByCategory:category];
    
    if (!groups || 0 == groups.count) {
        if (!self.indicator) {
            self.indicator = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:self.indicator];
        }
        [self.indicator show:YES];
        
        [[ImageDataManager sharedInstance] loadImageGroupsByCategory:category
                                                      withCompletion:^(NSArray *resultImageList, NSError *error) {
                                                          if (!error) {
                                                              [self.imageGroups addObjectsFromArray:[[ImageDataManager sharedInstance] getImageGroupsByCategory:category]];
                                                          }
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.indicator hide:YES];
                                                              [self.imageCollectionView reloadData];
                                                          });
        }];
    } else {
        [self.indicator hide:YES];
        [self.imageGroups addObjectsFromArray:groups];
        [self.imageCollectionView reloadData];
    }
}

- (void)refreshData
{
    [self.imageGroups removeAllObjects];
    [self loadDefaultDataByCategory:self.pageInfo.title];
    [self.imageCollectionView reloadData];
}

- (void)menuButtonTapped
{
    [[SDSTRootViewController sharedInstance] menuButtonTapped];
}

- (void)orientationDidChanged:(NSNotification *)notification
{
    [super orientationDidChanged:notification];
    [self.imageCollectionView reloadData];
}

- (CGSize)calcuateCellSize:(NSInteger)columnCount
{
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat frameWidth = isPortrait ? screenSize.width : screenSize.height;
    CGFloat cellWidth= (frameWidth - (columnCount + 1) * kColumnMargin) / columnCount;
    
    return CGSizeMake(cellWidth, cellWidth * 1.5);
}

- (void)loadMoreNewData
{
    [[ImageDataManager sharedInstance] loadMoreImageGroupsAsync:self.pageInfo.title
                                                      withCount:self.columnCount * 5
                                                    loadOldData:NO
                                                      completed:^(NSArray *resultImageList, NSError *error) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (!resultImageList || resultImageList.count <= 0) {
                                                                  [self.view makeToast:NSLocalizedString(@"no_more_images", @"")];
                                                              } else {
                                                                  NSMutableArray *indexPaths = [@[] mutableCopy];
                                                                  NSInteger count = resultImageList.count;
                                                                  for (NSInteger i = 0; i < count; i++) {
                                                                      [self.imageGroups insertObject:resultImageList[i] atIndex:0];
                                                                      [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                                                  }
                                                                  
                                                                  [self.imageCollectionView headerEndRefreshing];
                                                                  
                                                                  // Reload collection view with animation
                                                                  [self.imageCollectionView performBatchUpdates:^{
                                                                      [self.imageCollectionView insertItemsAtIndexPaths:indexPaths];
                                                                  } completion:^(BOOL finished) {
                                                                      
                                                                  }];
                                                              }
                                                          });
    }];
}

- (void)loadMoreOldData
{
    [[ImageDataManager sharedInstance] loadMoreImageGroupsAsync:self.pageInfo.title
                                                      withCount:self.columnCount * 5
                                                    loadOldData:YES
                                                      completed:^(NSArray *resultImageList, NSError *error) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              if (!resultImageList || resultImageList.count <= 0) {
                                                                  [self.view makeToast:NSLocalizedString(@"no_more_images", @"")];
                                                              } else {
                                                                  [self.imageGroups addObjectsFromArray:resultImageList];
                                                                  
                                                                  [self.imageCollectionView footerEndRefreshing];
                                                                  [self.imageCollectionView reloadData];
                                                              }
                                                          });
                                                      }];
}

@end
