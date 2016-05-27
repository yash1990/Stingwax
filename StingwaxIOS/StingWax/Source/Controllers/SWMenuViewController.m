//
//  SWMenuViewController.m
//  StingWax
//
//  Created by MSPSYS129 on 26/06/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWMenuViewController.h"
#import "SWAppDelegate.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SWUserNotificationList.h"
#import <MessageUI/MessageUI.h>
#import "NSObject+ConvertString.h"
#import "NSString+Utils.h"
#import "NSDictionary-Expanded.h"
#import "SWSubscriptionViewController.h"
#import "SWUpdateAccountViewController.h"

@interface SWMenuViewController ()<SWMenuCellDelegate,MFMailComposeViewControllerDelegate>
{
    SWSubscriptionViewController *objSWSubscriptionViewController;
    SWUpdateAccountViewController *objSWUpdateAccountViewController;
}
@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying;
@property (nonatomic) NSMutableArray *arrCategoryList;
@end

@implementation SWMenuViewController
@synthesize tblMenu = _tblMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [SWAppDelegate sharedDelegate];
    
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = [UIColor whiteColor];
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationForPlayer:) name:SWMyPlayerRunningNotification object:FALSE];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    
    
    [[UITabBar appearance] setTranslucent:TRUE];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    
    [self.navigationController.navigationBar setHidden:FALSE];
    [self.navigationController setNavigationBarHidden:FALSE animated:animated];
    
    if (appState.currentPlayerViewController) {
        [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
        self.navigationItem.leftBarButtonItem = self.btnNowPlaying;
        if (appState.currentPlayerViewController.isPlaying) {
            [self.honeycombView startAnimatingImmediately:NO];
        }
        else {
            [self.honeycombView stopAnimatingImmediately:NO];
        }
    }
    else {        
        [self.navigationItem setHidesBackButton:YES animated:YES];
    }
    [self getCategoryNotifListFromWeb];
    
}
-(void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:true];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - GetUserCategoryNotifList From Web
-(void)getCategoryNotifListFromWeb {
    [SWLogger logEvent:@"Loading set Notification"];
    [SVProgressHUD showWithStatus:@"getting Notification List" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getUserCategoryNotifyListForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error) {
        if (!error) {
            NSLog(@"%@", data);
            if (data) {
                self.arrCategoryList = data;
                [SWLogger logEvent:@"Loaded New Mixes with returned data"];
            }
            else {
                [SWLogger logEvent:@"Loaded New Mixes with NO returned data"];
            }
            [self.tblMenu setDelegate:self];
            [self.tblMenu setDataSource:self];
            [self.tblMenu reloadData];
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
        [self.tblMenu setDelegate:self];
        [self.tblMenu setDataSource:self];
        [self.tblMenu reloadData];
        [SVProgressHUD dismiss];
    }];
    
}

-(void)receivedNotificationForPlayer:(NSNotification *)notification
{
    NSInteger ii = [[notification object] integerValue];
    [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
    
    if (ii == 1) {
        self.navigationItem.leftBarButtonItem = self.btnNowPlaying;
        [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        if (!appState.currentPlayerViewController) {
            self.navigationItem.leftBarButtonItem = nil;
            [self.navigationItem setHidesBackButton:YES animated:YES];
        }
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - Back Button
-(void)btnBackPressed:(id)sender {
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.45f];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.navigationController.view layer] addAnimation:animation forKey:@""];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)btnContactPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Stingwax Team"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@"info@stingwax.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)btnLogoutPressed:(id)sender {
    NSString *strOkay = @"Okay";
    [UIAlertView showWithMessage:@"Are you sure you want to logout" cancelButtonTitle:@"Cancel" otherButtonTitles:@[strOkay] handler:^(TPAlertViewHandlerParams *const params) {
        if (params.handlerType == TPAlertViewTappedButton) {
            if ([params.buttonTitle isEqualToString:strOkay]) {
                [SWLogger logEventWithObject:self selector:_cmd];
                [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
                // Stop receiving remote control events
                [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                // Terminate player VC.  (stops playing.. yadda yadda )
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showWithStatus:@"Logging Out" maskType:SVProgressHUDMaskTypeGradient];
                });
                
                if (appState.currentPlayerViewController) {
                    [appState.currentPlayerViewController cleanUpPlayer_AndCompletionHandler:^(bool success) {
                        [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                            appState.currentPlayerViewController = nil;
                            if (success) {
                                [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                    appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                    [appDelegate.window makeKeyAndVisible];
                                });
                            }
                        }];
                    }];
                }
                else {
                    [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                        appState.currentPlayerViewController=nil;
                        if (success) {
                            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                                [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                [appDelegate.window makeKeyAndVisible];
                            });
                        }
                    }];
                }
                
            }
            else {
                // [[NSNotificationCenter defaultCenter] postNotificationName:SWDeselectTableViewCells object:nil];
            }
        }
    }];

}

