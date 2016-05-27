//
//  UITextField+Padding.m
//  EssentialWatches_iPhone
//
//  Created by __DeveloperName__ on 06/01/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "UITextField+Padding.h"

@implementation UITextField (Padding)

-(void) setLeftPadding:(int) paddingValue
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

-(void) setRightPadding:(int) paddingValue
{
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, paddingValue, self.frame.size.height)];
    self.rightView = paddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end
