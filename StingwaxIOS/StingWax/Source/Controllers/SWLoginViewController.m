//
//  LoginViewController.m
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SWLoginViewController.h"

#import "SWKeyboardAwareScrollView.h"
#import "SWHelper.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Keys.h"
#import "SWAPI.h"
#import "SWAppState.h"
#import "SWAppDelegate.h"
#import "SWKeyboardStateObserver.h"
#import "StingWax-Constant.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "GBDeviceInfo.h"
#import "UITabBar+SWNewSize.h"
#import <TwitterKit/TwitterKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SWLoginViewController () <UITextFieldDelegate, SWKeyboardAwareScrollViewDelegate,FBSDKLoginButtonDelegate>
{
    SWAppDelegate *appDelegate;
    NSString *strFBID;
    NSString *strTWID;
    NSDictionary *dictFBUserData;
    __weak IBOutlet UIImageView *movableImage;
    BOOL *isMovingImage;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnRememberMe;
@property (weak, nonatomic) IBOutlet UILabel *lblWebsite;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;

@property (weak, nonatomic) IBOutlet TWTRLogInButton *logInTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton *logInFacebookButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *usernameFieldTopSpace;

@property (nonatomic) BOOL isRemembered;

@end


@implementation SWLoginViewController

#pragma mark - Accessors

- (void)setIsRemembered:(BOOL)isRemembered
{
    _isRemembered = isRemembered;
    
    self.btnRememberMe.selected = _isRemembered;
}


#pragma mark - Setup Style

- (void)setupStyle
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.background.image = [UIImage imageNamed:@"bkg_plain-tall"];
        self.background.highlightedImage = [UIImage imageNamed:@"bkg_plain"];
        self.usernameFieldTopSpace.constant = 260;
        self.logoTopSpace.constant = 40;
    }
    else {
        self.background.image = [UIImage imageNamed:@"bkg_plain_ios6-tall"];
        self.background.highlightedImage = [UIImage imageNamed:@"bkg_plain_ios6"];
        self.usernameFieldTopSpace.constant = 240;
        self.logoTopSpace.constant = 20;
    }
    
    [self.background sizeToFit];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    if (window.frame.size.height <= 480) {
        
        self.lblWebsite.numberOfLines = 1;
        [self.lblWebsite sizeToFit];
        
        // Toggle between 4-inch and 3.5-inch background image sizes
        UIImage *image = self.background.image;
        self.background.image = self.background.highlightedImage;
        self.background.highlightedImage = image;
        [self.background sizeToFit];
    }
    
    CGSize contentSize = self.background.bounds.size;
    contentSize.height -= [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scrollView.contentSize = contentSize;
    
    self.txtUserName.inputAccessoryView = self.keyboardToolbar;
    self.txtPassword.inputAccessoryView = self.keyboardToolbar;
    
    self.logo.layer.shadowColor = [UIColor blackColor].CGColor;
    self.logo.layer.shadowOpacity = 1;
    self.logo.layer.shadowRadius = 25;
    self.logo.layer.shadowOffset = CGSizeMake(0, 0);
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = [SWAppDelegate sharedDelegate];
    [self setupStyle];
    
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_ON_LAUNCH handler:nil];
    }
    
    [[FBSDKLoginManager new] logOut];
    strFBID = @"";
    strTWID = @"";
//    [[Twitter sharedInstance] logOut];
    
    movableImage.image = [UIImage new];
