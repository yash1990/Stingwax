//
//  SWNewMixes.h
//  StingWax
//
//  Created by MSPSYS129 on 03/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWNewMixes : NSObject
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryDesc;
@property (nonatomic, strong) NSString *categoryDescLong;
@property (nonatomic, strong) UIColor *categoryColor;

@property (nonatomic) NSString *streamTitle;
@property (nonatomic) NSString *streamId;
@property (nonatomic) NSString *streamDesc;
@property (nonatomic) NSString *categoryId;
@property (nonatomic) NSString *streamIcon;
@property (nonatomic) NSString *streamArchived;
@property (nonatomic) NSString *streamUploadDate;


@property (nonatomic, strong) NSArray *streams;

+(NSArray *)modelNewMixesWithArray:(NSArray *)param error:(NSError *)error;

- (id)initWithDictionary:(NSDictionary *)dictionary;

// New Added
@property (nonatomic) BOOL isFavourite;
@property (nonatomic) NSString *isOther;
@property (nonatomic) NSMutableArray *streamList;
@property (nonatomic) double playlistDuration;
@property (nonatomic) NSInteger currentTrackNumber;
@property (nonatomic) NSTimeInterval currentTrackTime;
//

@end
