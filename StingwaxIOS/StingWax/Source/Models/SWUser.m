//
//  DataUser.m
//
//  Created by   on 6/26/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SWUser.h"


@interface SWUser ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SWUser

#pragma mark - Getters

- (NSString *)success
{
    if (!_success) {
        _success = @"";
    }
    return _success;
}

- (NSString *)startDate
{
    if (!_startDate) {
        _startDate = @"";
    }
    return _startDate;
}

- (NSString *)exDate
{
    if (!_exDate) {
        _exDate = @"";
    }
    return _exDate;
}

- (NSString *)hourRem
{
    if (!_hourRem) {
        _hourRem = @"";
    }
    return _hourRem;
}

- (NSString *)userId
{
    if (!_userId) {
        _userId = @"";
    }
    return _userId;
}

- (NSString *)userType
{
    if (!_userType) {
        _userType = @"";
    }
    return _userType;
}

- (NSString *)subscriptionId
{
    if (!_subscriptionId) {
        _subscriptionId = @"";
    }
    return _subscriptionId;
}


#pragma mark - Class Methods

+ (SWUser *)modelObjectWithDictionary:(NSDictionary *)dict
{
    SWUser *instance = [[SWUser alloc] initWithDictionary:dict];
    return instance;
}


#pragma mark - Object Lifecycle

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.success = [self objectOrNilForKey:@"success" fromDictionary:dict];
        self.startDate = [self objectOrNilForKey:@"startDate" fromDictionary:dict];
        self.exDate = [self objectOrNilForKey:@"exDate" fromDictionary:dict];
        self.hourRem = [self objectOrNilForKey:@"hourRem" fromDictionary:dict];
        self.userId = [self objectOrNilForKey:@"userId" fromDictionary:dict];
        self.userType = [self objectOrNilForKey:@"userType" fromDictionary:dict];
        self.subscriptionId = [self objectOrNilForKey:@"subscriptionId" fromDictionary:dict];
    }
    
    return self;
}


#pragma mark - Public Methods

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.success forKey:@"success"];
    [mutableDict setValue:self.startDate forKey:@"startDate"];
    [mutableDict setValue:self.exDate forKey:@"exDate"];
    [mutableDict setValue:self.hourRem forKey:@"hourRem"];
    [mutableDict setValue:self.userId forKey:@"userId"];
    [mutableDict setValue:self.userType forKey:@"userType"];
    [mutableDict setValue:self.subscriptionId forKey:@"subscriptionId"];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}


#pragma mark - Helper Method

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = dict[aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.success = [aDecoder decodeObjectForKey:@"success"];
    self.startDate = [aDecoder decodeObjectForKey:@"startDate"];
    self.exDate = [aDecoder decodeObjectForKey:@"exDate"];
    self.hourRem = [aDecoder decodeObjectForKey:@"hourRem"];
    self.userId = [aDecoder decodeObjectForKey:@"userId"];
    self.userType = [aDecoder decodeObjectForKey:@"userType"];
    self.subscriptionId = [aDecoder decodeObjectForKey:@"subscriptionId"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_success forKey:@"success"];
    [aCoder encodeObject:_startDate forKey:@"startDate"];
    [aCoder encodeObject:_exDate forKey:@"exDate"];
    [aCoder encodeObject:_hourRem forKey:@"hourRem"];
    [aCoder encodeObject:_userId forKey:@"userId"];
    [aCoder encodeObject:_userType forKey:@"userType"];
    [aCoder encodeObject:_subscriptionId forKey:@"subscriptionId"];
}

@end
