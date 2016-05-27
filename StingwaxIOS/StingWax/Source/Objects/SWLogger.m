//
//  SWLogger.m
//  StingWax
//
//  Created by Tyler Prevost on 2/21/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWLogger.h"

#import <BugSense-iOS/BugSenseController.h>

@implementation SWLogger

+ (SWLogger *)sharedLogger
{
    static SWLogger *_sharedLogger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLogger = [self new];
    });
    return _sharedLogger;
}

+ (void)logEventWithObject:(id)object selector:(SEL)selector
{
    NSString *event = [NSString stringWithFormat:@"%@ %@", object, NSStringFromSelector(selector)];
    [[self sharedLogger] logEvent:event withParameters:nil];
}

+ (void)logEvent:(NSString *)event
{
    [[self sharedLogger] logEvent:event withParameters:nil];
}

+ (void)logEvent:(NSString *)event withParameters:(NSDictionary *)params
{
    [[self sharedLogger] logEvent:event withParameters:params];
}

- (void)logEvent:(NSString *)event withParameters:(NSDictionary *)params
{
    [BugSenseController leaveBreadcrumb:event];
}

@end
