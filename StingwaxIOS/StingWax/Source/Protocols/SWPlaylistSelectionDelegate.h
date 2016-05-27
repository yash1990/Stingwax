//
//  SWPlaylistSelectionDelegate.h
//  StingWax
//
//  Created by Tyler Prevost on 2/5/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SWPlaylist.h"

@class SWPlayerViewController;

@protocol SWPlaylistSelectionDelegate <NSObject>

- (void)viewController:(UIViewController *)controller didSelectPlayList:(SWPlaylist *)playList;
- (SWPlayerViewController *)playerViewControllerForViewController:(UIViewController *)controller;

@end