//     [self animationLoop:nil finished:nil context:nil];
//    self.logInFacebookButton.publishPermissions = @[@"publish_actions"];
//    self.logInFacebookButton.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    // Check userdefaults for remember me value
    if ([[SWHelper getUserValueForKey:kIsUserRemembered] boolValue]) {
        self.txtUserName.text = [SWHelper getUserValueForKey:kUserNameValue];
        self.txtPassword.text = [SWHelper getUserValueForKey:kPasswordValue];
        self.isRemembered = YES;
    }
    else {
        self.txtUserName.text = @"";
        self.txtPassword.text = @"";
        self.isRemembered = NO;
    }
    layout_Constraint_width_ImgLogo.constant = ceilf((self.view.frame.size.width*46)/100);
    
    /*Twitter*/
    @try {
//        _logInTwitterButton = [TWTRLogInButton buttonWithLogInCompletion:^(TWTRSession* session, NSError* error) {
//            if (session) {
//                NSLog(@"signed in as %@", [session userName]);
//            } else {
//                NSLog(@"error: %@", [error localizedDescription]);
//            }
//        }];
        
        
        [self.logInTwitterButton setLogInCompletion:^(TWTRSession *session, NSError *error) {
            // play with Twitter session
            if(error != nil) {
                //error state
                
            } else {
                
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Twitter Execption:%@",exception);
    }
    @finally {
        
    }
    
   
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    self.txtUserName.enabled = YES;
    self.txtPassword.enabled = YES;
    self.btnLogin.enabled = YES;
    
    [self beginObservingKeyboardNotifications];
    
    NSDictionary *lastKnownUserDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLastLoggedInUser];
    NSString *lastKnownAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:kLastAuthToken];
    
    if (lastKnownUserDict && lastKnownAuthToken) {
        if (appState.currentUser) {
            [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
        }
        // Stop receiving remote control events
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        
//        // Log out last known user so we can log in again
//        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
//        [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self endObservingKeyboardNotifications];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Methods

- (void)createLoginRequest
{
    [SWLogger logEventWithObject:self selector:_cmd];
    // Disable user interaction.. a different loading hud should be implemented instead
    self.txtUserName.enabled = NO;
    self.txtPassword.enabled = NO;
    self.btnLogin.enabled = NO;
    
    [SVProgressHUD showWithStatus:@"Logging In" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] logInWithUserID:self.txtUserName.text password:self.txtPassword.text completion:^(SWUser *user, NSError *error)
    {
        [SVProgressHUD dismiss];
        // re-enable interface
        self.txtUserName.enabled = YES;
        self.txtPassword.enabled = YES;
        self.btnLogin.enabled = YES;
        if (!error) {
            // Make sure result is not nil
            if (user) {
                [SWLogger logEvent:@"Login Successful"];
                //Login Successful
                [appState setCurrentUser:user];
                
                [[SWAPI sharedAPI] sendCarrierInfo_Withcompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        NSLog(@"Successfully sent carrier info");
                    }else{
                        NSLog(@"error sending carrier info");
                    }
                }];
                [self loadPlayListController];
            }
            else {
                [SWLogger logEvent:@"Login Unsuccessful"];
                //Login Unsuccessful
                [appState.eventQueue postUserLoggedOut];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on login: %@", error]];            
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                [UIAlertView showWithMessage:error.localizedDescription handler:nil];
            }
        }
    }];
}

-(void)animationLoop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    // remove:
    //  [UIView setAnimationRepeatCount:1000];
    //  [UIView setAnimationRepeatAutoreverses:YES];
    
    CGFloat x = (CGFloat) (arc4random() % (int) self.view.bounds.size.width*1.3);
    CGFloat y = (CGFloat) (arc4random() % (int) self.view.bounds.size.height*1.2);
    
    CGPoint squarePostion = CGPointMake(x, y);
    movableImage.center = squarePostion;
    // add:
    [UIView setAnimationDelegate:self]; // as suggested by @Carl Veazey in a comment
    [UIView setAnimationDidStopSelector:@selector(animationLoop:finished:context:)];
    
    [UIView commitAnimations];
}


- (void)createLoginRequestWithFB
{
    [SWLogger logEventWithObject:self selector:_cmd];
    // Disable user interaction.. a different loading hud should be implemented instead
    self.txtUserName.enabled = NO;
    self.txtPassword.enabled = NO;
    self.btnLogin.enabled = NO;
    self.logInFacebookButton.enabled = FALSE;
    self.logInTwitterButton.enabled = FALSE;
    
    [SVProgressHUD showWithStatus:@"Logging In" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] logInWithFBWithUserID:strFBID completion:^(SWUser *user, NSError *error) {
         [SVProgressHUD dismiss];
         // re-enable interface
         self.txtUserName.enabled = YES;
         self.txtPassword.enabled = YES;
         self.btnLogin.enabled = YES;
        self.logInFacebookButton.enabled = YES;
        self.logInTwitterButton.enabled = YES;
         if (!error) {
             // Make sure result is not nil
             if (user) {
                 [SWLogger logEvent:@"Login Successful"];
                 //Login Successful
                 [appState setCurrentUser:user];
                 
                 [[SWAPI sharedAPI] sendCarrierInfo_Withcompletion:^(BOOL success, NSError *error) {
                     if (success) {
                         NSLog(@"Successfully sent carrier info");
                     }else{
                         NSLog(@"error sending carrier info");
                     }
                 }];
                 [self loadPlayListController];
             }
             else {
                 [SWLogger logEvent:@"Login Unsuccessful"];
                 //Login Unsuccessful
                 [appState.eventQueue postUserLoggedOut];
             }
         }
         else {
             [SWLogger logEvent:[NSString stringWithFormat:@"Error on login: %@", error]];
             if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                 [UIAlertView showWithMessage:error.localizedDescription handler:nil];
             }
         }
     }];
}

