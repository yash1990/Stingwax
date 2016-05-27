//
//  DataPlaylistCategories.h
//  StingWax
//
//  Created by Steve Malsam on 11/19/13.
//
//

#import <Foundation/Foundation.h>

@interface SWPlaylistCategory : NSObject

@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryDesc;
@property (nonatomic, strong) NSString *categoryDescLong;
@property (nonatomic, strong) UIColor *categoryColor;

@property (nonatomic, strong) NSArray *streams;

+(NSArray *)modelCategoriesWithArray:(NSArray *)param error:(NSError *)error;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
