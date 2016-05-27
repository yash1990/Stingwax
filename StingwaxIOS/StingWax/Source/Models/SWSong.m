//
//  SongInfo.m
//
//  Created by   on 6/27/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SWSong.h"


@interface SWSong ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SWSong

+ (SWSong *)modelObjectWithDictionary:(NSDictionary *)dict
{
    SWSong *instance = [[SWSong alloc] initWithDictionary:dict];
    return instance;
}


#pragma mark - Getters

- (NSString *)songArtist
{
    if (!_songArtist) {
        _songArtist = @"";
    }
    return _songArtist;
}

- (NSString *)songStream
{
    if (!_songStream) {
        _songStream = @"";
    }
    return _songStream;
}

- (NSString *)songTitle
{
    if (!_songTitle) {
        _songTitle = @"";
    }
    return _songTitle;
}

- (NSString *)songISRC
{
    if (!_songISRC) {
        _songISRC = @"";
    }
    return _songISRC;
}

- (NSString *)songLabel
{
    if (!_songLabel) {
        _songLabel = @"";
    }
    return _songLabel;
}


#pragma mark - Object Lifecycle

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        self.songArtist = [self objectOrNilForKey:@"songArtist" fromDictionary:dict];
        self.songLength = [dict[@"songLength"] doubleValue];
        self.songStream = [self objectOrNilForKey:@"songStream" fromDictionary:dict];
        self.songTitle = [self objectOrNilForKey:@"songTitle" fromDictionary:dict];
        self.songISRC = [self objectOrNilForKey:@"songISRC" fromDictionary:dict];
        self.songLabel = [self objectOrNilForKey:@"songLabel" fromDictionary:dict];
    }
    
    return self;
}


#pragma mark - Public Methods

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.songArtist forKey:@"songArtist"];
    [dict setValue:@(self.songLength) forKey:@"songLength"];
    [dict setValue:self.songStream forKey:@"songStream"];
    [dict setValue:self.songTitle forKey:@"songTitle"];
    [dict setValue:self.songISRC forKey:@"songISRC"];
    [dict setValue:self.songLabel forKey:@"songLabel"];
    return [NSDictionary dictionaryWithDictionary:dict];
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

    self.songArtist = [aDecoder decodeObjectForKey:@"songArtist"];
    self.songLength = [aDecoder decodeDoubleForKey:@"songLength"];
    self.songStream = [aDecoder decodeObjectForKey:@"songStream"];
    self.songTitle = [aDecoder decodeObjectForKey:@"songTitle"];
	self.songISRC = [aDecoder decodeObjectForKey:@"songISRC"];
	self.songLabel = [aDecoder decodeObjectForKey:@"songLabel"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_songArtist forKey:@"songArtist"];
    [aCoder encodeDouble:_songLength forKey:@"songLength"];
    [aCoder encodeObject:_songStream forKey:@"songStream"];
    [aCoder encodeObject:_songTitle forKey:@"songTitle"];
	[aCoder encodeObject:_songISRC forKey:@"songISRC"];
	[aCoder encodeObject:_songLabel forKey:@"songLabel"];
}

@end
