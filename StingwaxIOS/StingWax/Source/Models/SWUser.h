//
//  DataUser.h
//
//  Created by   on 6/26/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SWUser : NSObject <NSCoding>

@property (nonatomic) NSString *success;
@property (nonatomic) NSString *startDate;
@property (nonatomic) NSString *exDate;
@property (nonatomic) NSString *hourRem;
@property (nonatomic) NSString *userId;
@property (nonatomic) NSString *userType;
@property (nonatomic) NSString *subscriptionId;

+ (SWUser *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
