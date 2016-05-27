//
//  StingWaxAppDelegate.h
//  StingWax
//
//  Created by Dhawal Dawar on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// http://install.diawi.com/U3PFYm

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
@class GTMOAuth2Authentication;


@interface SWAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong ,nonatomic) UINavigationController *Tab0NavBarcontroller;
@property (strong ,nonatomic) UITabBarController *mainTabBarcontroller;
@property (strong , nonatomic) NSDictionary *myLaunchOptions;
+ (SWAppDelegate *)sharedDelegate;
+(UILabel *)fixWidthAndAnyHeightOfThisLabel:(UILabel *)aLabel;
+(CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;
+(UILabel *)fixHeightAndAnyWidthOfThisLabel:(UILabel *)aLabel;
+(CGFloat)widthOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;

-(void)registerForPushNotification;
-(void)setBadgeNumberForTabItemIndex:(NSInteger )item;
@end
