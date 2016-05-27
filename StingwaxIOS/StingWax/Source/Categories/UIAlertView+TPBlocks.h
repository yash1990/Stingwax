//
//  UIAlertView+TPBlocks.h
//  AlertViewBlocks
//
//  Created by Tyler Prevost on 1/28/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import <UIKit/UIKit.h>

// Defaults
extern NSString * const TPAlertViewDefaultCancelButtonTitle;    // @"Okay"
extern NSInteger const TPAlertViewDefaultCancelButtonIndex;     // -1

// Handler Type constants
typedef NS_ENUM(NSInteger, TPAlertViewHandlerType)
{
    TPAlertViewTappedButton = 1,
    TPAlertViewCancel = 2,
    TPAlertViewWillPresent = 4,
    TPAlertViewDidPresent = 12,
    TPAlertViewWillDismiss = 16,
    TPAlertViewDidDismiss = 48,
    TPAlertViewShouldEnableFirstOtherButton = 64,
};

@interface TPAlertViewHandlerParams : NSObject

// The type of the handler. Since the handler gets called for every delegate callback,
// we need a way to determine which callback was actually called. Check this value
// to see which delegate callback was called.
@property (nonatomic, readonly) TPAlertViewHandlerType handlerType;

// The alertView that is associated with the handler.
@property (nonatomic, readonly) UIAlertView *alertView;

// The index of the tapped button, if any. If a button index does not apply to
// a handler type, buttonIndex is NSIntegerMin. The handler types that have
// buttonIndex applicable to them are TPAlertViewTappedButton, TPAlertViewWillDismiss
// and TPAlertViewDidDismiss.
@property (nonatomic, readonly) NSInteger buttonIndex;

// Convenience property for the tapped button's title. You could also get this value with:
// [params.alertView buttonTitleAtIndex:params.buttonIndex];
@property (copy, nonatomic, readonly) NSString *buttonTitle;

// You can set this property in the returned params parameter of a TPAlertViewHandler
// to determine if the alert view's first other button should be enabled or not.
@property (nonatomic) BOOL shouldEnableFirstOtherButton;

@end


// Handler Block Typedef
typedef void(^TPAlertViewHandler)(TPAlertViewHandlerParams *const params);


@interface UIAlertView (TPBlocks)

// Just title
+ (void)showWithTitle:(NSString *)title
              handler:(TPAlertViewHandler)handler;

// Just message
+ (void)showWithMessage:(NSString *)message
                handler:(TPAlertViewHandler)handler;

// Both title and message
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
              handler:(TPAlertViewHandler)handler;

// Title and button titles
+ (void)showWithTitle:(NSString *)title
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
              handler:(TPAlertViewHandler)handler;

// Message and button titles
+ (void)showWithMessage:(NSString *)message
      cancelButtonTitle:(NSString *)cancelButtonTitle
      otherButtonTitles:(NSArray *)otherButtonTitles
                handler:(TPAlertViewHandler)handler;

// Title, message and button titles
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
              handler:(TPAlertViewHandler)handler;

// Everything, including cancelButtonIndex and alertViewStyle
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    cancelButtonIndex:(NSInteger)cancelButtonIndex
    otherButtonTitles:(NSArray *)otherButtonTitles
                style:(UIAlertViewStyle)style
              handler:(TPAlertViewHandler)handler;

// Use the above class methods, OR you can create a UIAlertView first and
// configure it how you want, then call this method on it
- (void)showWithHandler:(TPAlertViewHandler)handler;

@end
