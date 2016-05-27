//
//  StingWaxAppDelegate.m
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//  com.medlmobile.stingwaxEnterprise
//  com.medlmo.stingwaxDevelopment

#import "SWAppDelegate.h"
#import "SWLoginViewController.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SWKeepAlive.h"
#import "StingWax-Keys.h"
#import "SWAppState.h"
#import "StingWax-Constant.h"
#import <BugSense-iOS/BugSenseController.h>
#import <GooglePlus/GooglePlus.h>
#import "GBDeviceInfo.h"
#import <MessageUI/MessageUI.h>
#import <TwitterKit/TwitterKit.h>
#import <Fabric/Fabric.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface SWAppDelegate () <MFMailComposeViewControllerDelegate>

@end

@implementation SWAppDelegate

static NSString * const kClientID = @"452265719636-qbqmhro0t3j9jip1npl69a3er7biidd2.apps.googleusercontent.com";

#pragma mark Methods

+ (SWAppDelegate *)sharedDelegate
{
    return (SWAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)applicationSetup
{
    // set cache for AFNetworking
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES]; // enables spinner on top for data-request-visualization
    
    appState = [[SWAppState alloc] init];
    NSLog(@"AppState Initialized");
    // Set AudioSession
    NSError *error = nil;
    //	[[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if (error) {
        NSLog(@"AV Session Configuration Error = %@",[error localizedDescription]);
    }else{
        NSLog(@"AV Session Configured");
    }
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    NSLog(@"Background Tasks Configured");
    
    // Changing the default output audio route
    //    UInt32 doChangeDefaultRoute = 1;
    //    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    //    AVAudioSession *audioSession; // get your audio session somehow
    
    BOOL success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    if(!success)
    {
        NSLog(@"error doing outputaudioportoverride - %@", [error localizedDescription]);
    }
    
    [SWKeepAlive startKeepWebSessionAlive];
    
}

- (void)registerAppAppearance {
    UIColor *whiteColor = [UIColor whiteColor];
    NSShadow *shadow = [NSShadow.alloc init];
    shadow.shadowColor = [UIColor blackColor];
    
    // UILabel
    [[UILabel appearance] setBackgroundColor:[UIColor clearColor]];
    
    // UIBarButtonItem
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName: whiteColor,
                                                           NSShadowAttributeName: shadow,
                                                           NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0f]
                                                           } forState:UIControlStateNormal];
    
    // UINavigationBar
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    NSDictionary *textDictionary1 = @{
                                      NSForegroundColorAttributeName: whiteColor,
                                      NSShadowAttributeName: shadow,
                                      NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]
                                      };
    [[UINavigationBar appearance] setTitleTextAttributes:textDictionary1];
    
    // Fixes a problem in iOS 7.1 where UIAlertViews de-saturate the tintColors of
    // other views but then don't re-saturate them when dismissed.
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.window.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    }
}

-(void)updatdeTabBadgeNumber:(NSNotificationCenter *)notification {
    if (self.mainTabBarcontroller)
    {
        id badge = [[NSUserDefaults standardUserDefaults] objectForKey:kTabBarBadgeNumber];
        if(badge && badge != [NSNull null])
        {
            NSString *badgeString = @"0";
            NSInteger badgeNumber = 0;
            @try
            {
                badgeNumber = [badge integerValue];
                badgeString = [NSString stringWithFormat:@"%ld", badgeNumber];
            }
            @catch (NSException *exception) {
            }
            
            [[[[[self mainTabBarcontroller] tabBar] items] objectAtIndex:2] setBadgeValue:badgeNumber>0?badgeString:nil];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
        }
    }
}

