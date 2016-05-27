//
//  SWBaseViewController.h
//  StingWax
//
//  Created by Tyler Prevost on 2/10/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SWAppDelegate;

@interface SWBaseViewController : UIViewController
{
    SWAppDelegate *appDelegate;
}
@property (copy, nonatomic) void (^keyboardDidHideHandler)(id vc);

- (void)navigateBackToLogin;
- (void)handleSessionInvalidation:(NSNotification *)notif;
- (IBAction)testSessionInvalidation:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

- (void)performBlockAfterDismissingKeyboard:(void (^)(id vc))block;

@end
