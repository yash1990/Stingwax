//
//  Helper.m
//  StingWax
//
//  Created by Mark Perkins on 6/17/13.
//
//

#import "SWHelper.h"

#import "StingWax-Keys.h"

@implementation SWHelper


#pragma mark - User Defaults
+ (id)getUserValueForKey:(NSString*)aKey
{
    id result = [[NSUserDefaults standardUserDefaults] stringForKey:aKey];
    if (result == nil || [result isEqualToString:@""]) {
        //DEFAULT VALUES FOR PROPERTIES
        NSMutableDictionary *myDefaultValues = [[NSMutableDictionary alloc] init];
        
        //Add all default values to dictionary
        [myDefaultValues setValue:@NO forKey:kIsUserRemembered];
        [myDefaultValues setValue:@"" forKey:kUserNameValue];
        [myDefaultValues setValue:@"" forKey:kPasswordValue];
        
        //doesn't exist, so we set to default
        [self setUserValue:[myDefaultValues valueForKey:aKey] forKey:aKey];
    }
    return [[NSUserDefaults standardUserDefaults] objectForKey: aKey];
}

+ (void)setUserValue:(id)aValue forKey:(NSString*)aKey
{
    [[NSUserDefaults standardUserDefaults] setObject:aValue forKey:aKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeKey:(NSString*)aKey {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:aKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Conversions
+ (NSNumber *)stringToNumber:(NSString *)theString
{
    NSNumberFormatter *numberFormatter	= [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [numberFormatter numberFromString:theString];
    return number;
}

+ (NSString *)numberToString:(NSNumber *)theNumber
{
    NSString *aString = [theNumber stringValue];
    return aString;
}


#pragma mark - Utility Methods
+ (BOOL)doWeHaveInternetConnection
{
    Reachability *internetReach;
    /*if (internetReach != nil) {
     [internetReach autorelease];
     }*/
    internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            return NO;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            return YES;
    }
}

#pragma mark - Logging Helpers

+ (void)logPrintRect:(CGRect)_aRect withPropertyName:(NSString *)_propertyName
{
    NSLog(@"CGRect: %@ | x:%f, y:%f, w:%f, h:%f",_propertyName,_aRect.origin.x,_aRect.origin.y,_aRect.size.width,_aRect.size.height);
}

+ (void)logPrintPoint:(CGPoint)_aPoint withPropertyName:(NSString *)_propertyName
{
    NSLog(@"CGPoint: %@ | x:%f, y:%f",_propertyName,_aPoint.x,_aPoint.y);
}

+ (void)logPrintSize:(CGSize)_aSize withPropertyName:(NSString *)_propertyName
{
    NSLog(@"CGSize: %@ CGSize | width:%f, height:%f",_propertyName,_aSize.width,_aSize.height);
}

@end
