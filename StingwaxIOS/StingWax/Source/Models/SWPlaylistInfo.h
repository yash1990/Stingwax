//
//  DataPlayListInfo.h
//
//  Created by   on 6/27/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SWPlaylistInfo : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *songInfo;
@property (nonatomic, assign) double totalLength;
@property (nonatomic, strong) NSString *streamPath;

//Added (MAP)

/*
 Needed ability to gather starting points of each song within the total length..
 so when the songInfo array is set, i am calculating that and storing it into
 this array here.
 */
@property (nonatomic, strong) NSArray *songStartTimes;

+ (SWPlaylistInfo *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
