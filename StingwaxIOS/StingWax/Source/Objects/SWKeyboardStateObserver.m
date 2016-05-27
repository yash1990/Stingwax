//
//  SWKeyboardStateObserver.m
//  StingWax
//
//  Created by Tyler Prevost on 2/12/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWKeyboardStateObserver.h"

static SWKeyboardStateObserver *_sharedObserver;

@interface SWKeyboardStateObserver ()

@property (nonatomic) SWKeyboardState keyboardState;

@end


@implementation SWKeyboardStateObserver

+ (SWKeyboardState)keyboardState
{
    return self.sharedObserver.keyboardState;
}

+ (void)load
{
    @autoreleasepool {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedObserver = [self new];
            _sharedObserver.keyboardState = SWKeyboardStateNotVisible;
        });
    }
}

+ (SWKeyboardStateObserver *)sharedObserver
{
    return _sharedObserver;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self beginObservingKeyboardNotifications];
    }
    return self;
}

- (void)dealloc
{
    [self endObservingKeyboardNotifications];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    self.keyboardState = SWKeyboardStateAppearing;
}

- (void)keyboardDidShow:(NSNotification *)notif
{
    self.keyboardState = SWKeyboardStateOpen;
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    self.keyboardState = SWKeyboardStateDisappearing;
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    self.keyboardState = SWKeyboardStateClosed;
}

@end


@implementation NSObject (SWKeyboardObserving)

- (void)beginObservingKeyboardNotifications
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notifCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [notifCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [notifCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)endObservingKeyboardNotifications
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notifCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [notifCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notifCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
}

- (void)keyboardDidShow:(NSNotification *)notif
{
}

- (void)keyboardWillHide:(NSNotification *)notif
{
}

- (void)keyboardDidHide:(NSNotification *)notif
{
}

@end
