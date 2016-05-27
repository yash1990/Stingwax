//
//  DataPlayList.h
//
//  Created by   on 6/19/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SWPlaylist : NSObject <NSCoding>

@property (nonatomic) NSString *streamTitle;
@property (nonatomic) BOOL isFavourite;
@property (nonatomic) UIColor *colorStream;
@property (nonatomic) NSString *isOther;
@property (nonatomic) NSString *streamId;
@property (nonatomic) NSString *streamDesc;
@property (nonatomic) NSString *categoryTitle;
@property (nonatomic) NSString *categoryId;
@property (nonatomic) NSString *streamIcon;
@property (nonatomic) NSString *streamArchived;
@property (nonatomic) NSString *streamUploadDate;

// these 2 below are optional properties and were added to support
// the currentPlaylist Variable
@property (nonatomic) NSMutableArray *streamList;
@property (nonatomic) double playlistDuration;

@property (nonatomic) NSInteger currentTrackNumber;
@property (nonatomic) NSTimeInterval currentTrackTime;

+ (SWPlaylist *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