-(void)btnTutorialPressed:(id)sender {
    
}

-(void)btnSwitch_ONOFF_Pressed:(id)sender {
    [SWLogger logEvent:@"Loading set Notification"];
    [SVProgressHUD showWithStatus:@"Loading Set Notification" maskType:SVProgressHUDMaskTypeGradient];
    
    /*
    UISwitch *btnSender = (UISwitch*)sender;
    NSLog(@"CatID:%ld",btnSender.tag);
    
    NSString *strNotificationValue = [NSString stringWithFormat:@"%d",btnSender.isOn];
    NSString *strCatID = [NSString stringWithFormat:@"%ld",btnSender.tag];
    [[SWAPI sharedAPI] setUserCategoryNotifyForUserID:appState.currentUser.userId CategoryID:strCatID notificationvalue:strNotificationValue completion:^(BOOL success, NSError *error) {
        if (!success) {
            // Song was not reported.. should be stored in object archive for retrieval later.
            NSString *strErrorMessage = [NSString stringWithFormat:@"%@",[error domain]];
            [UIAlertView showWithTitle:@"Error" message:strErrorMessage
                               handler:^(TPAlertViewHandlerParams *const params) {
                               }];
            [btnSender setOn:0 animated:TRUE];
        }
        [SVProgressHUD dismiss];
    }];
    */
}

#pragma mark - Actions
- (IBAction)nowPlaying {
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (appState.currentPlayerViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
            [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
        });
    }
}


