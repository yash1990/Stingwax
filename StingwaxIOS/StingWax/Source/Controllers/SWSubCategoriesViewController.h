//
//  SWSubCategoriesViewController.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWAppDelegate.h"
#import "SWHoneycombView.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"
#import <SVProgressHUD/SVProgressHUD.h>

#import "SWPlaylistCategory.h"
#import "SWPlayerViewController.h"

@interface SWSubCategoriesViewController : SWHoneycombViewController <SWPlayerViewControllerDelegate>{
    UINavigationController *navigaton_Player;
}

@property (weak, nonatomic) IBOutlet UILabel *lblCategories;
@property(strong, nonatomic) NSString *strCategoryType;
@property(strong, nonatomic) NSMutableArray *arrCorePlayCategory;
@property(strong, nonatomic) NSMutableArray *arrPurePlayCategory;
@property (strong, nonatomic) SWPlaylistCategory *playlistCategory;
//@property (nonatomic) SWPlayerViewController *playerViewController;

@end
