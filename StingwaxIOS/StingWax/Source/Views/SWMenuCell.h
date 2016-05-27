//
//  SWMenuCell.h
//  StingWax
//
//  Created by MSPSYS129 on 17/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SWMenuCellDelegate;

@interface SWMenuCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *lblMenuName;
@property(weak, nonatomic) IBOutlet UILabel *lblCategoryName;
@property(weak, nonatomic) IBOutlet UISwitch *switchONOFF;
@property (strong, nonatomic) id <SWMenuCellDelegate> delegate;
-(IBAction)switchCellONOFFPressed:(id)sender;
@end

@protocol SWMenuCellDelegate <NSObject>

-(void)switchONOFFPressed:(id)sender;
@end