//
//  SongInfo.h
//
//  Created by   on 6/27/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface SWSong : NSObject <NSCoding>

@property (nonatomic) NSString *songArtist;
@property (nonatomic) double songLength;
@property (nonatomic) NSString *songStream;
@property (nonatomic) NSString *songTitle;
@property (nonatomic) NSString *songISRC;
@property (nonatomic) NSString *songLabel;

+ (SWSong *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
