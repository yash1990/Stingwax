
#import "NSDictionary-Expanded.h"

@implementation NSDictionary (NSDictionary_Expanded)

- (NSString*)getStringForKey:(NSString*)key
{
    if(isEmpty(self))
    {
        return @"";
    }
    
    NSString *value;
    id obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNumber class]])
    {
        value = [NSString stringWithFormat:@"%@", obj];
    }
    else
    {
        value = obj;
    }
    
    if(!isEmpty(value))
    {
        return value;
    }
    else
    {
        return @"";
    }
}

- (NSInteger)getIntegerForKey:(NSString*)key
{
    return [self getIntegerForKey:key defaultValue:NSNotFound];
}

- (NSInteger)getIntegerForKey:(NSString*)key defaultValue:(NSInteger)defaultValue
{
    if(isEmpty(self))
    {
        return defaultValue;
    }
    
    id obj = [self objectForKey:key];
    if(!isEmpty(obj) && [obj respondsToSelector:@selector(integerValue)])
    {
        return [obj integerValue];
    }
    else
    {
        return defaultValue;
    }
}

- (BOOL)getBoolForKey:(NSString*)key
{
    return [self getBoolForKey:key defaultValue:NO];
}

- (BOOL)getBoolForKey:(NSString*)key defaultValue:(BOOL)defaultValue
{
    if(isEmpty(self))
    {
        return defaultValue;
    }
    
    id obj = [self objectForKey:key];
    if(!isEmpty(obj) && [obj respondsToSelector:@selector(boolValue)])
    {
        return [obj boolValue];
    }
    else
    {
        return defaultValue;
    }
}

- (double)getDoubleForKey:(NSString*)key
{
    return [self getDoubleForKey:key defaultValue:DBL_MAX];
}

- (double)getDoubleForKey:(NSString*)key defaultValue:(NSInteger)defaultValue
{
    if(isEmpty(self))
    {
        return defaultValue;
    }
    
    id obj = [self objectForKey:key];
    if(!isEmpty(obj) && [obj respondsToSelector:@selector(doubleValue)])
    {
        return [obj doubleValue];
    }
    else
    {
        return defaultValue;
    }
}

- (float)getFloatForKey:(NSString*)key;
{
    return [self getFloatForKey:key defaultValue:FLT_MAX];
}

- (float)getFloatForKey:(NSString*)key defaultValue:(NSInteger)defaultValue
{
    if(isEmpty(self))
    {
        return defaultValue;
    }
    
    id obj = [self objectForKey:key];
    if(!isEmpty(obj) && [obj respondsToSelector:@selector(floatValue)])
    {
        return [obj floatValue];
    }
    else
    {
        return defaultValue;
    }
}

@end
