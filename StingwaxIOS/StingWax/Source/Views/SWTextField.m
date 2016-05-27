//
//  SWTextField.m
//  StingWax
//
//  Created by Tyler Prevost on 2/5/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWTextField.h"

@implementation SWTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *color = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                 attributes:@{NSForegroundColorAttributeName : color}];
    
    self.background = [self.background resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)
                                                      resizingMode:UIImageResizingModeStretch];
    
    self.textColor = [UIColor whiteColor];
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 10, 0);
}

@end
