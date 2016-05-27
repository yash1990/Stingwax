//
//  SWNewMixViewController.h
//  StingWax
//
//  Created by MSPSYS129 on 17/06/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWHoneycombViewController.h"

@interface SWNewMixViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tblNewMix;
@property (nonatomic) SWHoneycombView *honeycombView;

@end
