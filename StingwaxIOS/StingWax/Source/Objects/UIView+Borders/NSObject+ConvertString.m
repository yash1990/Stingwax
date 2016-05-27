//
//  NSObject+ConvertString.m
//  EssentialWatches
//
//  Created by __DeveloperName__ on 12/12/14.
//  Copyright (c) 2014 __CompanyName__. All rights reserved.
//

#import "NSObject+ConvertString.h"

@implementation NSObject (ConvertString)

-(NSString *)objectToString
{
    NSString *responseString;

    if ([self isKindOfClass:[NSNull class]] || [self isEqual:@"null"] || [self isEqual:@"NULL"] || [self isEqual:@"nil"] || [self isEqual:@"<null>"] || [self isEqual:@"(null)"]) {
        responseString = [NSString stringWithFormat:@""];
    }
    else{
        responseString = [NSString stringWithFormat:@"%@",self];
    }
    return responseString;
}

-(NSInteger)objectToNSInteger
{
    NSInteger resposneInteger = 0;
    if ([self isKindOfClass:[NSNull class]] || [self isEqual:@"null"] || [self isEqual:@"NULL"] || [self isEqual:@"nil"] || [self isEqual:@"<null>"] || [self isEqual:@"(null)"]) {
        resposneInteger = 0;
    }
    else
    {
        resposneInteger = [(NSNumber *)self integerValue];
    }
    return resposneInteger;
}
@end
