//
//  ForgotPasswordViewController.m
//  StingWax
//
//  Created by Dhawal Dawar on 20/04/11.
//

#import "SWForgotPasswordViewController.h"

#import "SWKeyboardAwareScrollView.h"
#import "SWKeyboardStateObserver.h"
#import "SWAPI.h"
#import "SWLogger.h"
#import "IQValidator.h"

#import "UIAlertView+TPBlocks.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface SWForgotPasswordViewController() <UITextFieldDelegate, SWKeyboardAwareScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SWKeyboardAwareScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIToolbar *keyboardToolbar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailFieldTopSpace;
@end

@implementation SWForgotPasswordViewController

#pragma mark - Setup Style

- (void)setupStyle
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.background.image = [UIImage imageNamed:@"bkg_plain-tall"];
        self.background.highlightedImage = [UIImage imageNamed:@"bkg_plain"];
        self.emailFieldTopSpace.constant = 300;
        self.logoTopSpace.constant = 40;
    }
    else {
        self.background.image = [UIImage imageNamed:@"bkg_plain_ios6-tall"];
        self.background.highlightedImage = [UIImage imageNamed:@"bkg_plain_ios6"];
        self.emailFieldTopSpace.constant = 280;
        self.logoTopSpace.constant = 20;
    }
    
    [self.background sizeToFit];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    
    if (window.frame.size.height <= 480) {
        // Toggle between 4-inch and 3.5-inch background image sizes
        UIImage *image = self.background.image;
        self.background.image = self.background.highlightedImage;
        self.background.highlightedImage = image;
        [self.background sizeToFit];
    }
    
    CGSize contentSize = self.background.bounds.size;
    contentSize.height -= [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scrollView.contentSize = contentSize;
    
    self.txtEmailAddress.inputAccessoryView = self.keyboardToolbar;
    
    self.logo.layer.shadowColor = [UIColor blackColor].CGColor;
    self.logo.layer.shadowOpacity = 1;
    self.logo.layer.shadowRadius = 25;
    self.logo.layer.shadowOffset = CGSizeMake(0, 0);
}


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

//    [self setupStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:TRUE animated:animated];
    [self.txtEmailAddress resignFirstResponder];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
    [self beginObservingKeyboardNotifications];

    [self.txtEmailAddress becomeFirstResponder];
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

- (void)createPasswordRecoveryRequest
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [[SWAPI sharedAPI] requestPasswordRecovery:self.txtEmailAddress.text completion:^(BOOL success, NSError *error)
     {
         [SVProgressHUD dismiss];
         if (success) {
             [SWLogger logEvent:@"Forgot Password request successful"];
             [UIAlertView showWithMessage:@"Your new login information has been sent to your email. Please be sure to check your SPAM folder too." handler:^(TPAlertViewHandlerParams *const params) {
                                  }];
             [self finish];
         }
         else {
             [SWLogger logEvent:[NSString stringWithFormat:@"Error on Forgot Password request finish: %@", error]];
             [UIAlertView showWithMessage:error.localizedDescription
                                  handler:^(TPAlertViewHandlerParams *const params) {
                                  }];
         }
     }];
}


#pragma mark - Actions

- (IBAction)submit
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
 	NSString *msg = nil;

	if ([self.txtEmailAddress.text length] == 0) {
		msg = [NSString stringWithFormat:@"Please enter your email address."];
	}
    else if(![IQValidator validateEmail:self.txtEmailAddress.text]) {
		msg = [NSString stringWithFormat:@"Enter a valid email address."];
    }
    
    if (msg) {
        [UIAlertView showWithMessage:msg
                             handler:^(TPAlertViewHandlerParams *const params) {
                                 if (params.handlerType == TPAlertViewTappedButton) {
                                     [self.txtEmailAddress becomeFirstResponder];
                                 }
                             }];
	}
    else {
		[self dismissKeyboard:self];

        [SVProgressHUD showWithStatus:@"Requesting Password" maskType:SVProgressHUDMaskTypeGradient];
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [self createPasswordRecoveryRequest];
        });
	}
}

- (IBAction)finish
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    [self performBlockAfterDismissingKeyboard:^(id vc) {
        [vc performSegueWithIdentifier:@"Finish" sender:nil];
    }];
}


#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
	[self.txtEmailAddress resignFirstResponder];
    
    [self submit];
    
	return YES;
}


#pragma mark - SWKeyboardAwareScrollViewDelegate Methods

- (UIView *)viewToKeepVisibleWhenKeyboardShowsForScrollView:(SWKeyboardAwareScrollView *)scrollView
{
    return self.btnBack;
}

@end
