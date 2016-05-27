

#import <Foundation/Foundation.h>
#import "NSObject-Expanded.h"

@interface NSDictionary (NSDictionary_Expanded)

- (NSString*)getStringForKey:(NSString*)key;
- (NSInteger)getIntegerForKey:(NSString*)key;
- (NSInteger)getIntegerForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
- (BOOL)getBoolForKey:(NSString*)key;
- (BOOL)getBoolForKey:(NSString*)key defaultValue:(BOOL)defaultValue;
- (double)getDoubleForKey:(NSString*)key;
- (double)getDoubleForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;
- (float)getFloatForKey:(NSString*)key;
- (float)getFloatForKey:(NSString*)key defaultValue:(NSInteger)defaultValue;

@end
