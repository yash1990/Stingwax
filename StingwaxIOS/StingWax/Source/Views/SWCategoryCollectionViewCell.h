//
//  SWCategoryCollectionViewCell.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/5/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWCategoryCollectionViewCell : UICollectionViewCell

@property(weak, nonatomic) IBOutlet UIImageView *imageCellItem;
@property(weak, nonatomic) IBOutlet UILabel *lblTitleRegular;
@property(weak, nonatomic) IBOutlet UILabel *lblTitleBold;

@end
