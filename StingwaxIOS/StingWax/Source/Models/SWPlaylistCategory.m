//
//  DataPlaylistCategories.m
//  StingWax
//
//  Created by Steve Malsam on 11/19/13.
//
//

#import "SWPlaylistCategory.h"

#import "SWPlaylist.h"


@implementation SWPlaylistCategory

+ (NSArray *)modelCategoriesWithArray:(NSArray *)param error:(NSError *)error
{
	NSParameterAssert(param != nil);
	NSMutableArray *returnArray = [NSMutableArray array];
	NSArray *categoryIDs = [param valueForKeyPath:@"@distinctUnionOfObjects.categoryID"];
	NSPredicate *categoryIDTemplate = [NSPredicate predicateWithFormat:@"categoryID == $CAT_ID"];
	for (NSString *catID in categoryIDs) {
		NSPredicate *catIDfilter = [categoryIDTemplate predicateWithSubstitutionVariables:@{@"CAT_ID" : catID}];
		NSArray *streamsInCategory = [param filteredArrayUsingPredicate:catIDfilter];
        SWPlaylistCategory *category;
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
	}
    
    //TODO: Edited By Sid
    NSArray *sortedArray = [returnArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(SWPlaylistCategory*)a categoryName];
        NSString *second = [(SWPlaylistCategory*)b categoryName];
        return [first compare:second];
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
		_streams = [NSArray array];
	}

	return self;
}

@end