#pragma mark - UITbaleview Delegate And DataSouces
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 8;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 7) {
        return self.arrCategoryList.count;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    if (indexPath.section == 7) {
        return 48.0f;
    }
    return 35;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 7) {
        return @"Category Notifications";
    }
    return @"";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWMenuCell *cell;
    if (indexPath.section == 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellNotifSetting" forIndexPath:indexPath];
        cell.delegate = self;
        cell.switchONOFF.transform = CGAffineTransformMakeScale(0.8, 0.75);
        SWUserNotificationList *nofication = [self.arrCategoryList objectAtIndex:indexPath.row];
        cell.lblCategoryName.text  = [nofication.categoryName uppercaseString];
        [cell.switchONOFF setTag:[nofication.categoryID integerValue]];
        [cell.switchONOFF setOn:[nofication.Notification integerValue]];
        if (cell.switchONOFF.isOn) {
            [cell.switchONOFF setThumbTintColor:[UIColor colorWithRed:(239/255.0f) green:(232/255.0f) blue:(20/255.0f) alpha:1]];
        }
        else {
            [cell.switchONOFF setThumbTintColor:[UIColor whiteColor]];
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellMenu" forIndexPath:indexPath];
        if (indexPath.section == 0) {
            cell.lblMenuName.text = @"Logout";
        }
        else if (indexPath.section == 1) {
            cell.lblMenuName.text = @"Contact";
        }
        else if (indexPath.section == 2) {
            cell.lblMenuName.text = @"Individual Terms and Condition & Privacy";
        }
        else if (indexPath.section == 3) {
            cell.lblMenuName.text = @"Business Terms and Condition & Privacy";
        }
        else if (indexPath.section == 4) {
            cell.lblMenuName.text = @"Tutorial";
        }
        else if (indexPath.section == 5) {
            cell.lblMenuName.text = @"Account Details";
        }
        else if (indexPath.section == 6) {
            cell.lblMenuName.text = @"Upgrade Account";
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    [v setFrame:CGRectMake(v.frame.origin.x, v.frame.origin.y, v.frame.size.width, 30)];
    v.backgroundView.backgroundColor = [UIColor darkGrayColor];
    view.tintColor = [UIColor darkGrayColor];
    [v.textLabel setTextColor:[UIColor whiteColor]];
    [v.textLabel setFrame:CGRectMake(15, v.textLabel.frame.origin.y, v.textLabel.frame.size.width, v.textLabel.frame.size.height)];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self btnLogoutPressed:nil];
    }
    else if (indexPath.section == 1) {
        [self btnContactPressed:nil];
    }
    else if (indexPath.section == 2) {
//        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"usertermsandcondition"];
        
//        [viewController.tabBarController.tabBar setTranslucent:TRUE];
//        [viewController.tabBarController.tabBar setSelectedImageTintColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setBackgroundImage:[UIImage new]];
//        [viewController.tabBarController.tabBar setBackgroundColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setTintColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
        
//        [self.navigationController pushViewController:viewController animated:TRUE];
        [self performSegueWithIdentifier:@"TermsAndConditionSegue" sender:self];
    }
    else if (indexPath.section == 3) {
//        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"businesstermsandcondition"];
        
//        [viewController.tabBarController.tabBar setTranslucent:FALSE];
//        [viewController.tabBarController.tabBar setSelectedImageTintColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setBackgroundImage:[UIImage new]];
//        [viewController.tabBarController.tabBar setBackgroundColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setTintColor:[UIColor clearColor]];
//        [viewController.tabBarController.tabBar setBarStyle:UIBarStyleDefault];
        
//        [self.navigationController pushViewController:viewController animated:TRUE];
        [self performSegueWithIdentifier:@"BusinessSegue" sender:self];
    }
    else if (indexPath.section == 4) {
        
    }
    else if (indexPath.section == 5) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        if(!objSWUpdateAccountViewController) {
            objSWUpdateAccountViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWUpdateAccountViewController"];
        }
        [self.navigationController pushViewController:objSWUpdateAccountViewController animated:TRUE];
        
    }
    else if (indexPath.section == 6) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        if(!objSWSubscriptionViewController) {
            objSWSubscriptionViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWSubscriptionViewController"];
        }
        [self.navigationController pushViewController:objSWSubscriptionViewController animated:TRUE];
        
    }
}

#pragma mark - Menucell Delegate
-(void)switchONOFFPressed:(id)sender {
    [SWLogger logEvent:@"Loading set Notification"];
    [SVProgressHUD showWithStatus:@"Loading Set Notification" maskType:SVProgressHUDMaskTypeGradient];
    
    
    __block UISwitch *btnSender = (UISwitch*)sender;
    NSLog(@"CatID:%ld",btnSender.tag);
    NSLog(@"Switch is On:%d",btnSender.isOn);
    
   __block NSString *strNotificationValue = [NSString stringWithFormat:@"%d",btnSender.isOn];
   __block NSString *strCatID = [NSString stringWithFormat:@"%ld",btnSender.tag];
    [[SWAPI sharedAPI] setUserCategoryNotifyForUserID:appState.currentUser.userId CategoryID:strCatID notificationvalue:strNotificationValue completion:^(BOOL success, NSError *error) {
        if (!success) {
            // Song was not reported.. should be stored in object archive for retrieval later.
            NSString *strErrorMessage = [NSString stringWithFormat:@"%@",[error domain]];
            [UIAlertView showWithTitle:@"Error" message:strErrorMessage
                               handler:^(TPAlertViewHandlerParams *const params) {
                               }];
            [btnSender setOn:!btnSender.isOn animated:TRUE];
            
        }
        else {
            NSInteger count = 0;
            for (SWUserNotificationList *notif in self.arrCategoryList) {                
                if ([notif.categoryID isEqualToString:strCatID] ) {
                    notif.Notification = [NSString stringWithFormat:@"%d",btnSender.isOn];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:count inSection:5];
                    [self.tblMenu reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                count++;
            }
        }
        if (btnSender.isOn) {
            [btnSender setThumbTintColor:[UIColor colorWithRed:(239/255.0f) green:(232/255.0f) blue:(20/255.0f) alpha:1]];
        }
        else {
            [btnSender setThumbTintColor:[UIColor whiteColor]];
        }
        [SVProgressHUD dismiss];
    }];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