#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"75f053e7"];
    StingWax_Constant *constant = [[StingWax_Constant alloc] init];
    [self applicationSetup];
    [self registerAppAppearance];
    [GPPDeepLink setDelegate:self];
    [GPPDeepLink readDeepLinkAfterInstall];
   
    // Clear application badge when app launches
    application.applicationIconBadgeNumber = 0;
    self.myLaunchOptions = launchOptions;
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    [[UITabBar appearance] setTranslucent:FALSE];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [[UITabBar appearance] setBackgroundColor:[UIColor clearColor]];
    [[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    
    // Add registration for remote notifications
    [[Twitter sharedInstance] startWithConsumerKey:@"vr8QzsO3V1wgRooH2gGk7BXsE" consumerSecret:@"eHk5yO2VTfSyDP9TOoyFfWw4e56E67W74UiKcOFwClWlEap4fg"];
//    [Fabric with:@[[Twitter sharedInstance]]];
    
    [self registerForPushNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatdeTabBadgeNumber:) name:kNotificationForBadge object:nil];

    [FBSDKLikeControl class];
    [FBSDKLoginButton class];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    
/*
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    if (receipt) {  //No local receipt -- handle the error.
        NSError *error;
        NSDictionary *requestContents = @{
                                          @"receipt-data": [receipt base64EncodedStringWithOptions:0],
                                          @"password":@"eda722cf21e74ba28c905919faef629d"
                                          };
        NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                              options:0
                                                                error:&error];
        
        if (requestData) {
            // Create a POST request with the receipt data.
            //    NSURL *storeURL = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
            NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
            NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
            [storeRequest setHTTPMethod:@"POST"];
            [storeRequest setHTTPBody:requestData];
            
            // Make a connection to the iTunes Store on a background queue.
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:storeRequest queue:queue
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       if (connectionError) {
                                           // ... Handle error ...
                                       } else {
                                           NSError *error;
                                           NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                                           if (!jsonResponse) { // ... Handle error ...
                                           }
                                           
                                           // ... Send a response back to the device ...
                                       }
                                   }];
        }
    }
    
    
    
    */
   
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [appState.eventQueue postResignActive];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    if([[SWAPI sharedAPI] isValidSession]){
        if (appState.currentPlayerViewController) {
            if (appState.currentPlayerViewController.isPlaying == false) {
                [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
            }
        }
    }
    [FBSDKAppEvents activateApp];
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

}
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadPlayListNotification" object:nil];
    
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [[NSUserDefaults standardUserDefaults] setObject:@(badge) forKey:kTabBarBadgeNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Display text
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    fb581988851946141 String Client App id
//    fb1075342025828202 Person app
//    Developer: 597278913754840
    
    if ([[url absoluteString] rangeOfString:@"581988851946141"].location != NSNotFound ) {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }else{
        
        return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return TRUE;
}

#pragma mark - Push Notification

-(void)registerForPushNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
#if !TARGET_IPHONE_SIMULATOR
    

    
    // Get Bundle Info for Remote Registration (handy if you have more than one app)
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
    NSUInteger rntypes;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8) {
        rntypes = [[[UIApplication sharedApplication] currentUserNotificationSettings] types];
    }
    else {
        rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    }

    
    // Set the defaults to disabled unless we find otherwise...
    NSString *pushBadge = @"disabled";
    NSString *pushAlert = @"disabled";
    NSString *pushSound = @"disabled";
    
    // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
    // one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
    // single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
    // true if those two notifications are on.  This is why the code is written this way
    if(rntypes == UIRemoteNotificationTypeBadge){
        pushBadge = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeAlert){
        pushAlert = @"enabled";
    }
    else if(rntypes == UIRemoteNotificationTypeSound){
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
    else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
        pushBadge = @"enabled";
        pushAlert = @"enabled";
        pushSound = @"enabled";
    }
    
    // Get the users Device Model, Display Name, Unique ID, Token & Version Number
    UIDevice *dev = [UIDevice currentDevice];
    NSString *deviceUuid = [dev.identifierForVendor UUIDString];
    NSString *deviceName = dev.name;
    NSString *deviceModel = dev.model;
    NSString *deviceSystemVersion = dev.systemVersion;
    
    // Prepare the Device Token for Registration (remove spaces and < >)
    NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
//    [[[UIAlertView alloc] initWithTitle:@"Token" message:deviceToken delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    
    // Build URL String for Registration
    // !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
    // !!! SAMPLE: "secure.awesomeapp.com"
    NSString *host = @"www.stingwax.com/api";
    
    // !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
    // !!! ( MUST START WITH / AND END WITH ? ).
    // !!! SAMPLE: "/path/to/apns.php?"
    NSString *urlString = [@"/apns.php?"stringByAppendingString:@"task=register"];
    
    urlString = [urlString stringByAppendingString:@"&appname="];
    urlString = [urlString stringByAppendingString:appName];
    urlString = [urlString stringByAppendingString:@"&appversion="];
    urlString = [urlString stringByAppendingString:appVersion];
    urlString = [urlString stringByAppendingString:@"&deviceuid="];
    urlString = [urlString stringByAppendingString:deviceUuid];
    urlString = [urlString stringByAppendingString:@"&devicetoken="];
    urlString = [urlString stringByAppendingString:deviceToken];
    urlString = [urlString stringByAppendingString:@"&devicename="];
    urlString = [urlString stringByAppendingString:deviceName];
    urlString = [urlString stringByAppendingString:@"&devicemodel="];
    urlString = [urlString stringByAppendingString:deviceModel];
    urlString = [urlString stringByAppendingString:@"&deviceversion="];
    urlString = [urlString stringByAppendingString:deviceSystemVersion];
    urlString = [urlString stringByAppendingString:@"&pushbadge="];
    urlString = [urlString stringByAppendingString:pushBadge];
    urlString = [urlString stringByAppendingString:@"&pushalert="];
    urlString = [urlString stringByAppendingString:pushAlert];
    urlString = [urlString stringByAppendingString:@"&pushsound="];
    urlString = [urlString stringByAppendingString:pushSound];
    if (appState) {
        if (appState.currentUser.userId) {
            urlString = [urlString stringByAppendingString:@"&clientid="];
            urlString = [urlString stringByAppendingString:appState.currentUser.userId];
            
            // Register the Device Data
            // !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
            NSURL *url = [[NSURL alloc] initWithScheme:@"https" host:host path:urlString];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                NSLog(@"Return Response Data: %@", response);
//                        [[[UIAlertView alloc] initWithTitle:@"response" message:[NSString stringWithFormat:@"%@",response] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
/*
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{
                    if ([MFMailComposeViewController canSendMail])
                    {
                        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                        mail.mailComposeDelegate = self;
                        [mail setSubject:@"Testing"];
                        [mail setMessageBody:[NSString stringWithFormat:@"%@\n\n Authorization :%@",response, [[NSUserDefaults standardUserDefaults] objectForKey:kLastAuthToken]] isHTML:NO];
                        [mail setToRecipients:@[@"siddharth.p@msp-group.co.uk",@"sudhir.c@msp-group.co.uk"]];
                        
                        [self.window.rootViewController presentViewController:mail animated:YES completion:NULL];
                    }
                    else
                    {
                        NSLog(@"This device cannot send email");
                    }
                });
*/
            }];
            NSLog(@"Register URL: %@", url);
        }
    }
    
