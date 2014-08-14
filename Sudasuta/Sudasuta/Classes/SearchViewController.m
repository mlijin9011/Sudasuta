//
//  SearchViewController.m
//  Sudasuta
//
//  Created by user on 14-7-16.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SearchViewController.h"
#import "ImageGridCell.h"
#import "Image.h"
#import "UIImageView+WebCache.h"
#import "ImageDBOperator.h"
#import "JsonObject.h"
#import "MBProgressHUD.h"
#import "UIView+SDSTExtension.h"
#import "UIScrollView+MJRefresh.h"
#import "ImageDetailViewController.h"

typedef NS_ENUM(NSUInteger, SearchSegment) {
    SearchSegment_Local = 0,
    SearchSegment_Network
};

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *searchSegment;
@property (weak, nonatomic) IBOutlet UISearchBar        *searchBar;
@property (weak, nonatomic) IBOutlet UIView             *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UICollectionView *searchCollectionView;

@property (strong, nonatomic) UIPopoverController       *searchPopoverController;
@property (strong, nonatomic) UINavigationController    *searchNavigationController;
@property (strong, nonatomic) SearchConditionView       *searchConditionView;
@property (strong, nonatomic) MBProgressHUD             *indicator;

@property (strong, nonatomic) NSMutableArray            *searchImages;
@property (strong, nonatomic) NSDictionary              *localThemes;
@property (strong, nonatomic) NSArray                   *localSubThemes;
@property (strong, nonatomic) NSArray                   *networkThemes;
@property (strong, nonatomic) NSMutableArray            *searchResults;
@property (strong, nonatomic) NSString                  *lastSearchWord;
@property (strong, nonatomic) Image                     *selectedImage;

@property (nonatomic) NSInteger searchResultIndex;
@property (nonatomic) BOOL      isLocalSearch;
@property (nonatomic) BOOL      isSearchWithTag;

@end

@implementation SearchViewController

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
        // Custom initialization
        self.searchImages = [@[]mutableCopy];
        self.columnCount = 0;
        self.isLocalSearch = YES;
        self.networkThemes = [@[]mutableCopy];
        self.localSubThemes = [@[]mutableCopy];
        self.localThemes = [[NSDictionary alloc] init];
        self.searchResults = [@[]mutableCopy];
        self.searchResultIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchBar.placeholder = NSLocalizedString(@"search_local_search", @"");
    [self.searchCollectionView addHeaderWithTarget:self action:@selector(searchMore)];
    
    [self loadThemesTag];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.searchImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SearchGridCell" forIndexPath:indexPath];
    Image *imageData = self.searchImages[indexPath.row];
    [cell.imageView setImageWithURL:[NSURL URLWithString:imageData.url]
                   placeholderImage:nil
                            options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedImage = self.searchImages[indexPath.row];
    [self performSegueWithIdentifier:@"SearchImageDetail" sender:self];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellSize;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    self.searchBackgroundView.hidden = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    self.searchBackgroundView.hidden = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.isSearchWithTag = NO;
    self.lastSearchWord = self.searchBar.text;
    [self.searchBar resignFirstResponder];
    if (self.isLocalSearch) {
        [self searchFromLocalByKeyword:self.lastSearchWord withTag:self.isSearchWithTag];
    } else {
        [self searchFromNetworkByKeyword:self.lastSearchWord withTag:self.isSearchWithTag];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

#pragma mark - SearchConditionDelegate

- (void)didSelectSearchConditonAtRow:(NSInteger)row withSubpage:(BOOL)hasSubpage
{
    if (self.isLocalSearch) {
        if (hasSubpage) {
            SearchConditionView *subConditionView = [[SearchConditionView alloc] init];
            self.localSubThemes = [self.localThemes objectForKey:self.localThemes.allKeys[row]];
            subConditionView.conditions = self.localSubThemes;
            subConditionView.selectDelegate = self;
            subConditionView.isHasSubpage = NO;
            [self.searchNavigationController pushViewController:subConditionView animated:YES];
        } else {
            self.isSearchWithTag = YES;
            self.searchBar.text = self.localSubThemes[row];
            self.lastSearchWord = self.searchBar.text;
            [self.searchPopoverController dismissPopoverAnimated:YES];
            [self searchFromLocalByKeyword:self.lastSearchWord withTag:self.isSearchWithTag];
        }
    } else {
        self.isSearchWithTag = YES;
        self.searchBar.text = self.networkThemes[row];
        self.lastSearchWord = self.searchBar.text;
        [self.searchPopoverController dismissPopoverAnimated:YES];
        [self searchFromNetworkByKeyword:self.lastSearchWord withTag:self.isSearchWithTag];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchImageDetail"]) {
        ImageDetailViewController *detailController = (ImageDetailViewController *)segue.destinationViewController;
        detailController.isGroup = NO;
        detailController.images = [[NSArray alloc] initWithObjects:self.selectedImage, nil];
    }
}

#pragma mark - Private Methods

- (void)orientationDidChanged:(NSNotification *)notification
{
    [super orientationDidChanged:notification];
    [self viewDidLayoutSubviews];
    [self.searchCollectionView reloadData];
}

- (IBAction)searchSegmentChanged:(id)sender
{
    NSInteger segmentIndex = self.searchSegment.selectedSegmentIndex;
    switch (segmentIndex) {
        case SearchSegment_Local:
            self.searchBar.placeholder = NSLocalizedString(@"search_local_search", @"");
            self.isLocalSearch = YES;
            break;
        
        case SearchSegment_Network:
            self.searchBar.placeholder = NSLocalizedString(@"search_network_search", @"");
            self.isLocalSearch = NO;
            break;
            
        default:
            break;
    }
    
    self.searchBar.text = @"";
    [self.searchResults removeAllObjects];
    [self.searchImages removeAllObjects];
    [self.searchCollectionView reloadData];
}

- (void)searchFromLocalByKeyword:(NSString *)keyword withTag:(BOOL)withTag
{
    if (!self.indicator) {
        self.indicator = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.indicator];
    }
    [self.indicator show:YES];
    
    self.searchResultIndex = 0;
    [self.searchImages removeAllObjects];
    [self.searchResults removeAllObjects];
    
    __block NSArray *articles;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (withTag) {
            articles = [[ImageDBOperator sharedInstance] getArticlesIdByTag:keyword];
        } else {
            articles = [[ImageDBOperator sharedInstance] getArticlesIdByTitle:keyword];
            if (nil == articles || 0 == [articles count]) {
                articles = [[ImageDBOperator sharedInstance] getArticlesIdByTag:keyword];
            }
        }
        
        if (nil == articles || 0 == [articles count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.indicator hide:YES];
                [self.view makeToast:NSLocalizedString(@"search_no_images", @"")];
            });
            
            return ;
        }
        
        [self.searchResults addObjectsFromArray:articles];
        NSInteger articleId = [articles[self.searchResultIndex] integerValue];
        [self.searchImages addObjectsFromArray:[[ImageDBOperator sharedInstance] getImagesBy:articleId]];
        self.searchResultIndex++;
        
        // Update UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [self.searchCollectionView reloadData];
        });
    });
}

