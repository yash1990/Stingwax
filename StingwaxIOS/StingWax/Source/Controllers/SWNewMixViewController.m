//
//  SWNewMixViewController.m
//  StingWax
//
//  Created by MSPSYS129 on 17/06/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWNewMixViewController.h"
#import "SWNewMixTableViewCell.h"
#import "SWAppDelegate.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
//#import "SWNewMixes.h"
#import "SWPlaylist.h"
#import "SWPlayerViewController.h"

@interface SWNewMixViewController ()<UITabBarControllerDelegate,UITabBarDelegate,SWPlayerViewControllerDelegate>
{
    SWAppDelegate *appDelegate;
}
@property(strong, nonatomic) NSArray *arrNewMixes;
@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying;
@end

@implementation SWNewMixViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [SWAppDelegate sharedDelegate];
    self.tblNewMix.delegate = self;
    self.tblNewMix.dataSource = self;
    
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = [UIColor whiteColor];
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationForPlayer:) name:SWMyPlayerRunningNotification object:FALSE];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (appState.currentPlayerViewController) {
        [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
        if (appState.currentPlayerViewController.isPlaying) {
            [self.honeycombView startAnimatingImmediately:NO];
        }
        else {
            [self.honeycombView stopAnimatingImmediately:NO];
        }
    }
    else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.tabBarController.tabBar setHidden:FALSE];
    self.tabBarController.delegate = self;
    [self loadNewStreamsDataFromServer];
    
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kTabBarBadgeNumber];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setBadgeValue:0];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}


-(void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:true];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - Actions
- (IBAction)nowPlaying {
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (appState.currentPlayerViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
            [appDelegate.mainTabBarcontroller setSelectedIndex:0];
            [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
        });
    }
}

#pragma mark - Back Button
-(IBAction)btnBackPressed:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

#pragma mark - Featch Data From Server
-(void)loadNewStreamsDataFromServer {
    [SWLogger logEvent:@"Loading New Mixes"];
    [SVProgressHUD showWithStatus:@"Loading New Mixes" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getNewMixForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error) {
        if (!error) {
            if (data) {
                self.arrNewMixes = [data mutableCopy];
                [self.tblNewMix setDelegate:self];
                [self.tblNewMix setDataSource:self];
                [self.tblNewMix reloadData];
                [SWLogger logEvent:@"Loaded New Mixes with returned data"];
                
                [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:kTabBarBadgeNumber];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];                
            }
            else {
                [SWLogger logEvent:@"Loaded New Mixes with NO returned data"];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading New Mixes: %@", error]];
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UITablebarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
//        return FALSE;
        return TRUE;
    }
    return TRUE;
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyAccountURL]];
//        tabBarController.selectedIndex = 2;
    }
}

#pragma mark - UITableView Delegate And DataSources
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.arrNewMixes count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWNewMixTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewMixCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:TRUE];
    UIView *bgColorView = [[UIView alloc] init];
    [bgColorView setBackgroundColor:[UIColor whiteColor]];
    bgColorView.alpha = 0.5;
    [cell setSelectedBackgroundView:bgColorView];
    
    SWPlaylist *newMixes = self.arrNewMixes[indexPath.row];
    
    cell.lblCategoryName.text = newMixes.categoryTitle.uppercaseString;
    cell.lblMixName.text = newMixes.streamTitle.uppercaseString;
    NSDateFormatter *dtF = [[NSDateFormatter alloc] init];
    [dtF setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d = [dtF dateFromString:newMixes.streamUploadDate];
    NSDateFormatter *dateFormatStr = [[NSDateFormatter alloc] init];
    [dateFormatStr setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatStr stringFromDate:d];
    
    cell.lblAddedDate.text = strDate;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SWPlaylist *stream = (SWPlaylist*)self.arrNewMixes[indexPath.row];
    [self changePlaylistToPlaylist:stream withTrackNumber:@0 trackTime:@0];
}

-(void)receivedNotificationForPlayer:(NSNotification *)notification
{
    NSInteger ii = [[notification object] integerValue];
    [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
    
    if (ii == 1) {
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
        [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        if (!appState.currentPlayerViewController) {
            self.navigationItem.rightBarButtonItem = nil;
        }
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - changePlaylistToPlaylist:withTrackNumber:trackTime:
- (void)changePlaylistToPlaylist:(SWPlaylist *)selectedPlaylist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime
{
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([appState isTimeExpiredForCurrentUser]) {
        appState.currentPlayerViewController = nil;
        [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return;
    }
    else if ([appState isAccountExpiredForCurrentUser])
    {
        appState.currentPlayerViewController = nil;
        [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return;
    }
    
    NSString *changePlaylistsString = @"Change Mix";
    
    void (^changePlaylists)(void) = ^{
        NSString *strTitle1 = @"The Beginning";
        NSString *strTitle2 = @"2nd Hour";
        NSString *strTitle3 = @"3rd Hour";
        NSString *strTitle4 = @"4th Hour";
        NSString *strTitle5 = @"5th Hour";
        NSString *strTitle6 = @"Cancel";
        
        [UIAlertView showWithMessage:@"Start Mix From" cancelButtonTitle:nil otherButtonTitles:@[strTitle1,strTitle2,strTitle3,strTitle4,strTitle5,strTitle6] handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewTappedButton) {
                if ([params.buttonTitle isEqualToString:strTitle1]) {
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@0];
                }
                else if ([params.buttonTitle isEqualToString:strTitle2]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@3600];
                }
                else if ([params.buttonTitle isEqualToString:strTitle3]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@7200];
                }
                else if ([params.buttonTitle isEqualToString:strTitle4]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@10800];
                }
                else if ([params.buttonTitle isEqualToString:strTitle5]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@14400];
                }
                else {
                }
            }
        }];
        
    };
    if (appState.currentPlayerViewController) {
        [UIAlertView showWithMessage:@"Are you sure you wish to listen to a different mix?" cancelButtonTitle:@"Keep Listening"
                   otherButtonTitles:@[changePlaylistsString] handler:^(TPAlertViewHandlerParams *const params) {
                       if (params.handlerType == TPAlertViewTappedButton) {
                           if ([params.buttonTitle isEqualToString:changePlaylistsString]) {
                               changePlaylists();
                           }
                           else {
                               //                               [[NSNotificationCenter defaultCenter] postNotificationName:SWDeselectTableViewCells object:nil];
                           }
                       }
                   }];
    }
    else {
        changePlaylists();
    }
}

#pragma mark - After Choose Playlist
-(void)afterChoosePlaylist:(SWPlaylist *)selectedPlaylist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime{
    void (^getNewPlayer)(void) = ^{
        appState.currentPlayerViewController = nil;
        appState.currentPlayerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlayer"];
    };
    if (appState.currentPlayerViewController) {
        [appState.currentPlayerViewController cleanUpPlayer];
    }
    if (!appState.currentPlayerViewController) {
        getNewPlayer();
    }
    
    appState.currentPlayList = selectedPlaylist;
    appState.currentPlayerViewController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Your main thread code goes in here
        [appState.currentPlayerViewController loadPlaylist:selectedPlaylist withTrackNumber:trackNumber trackTime:trackTime];
        appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
        [appDelegate.mainTabBarcontroller setSelectedIndex:0];
        [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
    });
}

#pragma mark - SWPlayerViewController Delagete
-(void)playerViewControllerDidFinish:(SWPlayerViewController *)controller {
    
}

- (void)playerViewController:(SWPlayerViewController *)controller didChangePlayStatus:(BOOL)isPlaying{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (isPlaying) {
        [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
