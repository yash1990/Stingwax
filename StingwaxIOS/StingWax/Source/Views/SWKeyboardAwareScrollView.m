//
//  SWKeyboardAwareScrollView.m
//  StingWax
//
//  Created by Tyler Prevost on 9/20/13.
//  Copyright (c) 2013 MEDL Mobile, Inc. All rights reserved.
//

#import "SWKeyboardAwareScrollView.h"

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

@interface SWKeyboardAwareScrollView ()
{
    NSNumber *_keyboardHidden;
}

//@property (nonatomic) BOOL shouldDelayContentTouches;

@end


@implementation SWKeyboardAwareScrollView
@dynamic  delegate;
//#pragma mark - Setters
//
//- (void)setDelaysContentTouches:(BOOL)delaysContentTouches
//{
//    [super setDelaysContentTouches:delaysContentTouches];
//    
//    self.shouldDelayContentTouches = delaysContentTouches;
//}

#pragma mark - Object Lifecycle

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerObservers];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterObservers];
}


#pragma mark - Private Methods

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Notification Handlers

- (void)keyboardWillShow:(NSNotification *)notif
{
    
    CGRect kbFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    kbFrame = [self.window convertRect:kbFrame toView:self];
    
    CGRect containerFrame = self.frame;
    CGRect diffRect = CGRectIntersection(containerFrame, kbFrame);
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, diffRect.size.height, 0.0);
    
//    [UIView animateWithDuration:[notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
//                          delay:0
//                        options:animationOptionsWithCurve([notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue])
//                     animations:
//    ^{
        self.contentInset = contentInsets;
        self.scrollIndicatorInsets = contentInsets;
//    } completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(viewToKeepVisibleWhenKeyboardShowsForScrollView:)]) {
        
        UIView *viewToKeepVisible = [self.delegate viewToKeepVisibleWhenKeyboardShowsForScrollView:self];
        
        // If we have a view to keep visible, try to keep it from being hidden by the keyboard
        if (viewToKeepVisible) {
            
            // Convert viewToKeepVisible's frame
            CGRect viewToKeepVisibleConvertedFrame;
            
            if (viewToKeepVisible.superview != self) {
                viewToKeepVisibleConvertedFrame = [self convertRect:viewToKeepVisible.frame fromView:viewToKeepVisible.superview];
            }
            else {
                viewToKeepVisibleConvertedFrame = viewToKeepVisible.frame;
            }
            
            // Expand viewToKeepVisible's frame by a smidgen (8 pixels all around) so it's not butting up right against the keyboard
            CGRect viewToKeepVisibleExpandedFrame = CGRectInset(viewToKeepVisibleConvertedFrame, 0, -8);
            
            // If viewToKeepVisible is hidden by keyboard, even partially, then scroll it so it's visible
            if (CGRectIntersectsRect(kbFrame, viewToKeepVisibleExpandedFrame)) {
                
                // This seems really hacky but it works...
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    [self scrollRectToVisible:viewToKeepVisibleExpandedFrame animated:YES];
                });
            }
        }
    }
    
//    self.shouldDelayContentTouches = self.delaysContentTouches;
//    self.delaysContentTouches = YES;
}

- (void)keyboardWillHide:(NSNotification *)notif
{
//    [UIView animateWithDuration:0.3 animations:^{
        self.contentInset = UIEdgeInsetsZero;
        self.scrollIndicatorInsets = UIEdgeInsetsZero;
//    }];
    
//    self.delaysContentTouches = self.shouldDelayContentTouches;
}

@end
