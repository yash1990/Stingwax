//
//  SWSongTableViewCell.m
//  StingWax
//
//  Created by Dhawal Dawar on 12/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SWSongTableViewCell.h"

@interface SWSongTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *songListCellBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@property (weak, nonatomic) IBOutlet UILabel *lblSNo;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end


@implementation SWSongTableViewCell

#pragma mark - Setters

- (void)setIsLoading:(BOOL)isLoading {
    _isLoading = isLoading;
    
    if (isLoading) {
        [self.spinner startAnimating];
        self.lblSNo.hidden = YES;
    }
    else {
        [self.spinner stopAnimating];
        [self setIsPlaying:self.isPlaying];
        self.lblSNo.hidden = NO;
    }
}

- (void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    
    if (isPlaying) {
        self.songListCellBackgroundView.hidden = NO;
	}
    else {
        self.songListCellBackgroundView.hidden = YES;
	}
}

#pragma mark - Object Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.exclusiveTouch = YES;
}

- (void)prepareForReuse
{
    [self setIsPlaying:NO];
    [self setIsLoading:NO];
    
    self.lblSongName.text = @"";
    self.songListCellBackgroundView.hidden = YES;
    
	[super prepareForReuse];
}


@end
