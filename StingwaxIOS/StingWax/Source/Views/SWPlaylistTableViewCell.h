//
//  SWPlaylistTableViewCell.h
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SWPlaylistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lbldesc;
@property (weak, nonatomic) IBOutlet UIImageView *hexView;
@property (nonatomic) UIColor *color;

@end
