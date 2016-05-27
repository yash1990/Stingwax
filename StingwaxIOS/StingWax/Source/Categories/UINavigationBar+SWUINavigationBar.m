//
//  UINavigationBar+SWUINavigationBar.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/29/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "UINavigationBar+SWUINavigationBar.h"
#import "GBDeviceInfo.h"

@implementation UINavigationBar (SWUINavigationBar)

- (CGSize)sizeThatFits:(CGSize)size {
    GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
    
    CGRect rec = self.frame;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    rec.size.width = screenRect.size.width;
    if (deviceInfo.display == GBDeviceDisplayiPhone35Inch || deviceInfo.display == GBDeviceDisplayiPhone4Inch) {
        rec.size.height = 48;
    }
    else if(deviceInfo.display == GBDeviceDisplayiPhone47Inch) {
        rec.size.height = 56;
    }
    else {
        rec.size.height = 62;
    }
    
    return rec.size;
}

@end
