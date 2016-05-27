//
//  SWMyAccountViewController.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/19/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWBaseViewController.h"
#import "SWKeyboardAwareScrollView.h"
#import "SWHelper.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Keys.h"
#import "SWAppState.h"
#import "SWKeyboardStateObserver.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SWAppState.h"
#import "SWAPI.h"

@interface SWMyAccountViewController : SWBaseViewController <SWKeyboardAwareScrollViewDelegate, UITextFieldDelegate>
{
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UILabel *lblcurentSubcriberType;
    __weak IBOutlet UILabel *lblStartDate;
    __weak IBOutlet UILabel *lblEndDate;
    __weak IBOutlet UITextField *txtFieldCreditCardFirstName;
    __weak IBOutlet UITextField *txtFieldCreditCardLastName;
    __weak IBOutlet UITextField *txtFieldCreditCardNumber;
    __weak IBOutlet UITextField *txtFieldCreditCardCodeVerification;
    
    __weak IBOutlet UITextField *txtFieldBillingAddress;
    __weak IBOutlet UITextField *txtFieldBillingAddress2;
    __weak IBOutlet UITextField *txtFieldBillingCity;
    __weak IBOutlet UITextField *txtFieldBillingState;
    __weak IBOutlet UITextField *txtFieldBillingZip;
}

-(IBAction)btnSelectSubcriptionPlanTapped:(id)sender;
-(IBAction)btnSelectExpirationYearTapped:(id)sender;
-(IBAction)btnSelectExpirationMonthTapped:(id)sender;
-(IBAction)btnSubmitTapped:(id)sender;
-(IBAction)btnNowPlayingTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;
@end
