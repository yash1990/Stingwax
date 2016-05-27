//
//  NSString+Utils.m
//  roman_converter
//
//  Created by Kuznetsov Mikhail on 30.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
+ (BOOL)stringIsEmpty:(NSString *)string {
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (string == nil) {
        return YES;
    } 
    else if ([string length] == 0) {
        return YES;
    } 
    else {
        if ([[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
            return YES;
        }
    }
    return NO;  
}

@end
