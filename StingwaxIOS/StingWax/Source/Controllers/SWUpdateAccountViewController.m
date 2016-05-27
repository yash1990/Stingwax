//
//  SWUpdateAccountViewController.m
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/7/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import "SWUpdateAccountViewController.h"
#import "SWDateTimeHelper.h"
#import "SWAppState.h"

@interface SWUpdateAccountViewController ()

@end


@implementation SWUpdateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    lblStartDate.text = [NSString stringWithFormat:@"%@",[SWDateTimeHelper getConvertedDateWithoutTime:appState.currentUser.startDate]];
    lblEndDate.text = [NSString stringWithFormat:@"%@",[SWDateTimeHelper getConvertedDateWithoutTime:appState.currentUser.exDate]];
    [self.navigationController setNavigationBarHidden:TRUE];
}

-(IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    [SWLogger logEventWithObject:self selector:_cmd];
    if([txtFieldEmail isFirstResponder]) {
        [txtFieldConfirmEmail becomeFirstResponder];
    }
    else if([txtFieldConfirmEmail isFirstResponder]) {
        [txtFieldPassword becomeFirstResponder];
    }
    else if([txtFieldPassword isFirstResponder]) {
        [txtFieldConfirmPassword becomeFirstResponder];
    }
    else if([txtFieldConfirmPassword isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}


- (IBAction)goNextTextField {
    [SWLogger logEventWithObject:self selector:_cmd];
    if([txtFieldEmail isFirstResponder]) {
        [txtFieldConfirmEmail becomeFirstResponder];
    }
    else if([txtFieldConfirmEmail isFirstResponder]) {
        [txtFieldPassword becomeFirstResponder];
    }
    else if([txtFieldPassword isFirstResponder]) {
        [txtFieldConfirmPassword becomeFirstResponder];
    }
    else if([txtFieldConfirmPassword isFirstResponder]) {
        [txtFieldEmail becomeFirstResponder];
    }
}

-(void)btnSelectSubcriptionPlanTapped:(id)sender {
    
}

-(void)btnCancelSubscriptionTapped:(id)sender {
    
}

-(void)btnSubmitTapped:(id)sender {
    
}

@end
