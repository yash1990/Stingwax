//
//  SWLogger.h
//  StingWax
//
//  Created by Tyler Prevost on 2/21/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWLogger : NSObject

+ (void)logEventWithObject:(id)object selector:(SEL)selector;
+ (void)logEvent:(NSString *)event;
+ (void)logEvent:(NSString *)event withParameters:(NSDictionary *)params;

@end
