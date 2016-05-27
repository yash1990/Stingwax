//
//  Helper.h
//  StingWax
//
//  Created by Mark Perkins on 6/17/13.
//
//

#import <Foundation/Foundation.h>

#import "Reachability.h"


@interface SWHelper : NSObject

#pragma mark - User Defaults
/**
 * Method name: getUserValueForKey
 * Description: Helper method for retrieving data in the User Defaults (preferences) for retrieval, 
                and establishes any default values those preferences have.
 */
+ (id)getUserValueForKey:(NSString*)aKey;

/**
 * Method name: setUserValue
 * Description: Helper method for setting a value in the user defaults.
 */
+ (void)setUserValue:(id)aValue forKey:(NSString*)aKey;

+ (void)removeKey:(NSString*)aKey;


#pragma mark - Conversions
+ (NSNumber *)stringToNumber:(NSString *)theString;
+ (NSString *)numberToString:(NSNumber *)theNumber;


#pragma mark - Utility Methods
/**
 * Method name: doWeHaveInternetConnection
 * Description: Uses Reachability to determine internet connectivity at the time 
                the method is called.  Returns boolean of YES it is, or NO it isn't
 */
+ (BOOL)doWeHaveInternetConnection;


#pragma mark - Logging Helper Methods
+ (void)logPrintRect:(CGRect)_aRect withPropertyName:(NSString *)_propertyName;
+ (void)logPrintPoint:(CGPoint)_aPoint withPropertyName:(NSString *)_propertyName;
+ (void)logPrintSize:(CGSize)_aSize withPropertyName:(NSString *)_propertyName;


@end