- (void)createLoginRequestWithTW
{
    [SWLogger logEventWithObject:self selector:_cmd];
    // Disable user interaction.. a different loading hud should be implemented instead
    self.txtUserName.enabled = NO;
    self.txtPassword.enabled = NO;
    self.btnLogin.enabled = NO;
    self.logInFacebookButton.enabled = FALSE;
    self.logInTwitterButton.enabled = FALSE;

    
    [SVProgressHUD showWithStatus:@"Logging In" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] logInWithTWWithUserID:strTWID completion:^(SWUser *user, NSError *error) {
        [SVProgressHUD dismiss];
        // re-enable interface
        self.txtUserName.enabled = YES;
        self.txtPassword.enabled = YES;
        self.btnLogin.enabled = YES;
        self.logInFacebookButton.enabled = YES;
        self.logInTwitterButton.enabled = YES;

        
        if (!error) {
            // Make sure result is not nil
            if (user) {
                [SWLogger logEvent:@"Login Successful"];
                //Login Successful
                [appState setCurrentUser:user];
                
                [[SWAPI sharedAPI] sendCarrierInfo_Withcompletion:^(BOOL success, NSError *error) {
                    if (success) {
                        NSLog(@"Successfully sent carrier info");
                    }else{
                        NSLog(@"error sending carrier info");
                    }
                }];
                [self loadPlayListController];
            }
            else {
                [SWLogger logEvent:@"Login Unsuccessful"];
                //Login Unsuccessful
                [appState.eventQueue postUserLoggedOut];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on login: %@", error]];
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                [UIAlertView showWithMessage:error.localizedDescription handler:nil];
            }
        }
    }];
}


- (void)loadPlayListController
{
    if (self.isRemembered) {
        [SWHelper setUserValue:@YES forKey:kIsUserRemembered];
        [SWHelper setUserValue:self.txtUserName.text forKey:kUserNameValue];
        [SWHelper setUserValue:self.txtPassword.text forKey:kPasswordValue];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *now = [[NSDate alloc] init];
        NSString *theDateTime = [dateFormat stringFromDate:now];
        
        NSString *userId = appState.currentUser.userId;
        [appState setSkippedSongCount:@"0" forUserId:userId AndWithDateTime:theDateTime];
    }
    else {
        [SWHelper removeKey:kIsUserRemembered];
        [SWHelper removeKey:kUserNameValue];
        [SWHelper removeKey:kPasswordValue];
    }
    
    [self settabbarControllerAsRootViewController];
}

-(void)settabbarControllerAsRootViewController
{
    appDelegate.mainTabBarcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"stingWaxTabBar"];
    UITabBar *tabBar = appDelegate.mainTabBarcontroller.tabBar;
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    
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
    
    [tabBarItem1 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    [tabBarItem2 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    [tabBarItem3 setImageInsets:UIEdgeInsetsMake(6, 0, -6, 0)];
    
    [tabBarItem1 setImage:selectedImageTab1];
    [tabBarItem2 setImage:selectedImageTab2];
    [tabBarItem3 setImage:selectedImageTab3];
    
    NSDictionary *remoteNotification = appDelegate.myLaunchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification)
    {
        // ...do stuff...
        [appDelegate.mainTabBarcontroller setSelectedIndex:2];
        
    }
    appDelegate.Tab0NavBarcontroller = [[appDelegate.mainTabBarcontroller viewControllers] objectAtIndex:0];
    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    appDelegate.window.rootViewController = appDelegate.mainTabBarcontroller;
    [appDelegate.window makeKeyAndVisible];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
    
    [tabBar setTranslucent:TRUE];
    [tabBar setSelectedImageTintColor:[UIColor clearColor]];
    [tabBar setBackgroundImage:[UIImage new]];
    [tabBar setBackgroundColor:[UIColor clearColor]];
    [tabBar setTintColor:[UIColor clearColor]];
    [tabBar setBarStyle:UIBarStyleDefault];
}

