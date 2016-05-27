//
//  SWSocialRegistrationViewController.m
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/13/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import "SWSocialRegistrationViewController.h"
#import "SWRegisterViewController.h"
#import "SWKeyboardAwareScrollView.h"
#import "SWHelper.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Keys.h"
#import "SWAppState.h"
#import "SWKeyboardStateObserver.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SWSubscriptionViewController.h"
#import "GBDeviceInfo.h"

@interface SWSocialRegistrationViewController ()<UITextFieldDelegate, SWKeyboardAwareScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    SWSubscriptionViewController *objSWSubscriptionViewController;
    UIPickerView *myPickerView;
    NSArray *pickerArray;
    UIDatePicker *datePicker;
}

@property(weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property(weak, nonatomic) IBOutlet UIButton *btnChooseSubcription;
@property(weak, nonatomic) IBOutlet  UIButton *btnAgreeWith;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldFirstName;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldLastName;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldBirthDate;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldEmail;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldConfirmEmail;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldPassword;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldConfirmPassword;
@property(weak, nonatomic) IBOutlet  UITextField *txtFieldGender;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
-(IBAction)btnChooseSubcriptionTapped:(id)sender;
-(IBAction)btnTermsAndConditionapped:(id)sender;
-(IBAction)btnSubmitTapped:(id)sender;

@end

@implementation SWSocialRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_ON_LAUNCH handler:nil];
    }
    
    self.txtFieldFirstName.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldLastName.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldEmail.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldConfirmEmail.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldPassword.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldConfirmPassword.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldBirthDate.inputAccessoryView  = self.keyboardToolbar;
    self.txtFieldGender.inputAccessoryView  = self.keyboardToolbar;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    //    self.txtFieldBirthDate.inputAccessoryView = numberToolbar;
    //    self.txtFieldGender.inputAccessoryView = numberToolbar;
    
    datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    [self.txtFieldBirthDate setInputView:datePicker];
    [datePicker setMaximumDate:[NSDate date]];
    self.txtFieldBirthDate.inputView = datePicker;
    
    
    pickerArray = [[NSArray alloc]initWithObjects:@"Male", @"Female", nil];
    myPickerView = [[UIPickerView alloc]init];
    myPickerView.dataSource = self;
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    _txtFieldGender.inputView = myPickerView;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self beginObservingKeyboardNotifications];

    
    NSLog(@"Data %@ ",_dictSocialUserData);
    NSLog(@"Media: %@",_isSocialMediaFacebook?@"TRUE":@"FALSE");
    
    if (self.isSocialMediaFacebook) {
        if ([_dictSocialUserData objectForKey:@"email"]) {
            _txtFieldEmail.text = [NSString stringWithFormat:@"%@",[_dictSocialUserData objectForKey:@"email"]];
            _txtFieldConfirmEmail.text = [NSString stringWithFormat:@"%@",[_dictSocialUserData objectForKey:@"email"]];
            _txtFieldEmail.userInteractionEnabled = NO;
            _txtFieldConfirmEmail.userInteractionEnabled = NO;
        }
        if ([_dictSocialUserData objectForKey:@"first_name"]) {
            _txtFieldFirstName.text = [NSString stringWithFormat:@"%@",[_dictSocialUserData objectForKey:@"first_name"]];
        }
        if ([_dictSocialUserData objectForKey:@"last_name"]) {
            _txtFieldLastName.text = [NSString stringWithFormat:@"%@",[_dictSocialUserData objectForKey:@"last_name"]];
        }
        if ([_dictSocialUserData objectForKey:@"birthday"]) {
            NSString *strDate = [NSString stringWithFormat:@"%@",[_dictSocialUserData objectForKey:@"birthday"]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *dateNew = [dateFormatter dateFromString:strDate];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            strDate = [dateFormatter stringFromDate:dateNew];
            _txtFieldBirthDate.text = strDate;
            datePicker.date = dateNew;
        }
        if ([_dictSocialUserData objectForKey:@"gender"]) {
            NSString *capitalized = [[[[_dictSocialUserData objectForKey:@"gender"] substringToIndex:1] uppercaseString] stringByAppendingString:[[_dictSocialUserData objectForKey:@"gender"] substringFromIndex:1]];
            _txtFieldGender.text = [NSString stringWithFormat:@"%@",capitalized];
        }
        else {
            _txtFieldGender.text = @"Male";
        }
    }
}

