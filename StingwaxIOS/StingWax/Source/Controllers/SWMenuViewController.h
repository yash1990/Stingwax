//
//  SWMenuViewController.h
//  StingWax
//
//  Created by MSPSYS129 on 26/06/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWHoneycombViewController.h"
#import <QuartzCore/CoreAnimation.h>
#import "SWAppDelegate.h"
#import "SWPlaylist.h"
#import "SWPlaylistCategory.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SWMenuCell.h"

@interface SWMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    SWAppDelegate *appDelegate;
   __weak IBOutlet UITableView *tblMenu;
}

@property (nonatomic) IBOutlet SWHoneycombView *honeycombView;
@property (weak, nonatomic) IBOutlet UITableView *tblMenu;
-(IBAction)btnBackPressed:(id)sender;

@end
