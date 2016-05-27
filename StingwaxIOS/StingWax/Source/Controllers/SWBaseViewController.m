//
//  SWBaseViewController.m
//  StingWax
//
//  Created by Tyler Prevost on 2/10/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWBaseViewController.h"
#import "SWLoginViewController.h"
#import "SWHoneycombViewController.h"
#import "StingWax-Keys.h"
#import "SWKeyboardStateObserver.h"
#import "SWAPI.h"
#import "SWAppState.h"
#import "SWAppDelegate.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"

static BOOL sessionInvalidated;
@implementation SWBaseViewController

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [SWAppDelegate sharedDelegate];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [super viewWillAppear:animated];
    
    // Don't register for session invalidation notifications if we're a pure
    // SWHoneycombViewController, as in the one in the player view controller.
    
    if (![self isMemberOfClass:[SWHoneycombViewController class]]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSessionInvalidation:) name:SWSessionInvalidatedNotification object:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [SWLogger logEventWithObject:self selector:_cmd];
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWLogger logEventWithObject:self selector:_cmd];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:SWSessionInvalidatedNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [super viewDidDisappear:animated];
    
    // Don't de-register for session invalidation notifications if we're a pure
    // SWHoneycombViewController, as in the one in the player view controller.
    if (![self isMemberOfClass:[SWHoneycombViewController class]]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SWSessionInvalidatedNotification object:nil];
    }
}

#pragma mark - Public Methods
- (void)navigateBackToLogin {
    // Every view controller in the storyboard (except the login view controller)
    // has an unwind segue called "Logout" that references unwindToLogin:
    // So if we're not an SWLoginViewController, we can navigate back to the login.
    // Otherwise, do nothing.
    // (Also do nothing if we are just a pure SWHoneycombViewController, as in
    // the chlid view controller of the player view controller.)
    if (![self isKindOfClass:[SWLoginViewController class]] && ![self isMemberOfClass:[SWHoneycombViewController class]])
    {
        // Also remember our last played song and stuff
        if (appState.currentUser) {
            [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
        }
        [SWLogger logEventWithObject:self selector:_cmd];
        sessionInvalidated = NO;
                
        [SWAppDelegate sharedDelegate].window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];;
        [SWAppDelegate sharedDelegate].window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
        [[SWAppDelegate sharedDelegate].window makeKeyAndVisible];
    }
}

#pragma mark - Remote Control Handling
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:SWReceivedRemoteControlEvent object:event];
}


#pragma mark - Actions

- (IBAction)testSessionInvalidation:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:self];
}


#pragma mark - Keyboard Handling

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)performBlockAfterDismissingKeyboard:(void (^)(id vc))block {
    self.keyboardDidHideHandler = block;
    if ([SWKeyboardStateObserver keyboardState] & SWKeyboardStateActive) {
        [self dismissKeyboard:self];
    }
    else {
        self.keyboardDidHideHandler(self);
        _keyboardDidHideHandler = nil;
    }
}

- (void)keyboardDidShow:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
}

- (void)keyboardDidHide:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (self.keyboardDidHideHandler) {
        _keyboardDidHideHandler(self);
        _keyboardDidHideHandler = nil;
    }
}

#pragma mark - Notifications
/*
- (void)handleSessionInvalidation:(NSNotification *)notif
{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (!sessionInvalidated) {
        sessionInvalidated = YES;
         [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:SWSessionInvalidatedNotification object:nil];
        [UIAlertView showWithTitle:@"Session Time-Out" message:@"Your session has been invalidated. Please log in again to continue listening."
                           handler:^(TPAlertViewHandlerParams *const params) {
                               if (params.handlerType == TPAlertViewTappedButton) {
                                   [self navigateBackToLogin];
                               }
                           }];
    }
}
*/
- (void)handleSessionInvalidation:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (!sessionInvalidated) {
        sessionInvalidated = YES;
        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SWSessionInvalidatedNotification object:nil];
        NSString *strErrorMessage = @"";
        if ([[notif object] isKindOfClass:[NSError class]]) {
            strErrorMessage = [NSString stringWithFormat:@"%@",[(NSError *)[notif object] domain]];
        }
        else{
            strErrorMessage = [NSString stringWithFormat:@"%@",[[notif object] objectForKey:@"error"]];
        }
        
        [UIAlertView showWithTitle:@"Error" message:strErrorMessage
                           handler:^(TPAlertViewHandlerParams *const params) {
                               if (params.handlerType == TPAlertViewTappedButton) {
                                   [self navigateBackToLogin];
                               }
                           }];
    }
}

@end
