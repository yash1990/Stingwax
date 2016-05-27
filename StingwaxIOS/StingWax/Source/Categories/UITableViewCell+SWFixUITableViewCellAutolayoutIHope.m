//
//  UITableViewCell+FixUITableViewCellAutolayoutIHope.m
//  StingWax
//
//  Created by Tyler Prevost on 2/6/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "UITableViewCell+SWFixUITableViewCellAutolayoutIHope.h"

@implementation UITableViewCell (SWFixUITableViewCellAutolayoutIHope)

+ (void)load
{
    @autoreleasepool {
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
            Method existing = class_getInstanceMethod(self, @selector(layoutSubviews));
            Method new = class_getInstanceMethod(self, @selector(sw_autolayout_replacementLayoutSubviews));
            
            method_exchangeImplementations(existing, new);
        }
    }
}

- (void)sw_autolayout_replacementLayoutSubviews
{
    [super layoutSubviews];
    [self sw_autolayout_replacementLayoutSubviews]; // not recursive due to method swizzling
    [super layoutSubviews];
}

@end
