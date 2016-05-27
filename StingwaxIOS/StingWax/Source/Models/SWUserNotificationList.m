//
//  SWUserNotificationList.m
//  StingWax
//
//  Created by MSPSYS129 on 21/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWUserNotificationList.h"
#import "NSDictionary-Expanded.h"
#import "NSObject-Expanded.h"
#import "NSString+Utils.h"

@interface SWUserNotificationList ()

@end


@implementation SWUserNotificationList

#pragma mark - Class Methods

+ (NSArray *)modelObjectWithArray:(NSArray *)arrParams
{
    NSMutableArray *arrReturn = [[NSMutableArray alloc] init];
    for (NSDictionary *tempDict in arrParams) {
        SWUserNotificationList *notification = [[self alloc] initWithDictionary:tempDict];
        [arrReturn addObject:notification];
    }
    return [arrReturn mutableCopy];
}


- (NSString *)categoryID
{
    if (!_categoryID) {
        _categoryID = @"";
    }
    return _categoryID;
}
-(NSString *)categoryName {
    if (!_categoryName) {
        _categoryName = @"";
    }
    return _categoryName;
}
-(NSString *)Notification {
    if (!_Notification) {
        _Notification = @"";
    }
    return _Notification;
}

#pragma mark - Object Lifecycle
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        if(!isNull([dict objectForKey:@"categoryID"])) [self setCategoryID:[dict getStringForKey:@"categoryID"]];
        if(!isNull([dict objectForKey:@"categoryName"])) [self setCategoryName:[dict getStringForKey:@"categoryName"]];
        if(!isNull([dict objectForKey:@"Notification"])) [self setNotification:[dict getStringForKey:@"Notification"]];
    }
    
    return self;
}


#pragma mark - Public Methods

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.categoryID forKey:@"categoryID"];
    [mutableDict setValue:self.categoryName forKey:@"categoryName"];
    [mutableDict setValue:self.Notification forKey:@"Notification"];
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}


#pragma mark - NSCoding Methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.categoryID = [aDecoder decodeObjectForKey:@"categoryID"];
    self.categoryName = [aDecoder decodeObjectForKey:@"categoryName"];
    self.Notification = [aDecoder decodeObjectForKey:@"Notification"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_categoryID forKey:@"categoryID"];
    [aCoder encodeObject:_categoryName forKey:@"categoryName"];
    [aCoder encodeObject:_Notification forKey:@"Notification"];
}
@end