- (void)searchFromNetworkByKeyword:(NSString *)keyword withTag:(BOOL)withTag
{
    if (!self.indicator) {
        self.indicator = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:self.indicator];
    }
    [self.indicator show:YES];
    
    self.searchResultIndex = 1;
    [self.searchImages removeAllObjects];
    [self.searchResults removeAllObjects];
    
    NSMutableString *url;
    if (withTag) {
        keyword = [NSString stringWithFormat:@"壁纸 %@", keyword];
        self.lastSearchWord = keyword;
        NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)keyword, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        url = [[NSMutableString alloc] initWithString:kNetworkThemeSearchURLHeader];
        [url appendFormat:@"&word=%@", encodedString];
    } else {
        NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)keyword, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
        url = [[NSMutableString alloc] initWithString:kNetworkSearchURLHeader];
        [url appendFormat:@"&word=%@", encodedString];
        [url appendFormat:@"&oq=%@", encodedString];
    }

    [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Search url = %@", url);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        NSHTTPURLResponse *response = nil;
        NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
        
        if (response && response.statusCode == 200) {
            NSArray *images = [self parseResult:result];
            if (images && images.count > 0) {
                [self.searchResults addObjectsFromArray:images];
                if (self.searchResults.count >= (12 * self.searchResultIndex)) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((self.searchResultIndex - 1) * 12, 12)];
                    [self.searchImages addObjectsFromArray:[self.searchResults objectsAtIndexes:indexSet]];
                    self.searchResultIndex++;
                } else {
                    [self.searchImages addObjectsFromArray:self.searchResults];
                    self.searchResultIndex++;
                }
            } else {
                [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:NSLocalizedString(@"search_no_images", @"") waitUntilDone:NO];
            }
        } else {
            [self.view performSelectorOnMainThread:@selector(makeToast:) withObject:NSLocalizedString(@"search_network_error", @"") waitUntilDone:NO];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.indicator hide:YES];
            [self.searchCollectionView reloadData];
        });
    });
}