#endif
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
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
}


// Failed to Register for Remote Notifications

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
#if !TARGET_IPHONE_SIMULATOR
    
    NSLog(@"Error in registration. Error: %@", error);
    
#endif
}

// Remote Notification Received while application was open.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
#if !TARGET_IPHONE_SIMULATOR
    
    //    [[[UIAlertView alloc] initWithTitle:@"Remote Notification" message:[NSString stringWithFormat:@"%@",userInfo] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
    
    NSLog(@"remote notification: %@",[userInfo description]);
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    NSString *alert = [apsInfo objectForKey:@"alert"];
    NSLog(@"Received Push Alert: %@", alert);
    
    NSString *sound = [apsInfo objectForKey:@"sound"];
    NSLog(@"Received Push Sound: %@", sound);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    NSString *badge = [apsInfo objectForKey:@"badge"];
    NSLog(@"Received Push Badge: %@", badge);
    
    NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + [[apsInfo objectForKey:@"badge"] integerValue];
    ;
    
//    NSString *strPendingBadge = [NSString stringWithFormat:@"%ld",([[[NSUserDefaults standardUserDefaults] objectForKey:kTabBarBadgeNumber] integerValue]+ [[apsInfo objectForKey:@"badge"] integerValue])];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[strPendingBadge integerValue]];
    
    @try {
        [[NSUserDefaults standardUserDefaults] setObject:@([badge integerValue]) forKey:kTabBarBadgeNumber];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
    }
    @catch (NSException *exception) {
    }
    
    NSString *alertMessage = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (alertMessage.length>0 && application.applicationState == UIApplicationStateActive) {
    }
