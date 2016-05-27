//
//  UITabBar+SWNewSize.m
//  StingWax
//
//  Created by MSPSYS129 on 06/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "UITabBar+SWNewSize.h"
#import "GBDeviceInfo.h"

@implementation UITabBar (SWNewSize)
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize;
    
    GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
    if (deviceInfo.display == GBDeviceDisplayiPhone35Inch || deviceInfo.display == GBDeviceDisplayiPhone4Inch) {
       newSize = CGSizeMake(size.width,60);
    }
    else if(deviceInfo.display == GBDeviceDisplayiPhone47Inch) {
        newSize = CGSizeMake(size.width,71);
    }
    else {
        newSize = CGSizeMake(size.width,78);
    }
    return newSize;
}
@end
