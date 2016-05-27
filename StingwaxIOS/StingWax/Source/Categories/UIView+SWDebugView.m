//
//  UIView+SWDebugView.m
//  StingWax
//
//  Created by Tyler Prevost on 2/14/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "UIView+SWDebugView.h"


@implementation UIView (SWDebugView)

- (void)setIsDebugView:(BOOL)isDebugView
{
#if !defined(DEBUG) || !DEBUG
    if (isDebugView) {
        [self removeFromSuperview];
    }
#endif
}

@end
