//
//  SWSongTableViewCell.h
//  StingWax
//
//  Created by Dhawal Dawar on 12/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWSongTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) UIView *songListCellBackgroundView;
@property (weak, nonatomic, readonly) UILabel *lblSongName;
@property (weak, nonatomic, readonly) UILabel *lblSNo;
@property (weak, nonatomic, readonly) UILabel *lblDuration;
@property (weak, nonatomic, readonly) UILabel *lblDesc;
@property (weak, nonatomic, readonly) UIActivityIndicatorView *spinner;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isLoading;

@end
