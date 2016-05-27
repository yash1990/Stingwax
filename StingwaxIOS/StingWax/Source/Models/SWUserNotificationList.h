//
//  SWUserNotificationList.h
//  StingWax
//
//  Created by MSPSYS129 on 21/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWUserNotificationList : NSObject

@property (nonatomic) NSString *categoryID;
@property (nonatomic) NSString *categoryName;
@property (nonatomic) NSString *Notification;

+ (NSArray *)modelObjectWithArray:(NSArray *)arrParams;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
