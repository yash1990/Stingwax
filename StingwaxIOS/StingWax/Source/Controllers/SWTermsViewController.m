//
//  SWTermsViewController.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/6/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWTermsViewController.h"
#import "SWAppState.h"
#import "SWAPI.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"

#import <SVProgressHUD/SVProgressHUD.h>

@interface SWTermsViewController ()<UITabBarControllerDelegate,UITabBarDelegate>

@end

@implementation SWTermsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tabBarController.tabBar setHidden:FALSE];
     self.tabBarController.delegate = self;
}

#pragma mark - UITablebarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
        return FALSE;
    }
    return TRUE;
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyAccountURL]];
//        tabBarController.selectedIndex = 2;
    }
}

-(IBAction)btnBackPressed:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