#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [pickerArray count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    [_txtFieldGender setText:[pickerArray objectAtIndex:row]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.txtFieldBirthDate.inputView;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *formattedDate = [dateFormatter stringFromDate:picker.date];
    
    self.txtFieldBirthDate.text = [NSString stringWithFormat:@"%@",formattedDate];
}

-(void)doneWithNumberPad {
    if ([_txtFieldBirthDate isFirstResponder]) {
        [self.txtFieldBirthDate resignFirstResponder];
    }
    else {
        [self.txtFieldGender resignFirstResponder];
    }
}


-(IBAction)btnDismissScreen:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}

#pragma mark - Button Choose Subcriprion Clicked
-(void)btnChooseSubcriptionTapped:(id)sender
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performBlockAfterDismissingKeyboard:^(SWSocialRegistrationViewController *vc) {
        //Open DropDown menu
        [vc showDropDownSubcriptionLsit];
    }];
}

-(IBAction)btnAgreeWithTapped:(id)sender {
    self.btnAgreeWith.selected = !self.btnAgreeWith.selected;
}

-(IBAction)btnTermsAndConditionapped:(id)sender {
}

#pragma mark - Button Submit Clicked
-(void)btnSubmitTapped:(id)sender
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performBlockAfterDismissingKeyboard:^(SWSocialRegistrationViewController *vc) {
        // Validate Fields
        if ([vc fieldsValidated]) {
            [vc createRegisterRequest];
        }
    }];
}

