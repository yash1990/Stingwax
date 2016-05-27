//
//  PurePlayViewController.h
//  StingWax
//
//  Created by Steve Malsam on 11/13/13.
//
//

#import <UIKit/UIKit.h>

#import "SWHoneycombViewController.h"
#import "SWPlayListSelectionDelegate.h"

@class SWPlayerViewController;

@interface SWPurePlayViewController : SWHoneycombViewController

@property (nonatomic, weak) id<SWPlaylistSelectionDelegate> delegate;

@end
