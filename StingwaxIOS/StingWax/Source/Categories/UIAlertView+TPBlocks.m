//
//  UIAlertView+TPBlocks.m
//  AlertViewBlocks
//
//  Created by Tyler Prevost on 1/28/14.
//  Copyright (c) 2014 Tyler Prevost. All rights reserved.
//

#import "UIAlertView+TPBlocks.h"

// Defaults
NSString * const TPAlertViewDefaultCancelButtonTitle    = @"Okay";
NSInteger const TPAlertViewDefaultCancelButtonIndex     = -1;


@interface TPAlertViewHandlerParams ()
{
    NSNumber *_buttonIndex;
}

@property (nonatomic) TPAlertViewHandlerType handlerType;
@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) NSInteger buttonIndex;
@property (copy, nonatomic) NSString *buttonTitle;

@end


@implementation TPAlertViewHandlerParams

- (NSInteger)buttonIndex
{
    if (!_buttonIndex) {
        _buttonIndex = @(NSIntegerMin);
    }
    return _buttonIndex.integerValue;
}

- (void)setButtonIndex:(NSInteger)buttonIndex
{
    _buttonIndex = @(buttonIndex);
}

@end


@interface TPAlertViewDelegate : NSObject <UIAlertViewDelegate>
{
    TPAlertViewHandler _handler;
}

@property (copy, nonatomic) TPAlertViewHandler handler;

+ (NSMutableSet *)sharedAlertViewDelegates;

@end


@implementation TPAlertViewDelegate

+ (NSMutableSet *)sharedAlertViewDelegates
{
    static NSMutableSet *_sharedAlertViewDelegates;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAlertViewDelegates = [NSMutableSet set];
    });
    return _sharedAlertViewDelegates;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewTappedButton;
        params.alertView = alertView;
        params.buttonIndex = buttonIndex;
        params.buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        _handler(params);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewWillPresent;
        params.alertView = alertView;
        _handler(params);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewDidPresent;
        params.alertView = alertView;
        _handler(params);
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewWillDismiss;
        params.alertView = alertView;
        params.buttonIndex = buttonIndex;
        params.buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        _handler(params);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewDidDismiss;
        params.alertView = alertView;
        params.buttonIndex = buttonIndex;
        params.buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
        _handler(params);
    }
    [self.class.sharedAlertViewDelegates removeObject:self];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
    params.shouldEnableFirstOtherButton = YES;
    
    if (self.handler) {
        params.handlerType = TPAlertViewShouldEnableFirstOtherButton;
        params.alertView = alertView;
        _handler(params);
    }
    
    return params.shouldEnableFirstOtherButton;
}

@end


@interface TPAlertViewDelegateWithCancel : TPAlertViewDelegate
@end


@implementation TPAlertViewDelegateWithCancel

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.handler) {
        TPAlertViewHandlerParams *params = [TPAlertViewHandlerParams new];
        params.handlerType = TPAlertViewCancel;
        params.alertView = alertView;
        _handler(params);
    }
    [self.class.sharedAlertViewDelegates removeObject:self];
}

@end


@implementation UIAlertView (TPBlocks)

+ (void)showWithTitle:(NSString *)title handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:title
                message:nil
      cancelButtonTitle:TPAlertViewDefaultCancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:nil
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithMessage:(NSString *)message handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:nil
                message:message
      cancelButtonTitle:TPAlertViewDefaultCancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:nil
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:title
                message:message
      cancelButtonTitle:TPAlertViewDefaultCancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:nil
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithTitle:(NSString *)title
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
              handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:title
                message:nil
      cancelButtonTitle:cancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:otherButtonTitles
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithMessage:(NSString *)message
      cancelButtonTitle:(NSString *)cancelButtonTitle
      otherButtonTitles:(NSArray *)otherButtonTitles
                handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:nil
                message:message
      cancelButtonTitle:cancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:otherButtonTitles
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
              handler:(TPAlertViewHandler)handler
{
    [self showWithTitle:title
                message:message
      cancelButtonTitle:cancelButtonTitle
      cancelButtonIndex:TPAlertViewDefaultCancelButtonIndex
      otherButtonTitles:otherButtonTitles
                  style:UIAlertViewStyleDefault
                handler:handler];
}

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    cancelButtonIndex:(NSInteger)cancelButtonIndex
    otherButtonTitles:(NSArray *)otherButtonTitles
                style:(UIAlertViewStyle)style
              handler:(TPAlertViewHandler)handler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:cancelButtonTitle
                                                  otherButtonTitles:otherButtonTitles.firstObject, nil];
        alertView.cancelButtonIndex = cancelButtonIndex;
        alertView.alertViewStyle = style;
        
        for (NSString *buttontitle in otherButtonTitles) {
            if (otherButtonTitles.firstObject != buttontitle) {
                [alertView addButtonWithTitle:buttontitle];
            }
        }
        
        [alertView setDelegateAndShow:handler withCancel:cancelButtonTitle.length > 0];
    });
}

- (void)showWithHandler:(TPAlertViewHandler)handler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDelegateAndShow:handler withCancel:[self buttonTitleAtIndex:self.cancelButtonIndex].length > 0];
    });
}

- (void)setDelegateAndShow:(TPAlertViewHandler)handler withCancel:(BOOL)withCancel
{
    TPAlertViewDelegate *alertViewDelegate;
    
    if (handler) {
        if (withCancel) {
            alertViewDelegate = [TPAlertViewDelegateWithCancel new];
        }
        else {
            alertViewDelegate = [TPAlertViewDelegate new];
        }
        alertViewDelegate.handler = handler;
    }
    
    self.delegate = alertViewDelegate;
    
    if (alertViewDelegate) {
        [[TPAlertViewDelegate sharedAlertViewDelegates] addObject:alertViewDelegate];
    }
    
    [self show];
}

@end
