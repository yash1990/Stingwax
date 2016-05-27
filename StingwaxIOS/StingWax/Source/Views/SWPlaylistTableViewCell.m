//
//  SWPlaylistTableViewCell.m
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SWPlaylistTableViewCell.h"

#import "UIImage+SWTint.h"

@implementation SWPlaylistTableViewCell

#pragma mark - Setters

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.hexView.tintColor = _color;
    }
    else {
        self.hexView.image = [[UIImage imageNamed:@"img_hextab_white"] sw_imageTintedWithColor:_color];
    }
}


#pragma mark - Object Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.exclusiveTouch = YES;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.hexView.image = [self.hexView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

@end
