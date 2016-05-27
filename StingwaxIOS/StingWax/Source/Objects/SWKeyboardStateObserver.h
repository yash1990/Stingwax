//
//  SWKeyboardStateObserver.h
//  StingWax
//
//  Created by Tyler Prevost on 2/12/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SWKeyboardState)
{
    SWKeyboardStateAppearing = 1<<0,
    SWKeyboardStateOpen = 1<<1,
    SWKeyboardStateDisappearing = 1<<2,
    SWKeyboardStateClosed = 1<<3,
    
    SWKeyboardStateVisible = SWKeyboardStateAppearing | SWKeyboardStateOpen | SWKeyboardStateDisappearing,
    SWKeyboardStateNotVisible = SWKeyboardStateClosed,
    
    SWKeyboardStateActive = SWKeyboardStateAppearing | SWKeyboardStateOpen,
    SWKeyboardStateInactive = SWKeyboardStateDisappearing | SWKeyboardStateClosed,
};

@interface SWKeyboardStateObserver : NSObject

+ (SWKeyboardState)keyboardState;

@end


@interface NSObject (SWKeyboardObserving)

- (void)beginObservingKeyboardNotifications;
- (void)endObservingKeyboardNotifications;

- (void)keyboardWillShow:(NSNotification *)notif;
- (void)keyboardDidShow:(NSNotification *)notif;
- (void)keyboardWillHide:(NSNotification *)notif;
- (void)keyboardDidHide:(NSNotification *)notif;

@end
