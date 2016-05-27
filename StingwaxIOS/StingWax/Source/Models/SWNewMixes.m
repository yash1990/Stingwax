//
//  SWNewMixes.m
//  StingWax
//
//  Created by MSPSYS129 on 03/07/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWNewMixes.h"
#import "SWPlaylist.h"

@implementation SWNewMixes
+ (NSArray *)modelNewMixesWithArray:(NSArray *)param error:(NSError *)error
{
    NSParameterAssert(param != nil);
    NSMutableArray *returnArray = [NSMutableArray array];
    
    /*
    NSArray *categoryIDs = [param valueForKeyPath:@"@distinctUnionOfObjects.categoryID"];
    NSPredicate *categoryIDTemplate = [NSPredicate predicateWithFormat:@"categoryID == $CAT_ID"];
    for (NSString *catID in categoryIDs) {
        NSPredicate *catIDfilter = [categoryIDTemplate predicateWithSubstitutionVariables:@{@"CAT_ID" : catID}];
        NSArray *streamsInCategory = [param filteredArrayUsingPredicate:catIDfilter];
        SWNewMixes *category;
        if (streamsInCategory.count > 0) {
            category = [[self alloc] initWithDictionary:streamsInCategory[0]];
            for (NSDictionary *streamInfo in streamsInCategory) {
                SWPlaylist *stream = [SWPlaylist modelObjectWithDictionary:streamInfo];
                category.streams = [category.streams arrayByAddingObject:stream];
            }
            //TODO: Edited By Sid
            NSArray *sortedArray = [category.streams sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [(SWPlaylist*)a streamTitle];
                NSString *second = [(SWPlaylist*)b streamTitle];
                return [first compare:second];
            }];
            category.streams = sortedArray;
            //--------------------
        }
        if (category) {
            [returnArray addObject:category];
        }
    }*/
    
    for (NSDictionary *tempDict in param) {
        SWNewMixes *category = [[self alloc] initWithDictionary:tempDict];
        [returnArray addObject:category];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //TODO: Edited By Sid
    NSArray *sortedArray = [returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(SWNewMixes*)a streamUploadDate];
        NSString *second = [(SWNewMixes*)b streamUploadDate];
        NSDate *date1 = [dateFormatter dateFromString:first];
        NSDate *date2 = [dateFormatter dateFromString:second];
        return [date1 compare:date2];
    }];
    returnArray = [sortedArray mutableCopy];
    
    //--------------------
    return returnArray;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    NSParameterAssert(dictionary != nil);
    self = [super init];
    if (self) {
        _categoryID = dictionary[@"categoryID"];
        _categoryName = dictionary[@"categoryName"];
        _categoryDesc = dictionary[@"categoryDesc"];
        _categoryDescLong = dictionary[@"categoryDescLong"];
        
        NSArray *colorComponents = dictionary[@"categoryColor"];
        _categoryColor = [UIColor colorWithRed:([colorComponents[0] intValue] / 255.0f)
                                         green:([colorComponents[1] intValue] / 255.0f)
                                          blue:([colorComponents[2] intValue] / 255.0f) alpha:1.0f];
        
        _streamId = dictionary[@"streamId"];
        _streamTitle = dictionary[@"streamTitle"];
        _streamIcon = dictionary[@"streamIcon"];
        _streamDesc = dictionary[@"streamDesc"];
        _streamArchived = dictionary[@"streamArchived"];
        _streamUploadDate = dictionary[@"streamUploadDate"];
        
        _streams = [NSArray array];
        
    }
    
    return self;
}

@end
