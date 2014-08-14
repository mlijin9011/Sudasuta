//
//  SettingViewController.m
//  Sudasuta
//
//  Created by user on 14-3-24.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "SettingViewController.h"
#import "SlideShowSettingViewController.h"

typedef NS_ENUM(NSUInteger, SettingSections) {
    SettingSectionAccount = 0,
    SettingSectionCache,
    SettingSectionSetting,
    SettingSectionAbout
};

@interface SettingViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *clearCacheIndicator;
@property (strong, nonatomic) UIActivityIndicatorView *checkVersionIndicator;
@property (strong, nonatomic) NSArray                 *settingList;

@property (nonatomic) float currentCacheSize;

@end

@implementation SettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImage *navigationBarImage = [UIImage imageNamed:@"IMG_NAVIGATIONBAR_BACKGROUND"];
    [self.navigationController.navigationBar setBackgroundImage:navigationBarImage forBarMetrics:UIBarMetricsDefault];
    
    self.clearCacheIndicator = [[UIActivityIndicatorView alloc] init];
    self.clearCacheIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.clearCacheIndicator.color = [UIColor blackColor];
    
    self.checkVersionIndicator = [[UIActivityIndicatorView alloc] init];
    self.checkVersionIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.checkVersionIndicator.color = [UIColor blueColor];
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"SettingList" ofType:@"plist"];
    NSArray *dataArray = [[NSArray alloc] initWithContentsOfFile:path];
    self.settingList = [[NSArray alloc] initWithArray:dataArray];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get Cache Size In Background
    __block float size = 0.0;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *cache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [cache objectAtIndex:0];
        size = [self cacheSizeForDirectory:cachePath];
        
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.currentCacheSize = size;
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableview Data Source Methods

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
    return settingSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithDictionary:self.settingList[indexPath.section]];
    NSString *key = (NSString *)dict.allKeys[0];
    NSArray *settingSection = [dict objectForKey:key];
    
    cell.textLabel.text = settingSection[indexPath.row];
    
    switch (indexPath.section) {
        case SettingSectionCache:
        {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fMB", self.currentCacheSize];
            UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
            self.clearCacheIndicator.center = accessoryView.center;
            [accessoryView addSubview:self.clearCacheIndicator];
            cell.accessoryView = accessoryView;
        }
            break;
            
        case SettingSectionSetting:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case SettingSectionAbout:
            if (indexPath.row == 2) {
                UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 30)];
                self.checkVersionIndicator.center = accessoryView.center;
                [accessoryView addSubview:self.checkVersionIndicator];
                cell.accessoryView = accessoryView;
            } else {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case SettingSectionAccount:
            break;
            
        case SettingSectionCache:
        {
            UIAlertView *alert  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_clear_cache", @"")
                                                             message:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                                   otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
            alert.tag = 1;
            [alert show];
        }
            break;
            
        case SettingSectionSetting:
        {
            [self performSegueWithIdentifier:@"SlideShowSetting" sender:self];
        }
            break;
            
        case SettingSectionAbout:
        {
            if (indexPath.row == 0) {
                [self performSegueWithIdentifier:@"About" sender:nil];
            } else if (indexPath.row == 1) {
                [self performSegueWithIdentifier:@"Feedback" sender:nil];
            } else if (indexPath.row == 2) {
                [self checkVersionUpdate];
            }
        }
            break;
    }

}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex + 1) {
        if (alertView.tag == 1) {
            NSIndexPath *clearCacheIndex = [NSIndexPath indexPathForItem:0 inSection:SettingSectionCache];
            [self.tableView cellForRowAtIndexPath:clearCacheIndex].userInteractionEnabled = NO;
            [self clearCache];
        } else if (alertView.tag == 2) {
            NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/id***?ls=1&mt=8"];
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

#pragma mark - Privates

- (IBAction)saveSetting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (float)cacheSizeForDirectory:(NSString *)path
{
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    float size = 0;
    NSArray *array = [fileManger contentsOfDirectoryAtPath:path error:nil];
    
    // Get Every File Size In Cache Directory
    for (int i = 0; i < [array count]; i++) {
        NSString *fullPath = [path stringByAppendingPathComponent:[array objectAtIndex:i]];
        BOOL isDirectory;
        
        // Get File Size And Convert to ..MB.
        if (!([fileManger fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory)) {
            NSDictionary *fileAtrributeDic = [fileManger attributesOfItemAtPath:fullPath error:nil];
            size += fileAtrributeDic.fileSize / 1024.0 / 1024.0;
        } else {
            
            // Recursion Get File Size
            size += [self cacheSizeForDirectory:fullPath];
        }
    }
    
    return size;
}

- (void)clearCache
{
    [self.clearCacheIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // Get Cache Path
        NSLog(@"clear cache start ...");
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *paths = nil;
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSMutableString *path = [paths objectAtIndex:0];
        NSDictionary *attributes = [manager attributesOfItemAtPath:path error:nil];
        
        // Delete Cache
        if ([manager isDeletableFileAtPath:path]) {
            [manager removeItemAtPath:path error:nil];
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES
                                attributes:attributes error:nil];
            NSLog(@"clear cache finish ...");
            [NSThread sleepForTimeInterval:1.0];
        }
        
        // Update UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *clearIndex = [NSIndexPath indexPathForRow:0 inSection:SettingSectionCache];
            [self.tableView cellForRowAtIndexPath:clearIndex].userInteractionEnabled = YES;
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [self.clearCacheIndicator stopAnimating];
            self.currentCacheSize = 0.00;
            [self.tableView reloadData];
        });
    });
}

- (void)checkVersionUpdate
{
    [self.checkVersionIndicator startAnimating];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
        
        NSURL *url = [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=***"];
        NSString *file =  [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        
        //"version":"1.0"
        NSRange substr = [file rangeOfString:@"\"version\":\""];
        NSRange substr2 =[file rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:NSMakeRange(substr.location + substr.length, 10)];
        NSRange range = NSMakeRange(substr.location + substr.length, substr2.location - substr.location - substr.length);
        NSString *newVersion =[file substringWithRange:range];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *versionIndex = [NSIndexPath indexPathForRow:2 inSection:SettingSectionAbout];
            [self.tableView cellForRowAtIndexPath:versionIndex].userInteractionEnabled = YES;
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            [self.checkVersionIndicator stopAnimating];
            [self.tableView reloadData];
            
            if(![nowVersion isEqualToString:newVersion]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"alert_app_version_update", @"")
                                                               message:NSLocalizedString(@"alert_sure_to_update", @"")
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"cancel", @"")
                                                     otherButtonTitles:NSLocalizedString(@"ok", @""), nil];
                alert.tag = 2;
                [alert show];
            }
        });
    });
}

@end
