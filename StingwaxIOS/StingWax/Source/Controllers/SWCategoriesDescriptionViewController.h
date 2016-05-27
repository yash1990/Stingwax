//
//  SWCategoriesDescriptionViewController.h
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWHoneycombView.h"

@interface SWCategoriesDescriptionViewController : UIViewController
{
    UINavigationController *navigaton_Player;
}
@property(strong, nonatomic) NSMutableArray *arrCoreCategory;
@property(strong, nonatomic) NSMutableArray *arrPurePlayCategory;
@property(strong, nonatomic) NSArray *arrPlistCategory;
@property(strong, nonatomic) SWHoneycombView *honeycombView;
@end
