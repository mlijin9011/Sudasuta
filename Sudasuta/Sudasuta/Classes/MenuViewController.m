//
//  MenuViewController.m
//  Sudasuta
//
//  Created by user on 14-3-17.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "MenuViewController.h"
#import "PageInfoManager.h"
#import "PageGroupInfo.h"
#import "PageInfo.h"
#import "SDSTMenuViewController.h"

static NSString *groupImages[] = {
    @"IMG_GROUP_ALL",
    @"IMG_GROUP_PLATE",
    @"IMG_GROUP_PHOTOGRAPHY",
    @"IMG_GROUP_LIFE",
    @"IMG_GROUP_INSPIRATION",
    @"IMG_GROUP_DESIGN",
    @"IMG_GROUP_DOWNLOAD",
    @"IMG_GROUP_TUTORIAL",
    @"IMG_GROUP_ORIGINAL"
};

static NSString *headerImages[] = {
    @"BTN_THEMES",
    @"BTN_HEART",
    @"BTN_SEARCH",
    @"BTN_SETTING"
};

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) id<MenuViewDelegate> delegate;
@property (strong, nonatomic) NSArray            *pageInfoGroups;
@property (strong, nonatomic) NSMutableArray     *headerViews;
@property (nonatomic) NSInteger                  currentGroup;

@end

@implementation MenuViewController

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
    self.pageInfoGroups = [[PageInfoManager sharedInstance] loadPageInfoGroups];
    
    UIImage *logo = [UIImage imageNamed:@"IMG_LOGO"];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, 200, 26)];
    logoView.image = logo;
    [self.navigationController.navigationBar addSubview:logoView];
    
    self.headerViews = [@[] mutableCopy];
    MenuHeaderView *headerView = nil;
    NSInteger count = self.pageInfoGroups.count;
    for (NSInteger i = 0; i < count; i++) {
        headerView = [[MenuHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
        headerView.headerTitle = ((PageGroupInfo *)self.pageInfoGroups[i]).title;
        headerView.headerImage = [UIImage imageNamed:headerImages[i]];
        headerView.delegate = self;
        if (i == MenuSection_Theme) {
            [headerView setSelectedEnabled:NO];
        }
        
        [self.headerViews addObject:headerView];
    }
    
    SDSTMenuViewController *controller = (SDSTMenuViewController *)self.parentViewController;
    self.delegate = controller.menuDelegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pageInfoGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PageGroupInfo *pageGroup = (PageGroupInfo *)self.pageInfoGroups[section];
    return pageGroup.pageInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"IMG_MENU_CELL_BACKGROUND"]];
    cell.textLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"IMG_MENU_CELL_BACKGROUND"]];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    PageGroupInfo *group = (PageGroupInfo *)self.pageInfoGroups[indexPath.section];
    if (group.pageInfos.count > 0) {
        cell.textLabel.text = ((PageInfo *)group.pageInfos[indexPath.row]).title;
        cell.imageView.image = [UIImage imageNamed:groupImages[indexPath.row]];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMenuCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kMenuHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    return self.headerViews[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PageGroupInfo *group = (PageGroupInfo *)self.pageInfoGroups[indexPath.section];
    if (group.pageInfos.count > 0) {
        [self.delegate didSelectMenuCell:indexPath.row withPageInfo:group.pageInfos[indexPath.row]];
    }
}

#pragma mark - MenuHeaderDelegate

- (void)didSelectMenuHeaderView:(MenuHeaderView *)menuHeaderView
{
    NSInteger section = [self.headerViews indexOfObject:menuHeaderView];
    
    switch (section) {
        case MenuSection_Theme:
            break;
        
        case MenuSection_Favorite:
        case MenuSection_Search:
            [self.delegate didSelectMenuHeader:section];
            break;
            
        case MenuSection_Setting:
            [self performSegueWithIdentifier:@"SettingPopover" sender:nil];
            break;
            
        default:
            break;
    }
}

@end