#endif
}

#pragma mark - GPPDeepLinkDelegate
- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink {
    // An example to handle the deep link data.
    [[[UIAlertView alloc] initWithTitle:@"Deep-link Data" message:[deepLink deepLinkID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
    if([[SWAPI sharedAPI] isValidSession]){
        if (appState.currentPlayerViewController) {
            if (!appState.currentPlayerViewController.isPlaying) {
                [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"IsAlertShowing"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [appState tryRestartingPreviousSessionForUserId:appState.currentUser.userId];
            }
        }
    }
    */
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
    BOOL isAlertviewShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"IsAlertShowing"];
    if (appState.currentPlayerViewController && self.mainTabBarcontroller) {
        if (appState.currentPlayerViewController.isPlaying) {
            NSInteger selectedTabNumber = [self.mainTabBarcontroller selectedIndex];
            UINavigationController *currentNav = [[self.mainTabBarcontroller viewControllers] objectAtIndex:0];
            if (![[currentNav topViewController] isKindOfClass:[SWPlayerViewController  class]]) {
                NSLog(@"Redirect To Player screen");
                [self.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
            }
            else {
                
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"IsAlertShowing"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Set Badge Number In Tab Bar
-(void)setBadgeNumberForTabItemIndex:(NSInteger)item {
    
}

#pragma mark - Size Class Method For Text And UIlable
+(UILabel *)fixWidthAndAnyHeightOfThisLabel:(UILabel *)aLabel {
    aLabel.frame = CGRectMake(aLabel.frame.origin.x, aLabel.frame.origin.y, aLabel.frame.size.width,
                              [SWAppDelegate heightOfTextForString:aLabel.text andFont:aLabel.font maxSize:CGSizeMake(aLabel.frame.size.width, MAXFLOAT)]);
    return aLabel;
}

+(CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    // iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes: [NSDictionary dictionaryWithObject:aFont forKey:NSFontAttributeName]
                                                  context: nil].size;
        return ceilf(sizeOfText.height);
    }
    
    // iOS6
    CGSize textSize = [aString sizeWithFont:aFont constrainedToSize:aSize lineBreakMode:NSLineBreakByWordWrapping];
    return ceilf(textSize.height);
}

+(UILabel *)fixHeightAndAnyWidthOfThisLabel:(UILabel *)aLabel
{
    aLabel.frame = CGRectMake(aLabel.frame.origin.x, aLabel.frame.origin.y,
                              [SWAppDelegate widthOfTextForString:aLabel.text
                                                          andFont:aLabel.font
                                                          maxSize:CGSizeMake(MAXFLOAT, aLabel.frame.size.height)], aLabel.frame.size.height);
    return aLabel;
}

+(CGFloat)widthOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    // iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                                  options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               attributes: [NSDictionary dictionaryWithObject:aFont forKey:NSFontAttributeName]
                                                  context: nil].size;
        return ceilf(sizeOfText.width);
    }
    
    // iOS6
    CGSize textSize = [aString sizeWithFont:aFont constrainedToSize:aSize lineBreakMode:NSLineBreakByWordWrapping];
    return ceilf(textSize.width);
}

@end
