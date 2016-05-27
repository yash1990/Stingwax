//
//  SWCategoryDescriptionTableViewCell.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface SWCategoryDescriptionTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UILabel *lblCategoryName;
@property(nonatomic, strong) IBOutlet UITextView *txtViewCategoryDescription;
@property(nonatomic, strong) IBOutlet UIImageView *image1;
@property(nonatomic, strong) IBOutlet UIImageView *image2;
@property(nonatomic, strong) IBOutlet UIImageView *image3;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *layout_Constraint_Height_textview;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *layout_Constraint_Width_Imageview;
@end
