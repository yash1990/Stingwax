//
//  SWUpdateAccountViewController.h
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/7/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWBaseViewController.h"
#import "SWAppDelegate.h"
#import "SWKeyboardAwareScrollView.h"

@interface SWUpdateAccountViewController : SWBaseViewController <UITextFieldDelegate, SWKeyboardAwareScrollViewDelegate>
{
    __weak IBOutlet SWKeyboardAwareScrollView *scrollView;
    __weak IBOutlet UILabel *lblcurentSubcriberType;
    __weak IBOutlet UILabel *lblStartDate;
    __weak IBOutlet UILabel *lblEndDate;
    
    __weak IBOutlet UITextField *txtFieldEmail;
    __weak IBOutlet UITextField *txtFieldConfirmEmail;
    __weak IBOutlet UITextField *txtFieldPassword;
    __weak IBOutlet UITextField *txtFieldConfirmPassword;
    
}

-(IBAction)btnBackTapped:(id)sender;
-(IBAction)btnSelectSubcriptionPlanTapped:(id)sender;
-(IBAction)btnCancelSubscriptionTapped:(id)sender;
-(IBAction)btnSubmitTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;

@end
