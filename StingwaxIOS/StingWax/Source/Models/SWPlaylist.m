//
//  DataPlayList.m
//
//  Created by   on 6/19/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "SWPlaylist.h"


@interface SWPlaylist ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end


@implementation SWPlaylist


#pragma mark - Getters
-(NSString *)streamIcon
{
    if (!_streamIcon) {
        _streamIcon = @"";
    }
    return _streamIcon;
}
- (NSString *)streamTitle
{
    if (!_streamTitle) {
        _streamTitle = @"";
    }
    return _streamTitle;
}

- (NSString *)isOther
{
    if (!_isOther) {
        _isOther = @"";
    }
    return _isOther;
}

- (NSString *)streamId
{
    if (!_streamId) {
        _streamId = @"";
    }
    return _streamId;
}

- (NSString *)streamDesc
{
    if (!_streamDesc) {
        _streamDesc = @"";
    }
    return _streamDesc;
}

-(NSString *)streamUploadDate
{
    if (!_streamUploadDate) {
        _streamUploadDate = @"";
    }
    return _streamUploadDate;
}

- (NSMutableArray *)streamList
{
    if (!_streamList) {
        _streamList = @[].mutableCopy;
    }
    return _streamList;
}

-(NSString *)streamArchived {
    if (!_streamArchived) {
        _streamArchived = @"0";
    }
    return _streamArchived;
}

- (UIColor *)colorStream
{
    if (!_colorStream) {
        _colorStream = [UIColor whiteColor];
    }
    return _colorStream;
}


#pragma mark - Class Methods

+ (SWPlaylist *)modelObjectWithDictionary:(NSDictionary *)dict
{
    SWPlaylist *instance = [[SWPlaylist alloc] initWithDictionary:dict];
    return instance;
}


#pragma mark - Object Lifecycle
- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.streamTitle = [self objectOrNilForKey:@"streamTitle" fromDictionary:dict];
        self.colorStream = [self colorFromArray:[self objectOrNilForKey:@"categoryColor" fromDictionary:dict]];
        self.streamId = [self objectOrNilForKey:@"streamId" fromDictionary:dict];
        self.streamIcon = [self objectOrNilForKey:@"streamIcon" fromDictionary:dict];
        self.streamDesc = [self objectOrNilForKey:@"streamDesc" fromDictionary:dict];
        self.streamArchived = [self objectOrNilForKey:@"streamArchived" fromDictionary:dict];
        self.streamUploadDate = [self objectOrNilForKey:@"streamUploadDate" fromDictionary:dict];
        self.categoryTitle = [self objectOrNilForKey:@"categoryName" fromDictionary:dict];
        self.categoryId = [self objectOrNilForKey:@"categoryID" fromDictionary:dict];
        self.currentTrackNumber = [[self objectOrNilForKey:@"currentTrackNumber" fromDictionary:dict] integerValue];
        self.currentTrackTime = [[self objectOrNilForKey:@"currentTrackTime" fromDictionary:dict] doubleValue];
    }

    if (self) {
        _streamList = [[NSMutableArray alloc] init];
    }

    return self;
}


#pragma mark - Public Methods

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.streamTitle forKey:@"streamTitle"];
    [mutableDict setValue:@(self.isFavourite) forKey:@"isFavourite"];
    [mutableDict setValue:[self arrayFromColor:self.colorStream] forKey:@"colorStream"];
    [mutableDict setValue:self.isOther forKey:@"isOther"];
    [mutableDict setValue:self.streamId forKey:@"streamId"];
    [mutableDict setValue:self.streamDesc forKey:@"streamDesc"];
    [mutableDict setValue:self.streamArchived forKey:@"streamArchived"];
    [mutableDict setValue:self.streamUploadDate forKey:@"streamUploadDate"];
    [mutableDict setValue:@(self.currentTrackNumber) forKey:@"currentTrackNumber"];
    [mutableDict setValue:@(self.currentTrackTime) forKey:@"currentTrackTime"];
    [mutableDict setValue:self.categoryTitle forKey:@"categoryName"];
    [mutableDict setValue:self.categoryId forKey:@"categoryId"];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}


#pragma mark - Helper Methods

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = dict[aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

- (UIColor *)colorFromArray:(NSArray *)colorArray
{
    if (colorArray.count >= 3) {
        return [UIColor colorWithRed:[colorArray[0] floatValue]/255.0
                               green:[colorArray[1] floatValue]/255.0
                                blue:[colorArray[2] floatValue]/255.0
                               alpha:(colorArray.count > 3 ? [colorArray[3] floatValue]/255.0 : 1.0)];
    }
    
    return [UIColor whiteColor];
}

- (NSArray *)arrayFromColor:(UIColor *)color
{
    if (!color) {
        return @[@255, @255, @255];
    }
    
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    return @[@(r * 255), @(g * 255), @(b * 255)];
}

- (NSData *)dataFromColor:(UIColor *)color
{
    return [NSKeyedArchiver archivedDataWithRootObject:[self arrayFromColor:color]];
}

- (UIColor *)colorFromData:(NSData *)data
{
    return [self colorFromArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.streamTitle = [aDecoder decodeObjectForKey:@"streamTitle"];
    self.isFavourite = [aDecoder decodeDoubleForKey:@"isFavourite"];
    self.colorStream = [self colorFromData:[aDecoder decodeObjectForKey:@"colorStream"]];
    self.isOther = [aDecoder decodeObjectForKey:@"isOther"];
    self.streamId = [aDecoder decodeObjectForKey:@"streamId"];
    self.streamDesc = [aDecoder decodeObjectForKey:@"streamDesc"];
    self.currentTrackNumber = [aDecoder decodeIntegerForKey:@"currentTrackNumber"];
    self.currentTrackTime = [aDecoder decodeDoubleForKey:@"currentTrackTime"];
    self.categoryTitle = [aDecoder decodeObjectForKey:@"categoryName"];
    self.categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
    self.streamArchived = [aDecoder decodeObjectForKey:@"streamArchived"];
    self.streamUploadDate = [aDecoder decodeObjectForKey:@"streamUploadDate"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_streamTitle forKey:@"streamTitle"];
    [aCoder encodeDouble:_isFavourite forKey:@"isFavourite"];
    [aCoder encodeObject:_isOther forKey:@"isOther"];
    [aCoder encodeObject:_streamId forKey:@"streamId"];
    [aCoder encodeObject:_streamDesc forKey:@"streamDesc"];
    [aCoder encodeInteger:_currentTrackNumber forKey:@"currentTrackNumber"];
    [aCoder encodeDouble:_currentTrackTime forKey:@"currentTrackTime"];
    [aCoder encodeObject:_categoryTitle forKey:@"categoryName"];
    [aCoder encodeObject:_categoryId forKey:@"categoryId"];
    [aCoder encodeObject:[self dataFromColor:_colorStream] forKey:@"colorStream"];
    [aCoder encodeObject:_streamArchived forKey:@"streamArchived"];
    [aCoder encodeObject:_streamUploadDate forKey:@"streamUploadDate"];
}

@end
