//
//  UIViewController+SWExitBack.m
//  StingWax
//
//  Created by Tyler Prevost on 2/6/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "UIViewController+SWExitBack.h"

@implementation UIViewController (SWExitBack)

- (IBAction)sw_exitBack:(UIStoryboardSegue *)segue
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