- (BOOL)fieldsValidated {
    NSString *errorMessage = nil;
    
    if (![SWHelper doWeHaveInternetConnection]) {
        errorMessage = INTERNET_UNAVAIL;
    }
    else if ([self.txtUserName.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please enter your username."];
    }
    else if ([self.txtPassword.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please enter your password."];
    }
    if (errorMessage) {
        [UIAlertView showWithMessage:errorMessage handler:nil];
        return NO;
    }
    else {
        return YES;
    }
}


#pragma mark - Actions

- (IBAction)forgotPassword {
    [SWLogger logEventWithObject:self selector:_cmd];
    
    [self performBlockAfterDismissingKeyboard:^(SWLoginViewController *vc) {
        [vc performSegueWithIdentifier:@"ForgotPasswordSegue" sender:nil];
    }];
}

- (IBAction)loginAction {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performBlockAfterDismissingKeyboard:^(SWLoginViewController *vc) {
        // Validate Fields
        if ([vc fieldsValidated]) {
            [vc createLoginRequest];
        }
    }];
}

- (IBAction)tapRememberMe:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    self.isRemembered = !self.isRemembered;
}

- (IBAction)visitStingwax {
    [SWLogger logEventWithObject:self selector:_cmd];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.stingwax.com/"]];
}

- (IBAction)goNextTextField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([self.txtUserName isFirstResponder]) {
        [self.txtPassword becomeFirstResponder];
    }
    else {
        [self.txtUserName becomeFirstResponder];
    }
}

// Keep this here to be able to unwind back to the login screen!
- (IBAction)unwindToLogin:(UIStoryboardSegue *)segue {
}

#pragma mark - Button Back Clicked
- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (textField == self.txtUserName) {
        [self.txtPassword becomeFirstResponder];
    }
    else if (textField == self.txtPassword) {        
        [self loginAction];
    }
    return YES;
}

#pragma mark - SWKeyboardAwareScrollViewDelegate Methods
- (UIView *)viewToKeepVisibleWhenKeyboardShowsForScrollView:(SWKeyboardAwareScrollView *)scrollView
{
    return self.btnRememberMe;
}


#pragma mark - Facebook Login
-(IBAction)btnLoginWithFacebook:(id)sender {
//    
//    self.logInFacebookButton.readPermissions = @[@"public_profile", @"email",@"name"];;
//    self.logInFacebookButton.delegate = self;
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior=FBSDKLoginBehaviorWeb;
    
    [login logInWithReadPermissions:@[@"public_profile",@"email",@"user_birthday"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            // Process error
            NSLog(@"error %@",error);
        } else if (result.isCancelled) {
            // Handle cancellations
            NSLog(@"Cancelled");
        } else {
            NSLog(@"Permission: %@",result.grantedPermissions);
            
            if ([result.grantedPermissions containsObject:@"email"]) {
                // Do work
                NSLog(@"Correct");
                
                NSLog(@"User name: %@",[FBSDKProfile currentProfile].name);
                NSLog(@"User ID: %@",[FBSDKProfile currentProfile].userID);
                
                if ([FBSDKAccessToken currentAccessToken]) {
                    
                    [SWLogger logEventWithObject:self selector:_cmd];
                    [SVProgressHUD showWithStatus:@"Fetching Data" maskType:SVProgressHUDMaskTypeGradient];
                    
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id,name,birthday,first_name,last_name,gender,email"}] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                             NSLog(@"fetched user:%@", result);
                             if ([result objectForKey:@"id"]) {
                                 strFBID = [NSString stringWithFormat:@"%@",[result objectForKey:@"id"]];
                                 dictFBUserData = (NSDictionary *)result;
                                 [self createLoginRequestWithFB];
                             }
                         }
                     }];
                }
            }
        }
    }];
}

-(void)profileUpdated:(NSNotification *) notification {
    NSLog(@"User name: %@",[FBSDKProfile currentProfile].name);
    NSLog(@"User ID: %@",[FBSDKProfile currentProfile].userID);
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

#pragma mark - Twitter Login
-(IBAction)btnLoginWithTwitter:(id)sender {
//    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
//        if (session) {
//            NSLog(@"signed in as %@", [session userName]);
//            
//        } else {
//            NSLog(@"error: %@", [error localizedDescription]);
//        }
//    }];
    
    [[Twitter sharedInstance] logInWithViewController:self.navigationController completion:^(TWTRSession * _Nullable session, NSError * _Nullable error) {
        if (session) {
            
            NSLog(@"signed in as %@", [session userName]);
            strTWID = [NSString stringWithFormat:@"%@",[session userID]];
            [self createLoginRequestWithTW];
            
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Accounts" message:@"Please configure a Twitter account in Settings.app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

@end
