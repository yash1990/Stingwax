//
//  FavoritesListViewController.h
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import <UIKit/UIKit.h>

#import "SWHoneycombViewController.h"
#import "SWPlayListSelectionDelegate.h"

@interface SWFavoritesViewController : SWHoneycombViewController

@property (nonatomic, weak) id<SWPlaylistSelectionDelegate> delegate;

@end
