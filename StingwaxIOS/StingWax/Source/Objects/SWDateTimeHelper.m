//
//  DateTime.m
//  BabyPlace
//
//  Created by Dhawal on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SWDateTimeHelper.h"

@implementation SWDateTimeHelper

+(NSDate *) getConvertedDate:(NSString *)strDate{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
	[format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
	[format setTimeZone:[NSTimeZone systemTimeZone]];
	NSDate *sourceDate=[format dateFromString:strDate];
    
    NSLog(@"%@",[format stringFromDate:sourceDate]);
    
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    return [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
}

+(NSString *) getConvertedDateWithoutTime:(NSString *)strDate{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *sourceDate=[format dateFromString:strDate];
    
    [format setDateFormat:@"dd/MM/yyyy"];
    NSString *strNewdate = [format stringFromDate:sourceDate];
    return strNewdate;
}

+(NSString *)convertTimeMinSec:(int)totSec{
    int min=totSec/60;//759.478  12
	int sec=totSec-(min*60);
	NSString *digitSec=[NSString stringWithFormat:@"%d",sec];
	if([digitSec length]==1){
		digitSec=[@"0" stringByAppendingFormat:@"%@",digitSec];
	}
	NSString *digitMin=[NSString stringWithFormat:@"%d",min];
	if([digitMin length]==1){
		digitMin=[@"0" stringByAppendingFormat:@"%@",digitMin];
	}
	return [NSString stringWithFormat:@"%@:%@",digitMin,digitSec];
}

+(NSString *)convertTimeFullFormat:(int)totSec{
	int hours = (totSec / 3600);
	int min = (totSec / 60)-(hours * 60);
	int sec = totSec%60;
	
	NSString *digitHour=[NSString stringWithFormat:@"%d",hours];
	if([digitHour length]==1){
		digitHour=[@"0" stringByAppendingFormat:@"%@",digitHour];
	}
	NSString *digitMin=[NSString stringWithFormat:@"%d",min];
	if([digitMin length]==1){
		digitMin=[@"0" stringByAppendingFormat:@"%@",digitMin];
	}
	NSString *digit=[NSString stringWithFormat:@"%d",sec];
	if([digit length]==1){
		digit=[@"0" stringByAppendingFormat:@"%@",digit];
	}
	return [NSString stringWithFormat:@"%@:%@:%@",digitHour,digitMin,digit];
}

+(NSString *)convertTimeMinSecWithRoundOff:(double)tSec{
	int totSec=(int)tSec;
    int miliSec=round(tSec)-totSec;
    int min=totSec/60;
	int sec=totSec-(min*60)+miliSec;
	NSString *digitSec=[NSString stringWithFormat:@"%d",sec];
	if([digitSec length]==1){
		digitSec=[@"0" stringByAppendingFormat:@"%@",digitSec];
	}
	NSString *digitMin=[NSString stringWithFormat:@"%d",min];
	if([digitMin length]==1){
		digitMin=[@"0" stringByAppendingFormat:@"%@",digitMin];
	}
	return [NSString stringWithFormat:@"%@:%@",digitMin,digitSec];
}
@end
