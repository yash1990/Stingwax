//
//  SWKeepAlive.h
//  StingWax
//
//  Created by Jeffrey Berthiaume on 5/9/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWKeepAlive : NSObject

+ (void) startKeepWebSessionAlive;
+ (void) stopKeepWebSessionAlive;

@end
