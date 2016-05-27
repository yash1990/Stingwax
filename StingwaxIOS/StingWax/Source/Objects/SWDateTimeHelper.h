//
//  DateTime.h
//  BabyPlace
//
//  Created by Dhawal on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWDateTimeHelper : NSObject

+ (NSDate *)getConvertedDate:(NSString *)strDate;
+ (NSString *)convertTimeMinSec:(int)totSec;
+ (NSString *)convertTimeFullFormat:(int)totSec;
+ (NSString *)convertTimeMinSecWithRoundOff:(double)tSec;
+(NSDate *) getConvertedDateWithoutTime:(NSString *)strDate;
@end
