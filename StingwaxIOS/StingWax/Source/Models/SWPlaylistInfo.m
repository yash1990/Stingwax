//
//  DataPlayListInfo.m
//
//  Created by   on 6/27/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SWPlaylistInfo.h"
#import "SWSong.h"


@interface SWPlaylistInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SWPlaylistInfo

@synthesize songInfo = _songInfo;
@synthesize totalLength = _totalLength;
@synthesize streamPath = _streamPath;
@synthesize songStartTimes = _songStartTimes;

- (NSArray *)songInfo
{
    if (!_songInfo) {
        _songInfo = @[];
    }
    return _songInfo;
}

- (NSString *)streamPath
{
    if (!_streamPath) {
        _streamPath = @"";
    }
    return _streamPath;
}

- (NSArray *)songStartTimes
{
    if (!_songStartTimes) {
        _songStartTimes = @[];
    }
    return _songStartTimes;
}

+ (SWPlaylistInfo *)modelObjectWithDictionary:(NSDictionary *)dict
{
    SWPlaylistInfo *instance = [[SWPlaylistInfo alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {

        NSObject *receivedSongInfo = dict[@"songInfo"];
        NSMutableArray *parsedSongInfo = [NSMutableArray array];

        if ([receivedSongInfo isKindOfClass:[NSArray class]]) {

            for (NSDictionary *item in (NSArray *)receivedSongInfo) {

                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedSongInfo addObject:[SWSong modelObjectWithDictionary:item]];
                }
            }

        } else if ([receivedSongInfo isKindOfClass:[NSDictionary class]]) {

            [parsedSongInfo addObject:[SWSong modelObjectWithDictionary:(NSDictionary *)receivedSongInfo]];
        }

        self.songInfo = [NSArray arrayWithArray:parsedSongInfo];
        self.totalLength = [dict[@"totalLength"] doubleValue];
        self.streamPath = [self objectOrNilForKey:@"streamPath" fromDictionary:dict];

        [self createSongStartTimes];

        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForSongInfo = [NSMutableArray array];

    for (NSObject *subArrayObject in self.songInfo) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForSongInfo addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForSongInfo addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForSongInfo] forKey:@"songInfo"];
    [mutableDict setValue:@(self.totalLength) forKey:@"totalLength"];
    [mutableDict setValue:self.streamPath forKey:@"streamPath"];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - Calculated Values
- (void) createSongStartTimes {

    NSMutableArray *calculatedStartPoints = [NSMutableArray array];

    // Check for empty values
    if ([self.songInfo count] == 0) {
        self.songStartTimes = calculatedStartPoints;
        return;
    }

    // Build startPoints.
    double timeBuilder = 0.f;
    for (SWSong *songInfo in self.songInfo) {

        [calculatedStartPoints addObject:@(timeBuilder)];
        timeBuilder += songInfo.songLength;

    }

    self.songStartTimes = [NSArray arrayWithArray:calculatedStartPoints];
    //CFShow(self.songStartTimes);
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

    self.songInfo = [aDecoder decodeObjectForKey:@"songInfo"];
    self.totalLength = [aDecoder decodeDoubleForKey:@"totalLength"];
    self.streamPath = [aDecoder decodeObjectForKey:@"streamPath"];
    self.songStartTimes = [aDecoder decodeObjectForKey:@"songStartTimes"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_songInfo forKey:@"songInfo"];
    [aCoder encodeDouble:_totalLength forKey:@"totalLength"];
    [aCoder encodeObject:_streamPath forKey:@"streamPath"];
    [aCoder encodeObject:_songStartTimes forKey:@"songStartTimes"];
}



@end
