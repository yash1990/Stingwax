//
//  NSObject+AssociatedValues.m
//  StingWax
//
//  Created by Tyler Prevost on 1/28/14.
//
//

#import "NSObject+SWAssociatedValues.h"

@implementation NSObject (SWAssociatedValues)

- (void)sw_setAssociatedValue:(id)value forKey:(NSString *)key
{
    [self sw_setAssociatedValue:value forKey:key policy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (void)sw_setAssociatedValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy
{
    objc_setAssociatedObject(self, (__bridge const void *)(key), value, policy);
}

- (id)sw_associatedValueForKey:(NSString *)key
{
    return objc_getAssociatedObject(self, (__bridge const void *)(key));
}

- (void)sw_removeAssociatedValueForKey:(NSString *)key
{
    objc_setAssociatedObject(self, (__bridge const void *)(key), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)sw_removeAllAssociatedValues
{
    objc_removeAssociatedObjects(self);
}

@end
