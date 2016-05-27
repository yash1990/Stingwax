//
//  SWKeyboardAwareScrollView.h
//  StingWax
//
//  Created by Tyler Prevost on 9/20/13.
//  Copyright (c) 2013 MEDL Mobile, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWKeyboardAwareScrollView;

@protocol SWKeyboardAwareScrollViewDelegate <UIScrollViewDelegate>

@optional
- (UIView *)viewToKeepVisibleWhenKeyboardShowsForScrollView:(SWKeyboardAwareScrollView *)scrollView;

@end


@interface SWKeyboardAwareScrollView : UIScrollView

@property (nonatomic, assign) id<SWKeyboardAwareScrollViewDelegate> delegate;

@end
