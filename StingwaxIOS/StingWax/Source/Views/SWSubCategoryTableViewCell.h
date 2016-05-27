//
//  SWSubCategoryTableViewCell.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SWSubCategoryTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UILabel *lblCategoryName;
@property(nonatomic, strong) IBOutlet UITextView *txtViewCategoryDescription;
@property(nonatomic, strong) IBOutlet UIImageView *image1;

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *layout_Constraint_Height_textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraint_Widht_Image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraint_Height_Image;
@end