#pragma mark - Field Varification
- (BOOL)fieldsValidated
{
    NSString *errorMessage = nil;
    
    if (![SWHelper doWeHaveInternetConnection]) {
        errorMessage = INTERNET_UNAVAIL;
    }
    else if ([self.txtFieldFirstName.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your First Name."];
    }
    else if ([self.txtFieldLastName.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Last Name."];
    }
    else if ([self.txtFieldBirthDate.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Birth Date."];
    }
    else if ([self.txtFieldEmail.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Email."];
    }
    else if ([self.txtFieldConfirmEmail.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Confirm Email."];
    }
    else if (![self.txtFieldConfirmEmail.text isEqualToString:_txtFieldConfirmEmail.text]) {
        errorMessage = [NSString stringWithFormat:@"Your Confirm Email Doesn't Match With Email."];
    }
    else if ([self.txtFieldPassword.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Password."];
    }
    else if ([self.txtFieldConfirmPassword.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Confirm Password."];
    }
    else if (![self.txtFieldPassword.text isEqualToString:_txtFieldConfirmPassword.text]) {
        errorMessage = [NSString stringWithFormat:@"Your Confirm Password Doesn't Match With Password."];
    }
    else if ([self.txtFieldGender.text length] == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Enter Your Gender."];
    }
    else if (self.btnAgreeWith.selected == 0) {
        errorMessage = [NSString stringWithFormat:@"Please Agree With Stingwax Terms And Condition."];
    }
    
    if (errorMessage) {
        [UIAlertView showWithMessage:errorMessage handler:nil];
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.txtFieldBirthDate) {
        if (_txtFieldBirthDate.text.length > 6) {
            @try {
                NSString *strDate = [NSString stringWithFormat:@"%@",_txtFieldBirthDate.text];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *dateNew = [dateFormatter dateFromString:strDate];
                datePicker.date = dateNew;
            }
            @catch (NSException *exception) {
                 datePicker.date = [NSDate date];
            }
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (textField == self.txtFieldFirstName) {
        [self.txtFieldLastName becomeFirstResponder];
    }
    else if (textField == self.txtFieldLastName) {
        [self.txtFieldEmail becomeFirstResponder];
    }
    else if (textField == self.txtFieldEmail) {
        [self.txtFieldConfirmEmail becomeFirstResponder];
    }
    else if (textField == self.txtFieldConfirmEmail) {
        [self.txtFieldPassword becomeFirstResponder];
    }
    else if (textField == self.txtFieldPassword) {
        [self.txtFieldConfirmPassword becomeFirstResponder];
    }
    else if (textField == self.txtFieldConfirmPassword) {
        [self.txtFieldConfirmPassword resignFirstResponder];
    }
    return YES;
}

#pragma mark - Goto Next  Field
- (IBAction)goNextTextField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if ([self.txtFieldFirstName isFirstResponder]) {
        [self.txtFieldLastName becomeFirstResponder];
    }
    else if ([self.txtFieldLastName isFirstResponder]) {
        [self.txtFieldBirthDate becomeFirstResponder];
    }
    else if ([self.txtFieldBirthDate isFirstResponder]) {
        [self.txtFieldEmail becomeFirstResponder];
    }
    else if ([self.txtFieldEmail isFirstResponder]) {
        [self.txtFieldConfirmEmail becomeFirstResponder];
    }
    else if ([self.txtFieldConfirmEmail isFirstResponder]) {
        [self.txtFieldPassword becomeFirstResponder];
    }
    else if ([self.txtFieldPassword isFirstResponder]) {
        [self.txtFieldConfirmPassword becomeFirstResponder];
    }
    else if ([self.txtFieldConfirmPassword isFirstResponder]) {
        [self.txtFieldGender becomeFirstResponder];
    }
    else {
        [self.txtFieldFirstName becomeFirstResponder];
    }
}

#pragma mark - Show DropDown List
-(void)showDropDownSubcriptionLsit {
    
}

#pragma mark - Register Request
- (void)createRegisterRequest
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [SVProgressHUD showWithStatus:@"Register In" maskType:SVProgressHUDMaskTypeGradient];
    
    NSMutableDictionary *dictParams = [[NSMutableDictionary alloc] init];
    [dictParams setObject:_txtFieldEmail.text forKey:@"email"];
    if (self.isSocialMediaFacebook) {
        [dictParams setObject:@"getLoggedInFBregi" forKey:@"methodIdentifier"];
        [dictParams setObject:[self.dictSocialUserData objectForKey:@"id"] forKey:@"fbid"];
    }
    else {
        [dictParams setObject:@"getLoggedInTWregi" forKey:@"methodIdentifier"];
        [dictParams setObject:[self.dictSocialUserData objectForKey:@"id"] forKey:@"twid"];
    }
    [dictParams setObject:_txtFieldFirstName.text forKey:@"fname"];
    [dictParams setObject:_txtFieldLastName.text forKey:@"lname"];
    [dictParams setObject:_txtFieldPassword.text forKey:@"password"];
    [dictParams setObject:_txtFieldBirthDate.text forKey:@"DOB"];
    
    NSString *gender = @"2";
    if ([[_txtFieldGender.text uppercaseString] isEqualToString:@"MALE"]) {
        gender = @"1";
    }
    [dictParams setObject:gender forKey:@"gender"];
    
    [[SWAPI sharedAPI] logInWithNewUserData:dictParams completion:^(SWUser *user, NSError *error) {
        [SVProgressHUD dismiss];
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
                [UIAlertView showWithMessage:error.localizedDescription handler:^(TPAlertViewHandlerParams *const params) {
                    if (error.code == 111 && params.handlerType == TPAlertViewDidDismiss) {
                            [SWAppDelegate sharedDelegate].window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];;
                            [SWAppDelegate sharedDelegate].window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                            [[SWAppDelegate sharedDelegate].window makeKeyAndVisible];
    
                    }
                }];
            }
        }
        
        [SVProgressHUD dismiss];
    }];
}


- (void)loadPlayListController
{
    if (TRUE) {
        [SWHelper setUserValue:@YES forKey:kIsUserRemembered];
        [SWHelper setUserValue:self.txtFieldEmail.text forKey:kUserNameValue];
        [SWHelper setUserValue:self.txtFieldPassword.text forKey:kPasswordValue];
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self endObservingKeyboardNotifications];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
