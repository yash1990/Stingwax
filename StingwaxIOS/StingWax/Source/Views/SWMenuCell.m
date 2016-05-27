//
//  SWMenuCell.m
//  StingWax
//
//  Created by MSPSYS129 on 17/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWMenuCell.h"

@implementation SWMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)switchCellONOFFPressed:(id)sender {
//    UISwitch *senderSwitch = (UISwitch*) sender;
//    if (senderSwitch.isOn) {
//        [senderSwitch setThumbTintColor:[UIColor colorWithRed:(239/255.0f) green:(232/255.0f) blue:(20/255.0f) alpha:1]];
//    }
//    else {
//        [senderSwitch setThumbTintColor:[UIColor whiteColor]];
//    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchONOFFPressed:)]) {
        [self.delegate switchONOFFPressed:sender];
    }
}

@end

