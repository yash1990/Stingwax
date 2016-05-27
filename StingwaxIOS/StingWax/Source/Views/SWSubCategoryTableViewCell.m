//
//  SWSubCategoryTableViewCell.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWSubCategoryTableViewCell.h"

@implementation SWSubCategoryTableViewCell
@synthesize lblCategoryName,image1,txtViewCategoryDescription,layout_Constraint_Height_textview;
@synthesize layoutConstraint_Height_Image,layoutConstraint_Widht_Image;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
