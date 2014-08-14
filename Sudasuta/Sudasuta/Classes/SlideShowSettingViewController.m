//
//  SlideShowSettingViewController.m
//  Sudasuta
//
//  Created by user on 14-7-18.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SlideShowSettingViewController.h"

static NSString *slideTypes[] = {
    @"fade",
    @"cameraIris",
    @"rippleEffect",
    @"suckEffect",
    @"rotate",
    @"moveIn",
    @"push",
    @"reveal",
    @"cube",
    @"alignedCube",
    @"flip",
    @"alignedFlip",
    @"pageCurl",
    @"pageUnCurl",
};

static NSString *slideSubtypes[] = {
    @"fromRight",
    @"fromLeft",
    @"fromBottom",
    @"fromTop",
    @"90ccw",
    @"90cw",
    @"180ccw",
    @"180cw"
};

static NSTimeInterval slideIntervals[] = {
    5,
    10,
    30,
    60
};

typedef NS_ENUM(NSUInteger, SettingSections) {
    SettingSectionType = 0,
    SettingSectionInterval,
    SettingSectionOrder
};

@interface SlideShowSettingViewController ()

@property (strong, nonatomic) NSArray *settingList;
@property (nonatomic) NSUInteger selectedTypeIndex;
@property (nonatomic) NSUInteger selectedDirectionIndex;
@property (nonatomic) NSUInteger selectedIntervalIndex;
@property (nonatomic) NSUInteger selectedOrderIndex;

@end

@implementation SlideShowSettingViewController

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
        self.selectedTypeIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kNSUserDefaultKeySlideTypeIndex];
        self.selectedDirectionIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kNSUserDefaultKeySlideDirectionIndex];
        self.selectedIntervalIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kNSUserDefaultKeySlideIntervalIndex];
        self.selectedOrderIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kNSUserDefaultKeySlideOrderIndex];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *navigationBarImage = [UIImage imageNamed:@"IMG_NAVIGATIONBAR_BACKGROUND"];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"SlideShowSettingList" ofType:@"plist"];
    self.settingList = [[NSArray alloc] initWithContentsOfFile:path];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.selectedTypeIndex forKey:kNSUserDefaultKeySlideTypeIndex];
    [defaults setInteger:self.selectedDirectionIndex forKey:kNSUserDefaultKeySlideDirectionIndex];
    [defaults setInteger:self.selectedIntervalIndex forKey:kNSUserDefaultKeySlideIntervalIndex];
    [defaults setInteger:self.selectedOrderIndex forKey:kNSUserDefaultKeySlideOrderIndex];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.settingList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    return key;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    NSArray *settingSection = [dict objectForKey:key];
    return [settingSection count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[section]];
    NSString *key = (NSString *)dict.allKeys[0];
    NSArray *settingSection = [dict objectForKey:key];
    NSString *item = [settingSection objectAtIndex:row];
    
    static NSString *cellIdentifier = @"SlideShowSettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = item;
    switch (section) {
        case SettingSectionType:
            if (self.selectedTypeIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case SettingSectionInterval:
            if (self.selectedIntervalIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case SettingSectionOrder:
            if (self.selectedOrderIndex == row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    switch (section) {
        case SettingSectionType:
            self.selectedTypeIndex = row;
            break;
            
        case SettingSectionInterval:
            self.selectedIntervalIndex = row;
            break;
            
        case SettingSectionOrder:
            self.selectedOrderIndex = row;
            break;
    }
    
	[tableView reloadData];
}

- (NSString *)selectedType
{
	return slideTypes[self.selectedTypeIndex];
}

- (NSString *)selectedDirection
{
    if (self.selectedTypeIndex <= 3) {
        // If selected type has no direction, change direction section data to none.
        return slideSubtypes[0];
    } else if (self.selectedTypeIndex == 4) {
        // If selected type is "rotate", change direction section data to angle parameter.
        return slideSubtypes[4];
    } else {
        return slideSubtypes[0];
    }
    
	return slideSubtypes[0];
}

- (NSTimeInterval)selectedInterval
{
	return slideIntervals[self.selectedIntervalIndex];
}

- (NSUInteger)selectedOrder
{
    return self.selectedOrderIndex;
}

@end
