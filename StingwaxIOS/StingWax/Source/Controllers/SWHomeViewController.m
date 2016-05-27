//
//  SWHomeViewController.m
//  StingWax
//
//  Created by __DeveloperName__ on 4/25/15.
//  Copyright (c) 2015 __CompanyName__ All rights reserved.
//

#import "SWHomeViewController.h"
#import "SWAppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SWKeepAlive.h"
#import "StingWax-Keys.h"
#import "SWAppState.h"
#import <BugSense-iOS/BugSenseController.h>
#import "SWPlaylistsViewController.h"
#import "SWAPI.h"
#import "SWAuthenticationRequestSerializer.h"
#import "SWAppDelegate.h"
#import "GBDeviceInfo.h"
#import "UINavigationBar+SWUINavigationBar.h"
#import "UITabBar+SWNewSize.h"
#import "UIAlertView+TPBlocks.h"
#import "UIImage+SWTint.h"


@interface SWHomeViewController ()
{
    SWAppDelegate *appDelegate;
    IBOutlet UIImageView *gifImageView;
    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnFreeTrial;
}
@property(strong, nonatomic) IBOutlet UIButton *btnRegistration;
-(IBAction)btnRegitrationPressed:(id)sender;

@end

@implementation SWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [SWAppDelegate sharedDelegate];
    NSDictionary *dictuser = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoggedInUser];
    NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kLastAuthToken];
    NSLog(@"\n %s File In:%s",__FILE__,__PRETTY_FUNCTION__);
    NSLog(@"\nLast logged User:%@",dictuser);
    NSLog(@"\nLast logged User Auth Token:%@",authToken);
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"PreLoginGIF" withExtension:@"gif"];
    gifImageView.image = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];    
   
    
    btnLogin.layer.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:(43.0/255.0f) alpha:1.0f].CGColor;
    btnLogin.layer.borderWidth = 1.0f;
    
    btnFreeTrial.layer.borderColor = [UIColor colorWithRed:1 green:(44/255.0f) blue:0 alpha:1.0f].CGColor;
    btnFreeTrial.layer.borderWidth = 1.0f;
    
     [self checkUserAlreadyLoogedInOrNot];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    layout_Constraint_width_ImgLogo.constant = ceilf((self.view.frame.size.width*46)/100);
    //UserDefault For Logged User
}

-(void)checkUserAlreadyLoogedInOrNot {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kIsCurrentUserLoggedIn]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kIsCurrentUserLoggedIn]) {
            //Auto Login Process
            NSDictionary *dictuser = [[NSUserDefaults standardUserDefaults] objectForKey:kLastLoggedInUser];
            SWUser *user = [SWUser modelObjectWithDictionary:dictuser];
            NSString *authToken = [[NSUserDefaults standardUserDefaults] objectForKey:kLastAuthToken];
            SWAuthenticationRequestSerializer *serializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:authToken];
            [[SWAPI sharedAPI] setRequestSerializer:serializer];
            [appState setCurrentUser:user];
            if ([appState isAccountExpiredForCurrentUser])
            {
                [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
                    if (params.handlerType == TPAlertViewDidDismiss) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                    }
                }];
                return;
            }            
            [SWAPI sharedAPI].validSession = TRUE;
            [self settabbarControllerAsRootViewController];
            NSLog(@"Auto Logging with Usre Data:%@",dictuser);
            NSLog(@"Auto Logging with Authentication:%@",authToken);
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
    }
}

-(void)settabbarControllerAsRootViewController
{
 
    appDelegate.mainTabBarcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"stingWaxTabBar"];
    UITabBar *tabBar = appDelegate.mainTabBarcontroller.tabBar;
    
//    [tabBarController.tabBar setFrame:CGRectMake(0, tabBar.frame.origin.y-10, tabBar.frame.size.width, tabBar.frame.size.height)];
    
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    UIImage *selectedImageTab1;
    UIImage *selectedImageTab2;
    UIImage *selectedImageTab3;
    GBDeviceInfo *objGBDeviceInfo = [GBDeviceInfo deviceInfo];
   if (objGBDeviceInfo.model == GBDeviceModeliPhone5S || objGBDeviceInfo.model == GBDeviceModeliPhone5C || objGBDeviceInfo.model == GBDeviceModeliPhone5) {
        selectedImageTab1 = [[UIImage imageNamed:@"Tab_1_iPhone5s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab2 = [[UIImage imageNamed:@"Tab_2_iPhone5s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab3 = [[UIImage imageNamed:@"Tab_3_iPhone5s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
       
    }
    else if (objGBDeviceInfo.model == GBDeviceModeliPhone6) {
        selectedImageTab1 = [[UIImage imageNamed:@"Tab_1_iPhone6"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab2 = [[UIImage imageNamed:@"Tab_2_iPhone6"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab3 = [[UIImage imageNamed:@"Tab_3_iPhone6"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    else {        
        selectedImageTab1 = [[UIImage imageNamed:@"Tab_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab2 = [[UIImage imageNamed:@"Tab_2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImageTab3 = [[UIImage imageNamed:@"Tab_3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [tabBarItem1 setSelectedImage:selectedImageTab1];
    [tabBarItem2 setSelectedImage:selectedImageTab2];
    [tabBarItem3 setSelectedImage:selectedImageTab3];
    
    [tabBarItem1 setImage:selectedImageTab1];
    [tabBarItem2 setImage:selectedImageTab2];
    [tabBarItem3 setImage:selectedImageTab3];
    
    [tabBarItem1 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    [tabBarItem2 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    [tabBarItem3 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    
    NSDictionary *remoteNotification = appDelegate.myLaunchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification)
    {
        // ...do stuff...
        [appDelegate.mainTabBarcontroller setSelectedIndex:2];
    }
    
    appDelegate.Tab0NavBarcontroller = [[appDelegate.mainTabBarcontroller viewControllers] objectAtIndex:0];
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    appDelegate.window.rootViewController  = appDelegate.mainTabBarcontroller;
    [appDelegate.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
    
    [tabBar setTranslucent:TRUE];
    [tabBar setSelectedImageTintColor:[UIColor clearColor]];
    [tabBar setBackgroundImage:[UIImage new]];
    [tabBar setBackgroundColor:[UIColor clearColor]];
    [tabBar setTintColor:[UIColor clearColor]];
    [tabBar setBarStyle:UIBarStyleDefault];
    
}

-(void)btnRegitrationPressed:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kRegistrationURL]];
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