//
//  SWSocialRegistrationViewController.h
//  StingWax
//
//  Created by Sudhir Chovatiya on 3/13/16.
//  Copyright © 2016 __CompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWBaseViewController.h"

@interface SWSocialRegistrationViewController : SWBaseViewController
@property(nonatomic, strong) NSMutableDictionary *dictSocialUserData;
@property(assign) BOOL isSocialMediaFacebook;
@end
