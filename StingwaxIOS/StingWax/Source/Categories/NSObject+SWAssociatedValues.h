//
//  NSObject+AssociatedValues.h
//  StingWax
//
//  Created by Tyler Prevost on 1/28/14.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (SWAssociatedValues)

- (void)sw_setAssociatedValue:(id)value forKey:(NSString *)key;
- (void)sw_setAssociatedValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy;
- (id)sw_associatedValueForKey:(NSString *)key;
- (void)sw_removeAssociatedValueForKey:(NSString *)key;
- (void)sw_removeAllAssociatedValues;

@end
