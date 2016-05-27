//
//  SWPlaylistsViewController.h
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.c
//

#import <UIKit/UIKit.h>
#import "SWHoneycombViewController.h"
// Frameworks
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
#import "SWAppDelegate.h"

// Controllers
#import "SWPlayerViewController.h"
#import "SWFavoritesViewController.h"
#import "SWPurePlayViewController.h"
#import "SWCategoriesDescriptionViewController.h"

// Views
#import "SWHoneycombView.h"
#import "SWPlaylistTableViewCell.h"
#import "SWSongTableViewCell.h"
#import "SWCategoryCollectionViewCell.h"
#import "SWCollectionHeaderReusableView.h"

// Other things
#import "SWPlaylist.h"
#import "SWPlaylistCategory.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SWPlaylistsViewController : SWHoneycombViewController{
    UINavigationController *navigaton_Player;
}

@end