- (void)searchMore
{
    if (self.isLocalSearch) {
        if (self.searchResultIndex >= 1 && self.searchResultIndex < [self.searchResults count] ) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSInteger articleId = [self.searchResults[self.searchResultIndex] integerValue];
                self.searchResultIndex++;
                NSArray *newImages = [[ImageDBOperator sharedInstance] getImagesBy:articleId];
                
                // Update UI.
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSMutableArray *indexPaths = [@[] mutableCopy];
                    NSInteger count = newImages.count;
                    for (NSInteger i = 0; i < count; i++) {
                        [self.searchImages insertObject:newImages[i] atIndex:0];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [self.searchCollectionView headerEndRefreshing];
                    
                    // Reload collection view with animation
                    [self.searchCollectionView performBatchUpdates:^{
                        [self.searchCollectionView insertItemsAtIndexPaths:indexPaths];
                    } completion:^(BOOL finished) {
                        
                    }];
                });
            });
            
        } else if ([self.searchResults count] == self.searchResultIndex) {
            [self.searchCollectionView headerEndRefreshing];
            [self.view makeToast:NSLocalizedString(@"no_more_images", @"")];
        }
    } else {
        if (self.searchResults.count <= (12 * (self.searchResultIndex - 1))) {
            [self.searchCollectionView headerEndRefreshing];
            [self.view makeToast:NSLocalizedString(@"no_more_images", @"")];
        } else {
            NSInteger length = 12;
            if (self.searchResults.count <= (12 * self.searchResultIndex)) {
                length = self.searchResults.count - 12 * (self.searchResultIndex - 1);
            }
            
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange((self.searchResultIndex - 1) * 12, length)];
            NSArray *images = [self.searchResults objectsAtIndexes:indexSet];
            self.searchResultIndex++;
            
            NSMutableArray *indexPaths = [@[] mutableCopy];
            for (int i = 0; i < images.count; i++) {
                [self.searchImages insertObject:images[i] atIndex:0];
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [self.searchCollectionView headerEndRefreshing];
            
            // Reload collection view with animation
            [self.searchCollectionView performBatchUpdates:^{
                [self.searchCollectionView insertItemsAtIndexPaths:indexPaths];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (NSArray *)parseResult:(NSData *)result
{
    if (!result) {
        return nil;
    }
    
    @try {
        // Correct Encoding.
        NSString *encodeStr = [[NSString alloc] initWithBytes:[result bytes]
                                                       length:[result length]
                                                     encoding:NSUTF8StringEncoding];
        if (nil == encodeStr) {
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            encodeStr = [[NSString alloc] initWithBytes:[result bytes]
                                                 length:[result length]
                                               encoding:enc];
        }
        
        // Get images Array.
        NSMutableArray *imageList;
        NSData *encodeData      = [encodeStr dataUsingEncoding:NSUTF8StringEncoding];
        JsonObject *jsonResult  = [[JsonObject alloc] initWithData:encodeData];
        NSArray *jsonArray   = [jsonResult getJsonArray:@"data" withFallBack:@[]];
        if (jsonArray && jsonArray.count > 0) {
            imageList = [[NSMutableArray alloc] init];
            for (JsonObject *json in jsonArray) {
                NSString *url = [json getString:@"objURL"];
                if (nil != url && url.length > 0) {
                    Image *image = [[Image alloc] init];
                    image.url = url;
                    [imageList addObject:image];
                }
            }
            
            return imageList;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    }
    
    return nil;
}

- (void)loadThemesTag
{
    NSString *pathLocal = [[NSBundle mainBundle] pathForResource:@"LocalThemes" ofType:@"plist"];
    self.localThemes = [[NSDictionary alloc] initWithContentsOfFile:pathLocal];
    NSString *pathNetwork = [[NSBundle mainBundle] pathForResource:@"NetworkThemes" ofType:@"plist"];
    self.networkThemes = [[[NSDictionary alloc] initWithContentsOfFile:pathNetwork] allKeys];
}

- (IBAction)selectSearchCondition:(id)sender
{
    if (!self.searchConditionView) {
        self.searchConditionView = [[SearchConditionView alloc] init];
        self.searchConditionView.selectDelegate = self;
    }
    self.searchConditionView.conditions = self.isLocalSearch ? self.localThemes.allKeys : self.networkThemes;
    self.searchConditionView.isHasSubpage = self.isLocalSearch;
    [self.searchConditionView reloadData];
    
    if (!self.searchNavigationController) {
        self.searchNavigationController = [[UINavigationController alloc] initWithRootViewController:self.searchConditionView];
    }
    [self.searchNavigationController popToRootViewControllerAnimated:NO];
    self.searchConditionView.navigationItem.title = NSLocalizedString(@"search_theme_tag", @"");
    
    if (!self.searchPopoverController) {
        self.searchPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.searchNavigationController];
    }
    [self.searchPopoverController presentPopoverFromRect:((UIButton *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

@end
