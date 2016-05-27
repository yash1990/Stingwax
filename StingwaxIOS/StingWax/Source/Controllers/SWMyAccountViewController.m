//
//  SWMyAccountViewController.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/19/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWMyAccountViewController.h"
#import "UITextField+Padding.h"
#import "SWDateTimeHelper.h"

@interface SWMyAccountViewController () {
    
}
@property(strong, nonatomic) NSString *shareStatus;
@end

@implementation SWMyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_ON_LAUNCH handler:nil];
    }
    [txtFieldCreditCardFirstName setLeftPadding:5];
    [txtFieldCreditCardLastName setLeftPadding:5];
    [txtFieldCreditCardNumber setLeftPadding:5];
    [txtFieldCreditCardCodeVerification setLeftPadding:5];
    [txtFieldBillingAddress setLeftPadding:5];
    [txtFieldBillingAddress2 setLeftPadding:5];
    [txtFieldBillingCity setLeftPadding:5];
    [txtFieldBillingState setLeftPadding:5];
    [txtFieldBillingZip setLeftPadding:5];
    [txtFieldCreditCardFirstName setRightPadding:5];
    [txtFieldCreditCardLastName setRightPadding:5];
    [txtFieldCreditCardNumber setRightPadding:5];
    [txtFieldCreditCardCodeVerification setRightPadding:5];
    [txtFieldBillingAddress setRightPadding:5];
    [txtFieldBillingAddress2 setRightPadding:5];
    [txtFieldBillingCity setRightPadding:5];
    [txtFieldBillingState setRightPadding:5];
    [txtFieldBillingZip setRightPadding:5];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self beginObservingKeyboardNotifications];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    lblStartDate.text = [NSString stringWithFormat:@"%@",[SWDateTimeHelper getConvertedDateWithoutTime:appState.currentUser.startDate]];
    lblEndDate.text = [NSString stringWithFormat:@"%@",[SWDateTimeHelper getConvertedDateWithoutTime:appState.currentUser.exDate]];
}


#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (textField == txtFieldCreditCardFirstName) {
        [txtFieldCreditCardLastName becomeFirstResponder];
    }
    else if (textField == txtFieldCreditCardLastName) {
        [txtFieldCreditCardNumber becomeFirstResponder];
    }
    else if (textField == txtFieldCreditCardNumber) {
        [txtFieldCreditCardCodeVerification becomeFirstResponder];
    }
    else if (textField == txtFieldCreditCardCodeVerification) {
        [txtFieldBillingAddress becomeFirstResponder];
    }
    else if (textField == txtFieldBillingAddress) {
        [txtFieldBillingAddress2 becomeFirstResponder];
    }
    else if (textField == txtFieldBillingAddress2) {
        [txtFieldBillingCity becomeFirstResponder];
    }
    else if (textField == txtFieldBillingCity) {
        [txtFieldBillingState becomeFirstResponder];
    }
    else if (textField == txtFieldBillingState) {
        [txtFieldBillingZip becomeFirstResponder];
    }
    else if (textField == txtFieldBillingZip) {
        [self btnSubmitTapped:nil];
    }
    return YES;
}

#pragma mark - Goto Next  Field
- (IBAction)goNextTextField {    
    [SWLogger logEventWithObject:self selector:_cmd];
    if([txtFieldCreditCardFirstName isFirstResponder]) {
        [txtFieldCreditCardLastName becomeFirstResponder];
    }
    else if([txtFieldCreditCardLastName isFirstResponder]) {
        [txtFieldCreditCardNumber becomeFirstResponder];
    }
    else if([txtFieldCreditCardNumber isFirstResponder]) {
        [txtFieldCreditCardCodeVerification becomeFirstResponder];
    }
    else if([txtFieldCreditCardCodeVerification isFirstResponder]) {
        [txtFieldBillingAddress becomeFirstResponder];
    }
    else if([txtFieldBillingAddress isFirstResponder]) {
        [txtFieldBillingAddress2 becomeFirstResponder];
    }
    else if([txtFieldBillingAddress2 isFirstResponder]) {
        [txtFieldBillingCity becomeFirstResponder];
    }
    else if([txtFieldBillingCity isFirstResponder]) {
        [txtFieldBillingState becomeFirstResponder];
    }
    else if([txtFieldBillingState isFirstResponder]) {
        [txtFieldBillingZip becomeFirstResponder];
    }
    else if([txtFieldBillingZip isFirstResponder]) {
        [txtFieldCreditCardFirstName becomeFirstResponder];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.stingwax.com"]];
}


#pragma mark - Button Action
#pragma mark - Button Subsbription Tapped
-(void)btnSelectSubcriptionPlanTapped:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performBlockAfterDismissingKeyboard:^(SWMyAccountViewController *vc) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.stingwax.com"]];
    }];
}

#pragma mark - Button Expiration Year Tapped
-(void)btnSelectExpirationYearTapped:(id)sender {
    [self performBlockAfterDismissingKeyboard:^(SWMyAccountViewController *vc) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.stingwax.com"]];
    }];
}
#pragma mark - Button Expiration Month Tapped
-(void)btnSelectExpirationMonthTapped:(id)sender {
    [self performBlockAfterDismissingKeyboard:^(SWMyAccountViewController *vc) {
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.stingwax.com"]];
    }];
}

#pragma mark - Button Submit Tapped
-(void)btnSubmitTapped:(id)sender {
    [self performBlockAfterDismissingKeyboard:^(SWMyAccountViewController *vc) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.stingwax.com"]];
    }];
}

#pragma mark - Button NowPlaying Tapped 
-(void)btnNowPlayingTapped:(id)sender {
    [self performBlockAfterDismissingKeyboard:^(SWMyAccountViewController *vc) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
