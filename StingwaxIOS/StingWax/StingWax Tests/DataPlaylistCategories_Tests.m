//
//  DataPlaylistCategories_Tests.m
//  StingWax
//
//  Created by Steve Malsam on 11/19/13.
//
//

// Class under test
#import "SWPlaylistCategory.h"

// Collaborators

// Test Assistance
#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

@interface DataPlaylistCategories_Tests : XCTestCase {
	NSArray *oneStream;
}
@end

NSString *oneStreamOneCategoryJSONString = @"[\n"
		"    {\n"
		"        \"success\": \"1\",\n"
		"        \"streamInfo\": [\n"
		"            {\n"
		"                \"categoryID\": \"85\",\n"
		"                \"categoryName\": \"Hip Hop Demo\",\n"
		"                \"categoryDesc\": \"Test Hip Hop Stream\",\n"
		"                \"categoryColor\": [\n"
		"                    198,\n"
		"                    40,\n"
		"                    222\n"
		"                ],\n"
		"                \"streamId\": \"288\",\n"
		"                \"streamTitle\": \"Original Stingwax Mix\"\n"
		"            }\n"
		"        ]\n"
		"    }\n"
		"]";

NSString *twoStreamOneCategoryJSONString = @"[\n"
		"    {\n"
		"        \"success\": \"1\",\n"
		"        \"streamInfo\": [\n"
		"            {\n"
		"                \"categoryID\": \"85\",\n"
		"                \"categoryName\": \"Hip Hop Demo\",\n"
		"                \"categoryDesc\": \"Test Hip Hop Stream\",\n"
		"                \"categoryColor\": [\n"
		"                    198,\n"
		"                    40,\n"
		"                    222\n"
		"                ],\n"
		"                \"streamId\": \"288\",\n"
		"                \"streamTitle\": \"Original Stingwax Mix\"\n"
		"            },\n"
		"            {\n"
		"                \"categoryID\": \"85\",\n"
		"                \"categoryName\": \"Hip Hop Demo\",\n"
		"                \"categoryDesc\": \"Test Hip Hop Stream\",\n"
		"                \"categoryColor\": [\n"
		"                    198,\n"
		"                    40,\n"
		"                    222\n"
		"                ],\n"
		"                \"streamId\": \"333\",\n"
		"                \"streamTitle\": \"PH17IND\"\n"
		"            },"
		"        ]\n"
		"    }\n"
		"]";

NSString *twoStreamTwoCategoryJSONString = @"[\n"
		"    {\n"
		"        \"success\": \"1\",\n"
		"        \"streamInfo\": [\n"
		"            {\n"
		"                \"categoryID\": \"85\",\n"
		"                \"categoryName\": \"Hip Hop Demo\",\n"
		"                \"categoryDesc\": \"Test Hip Hop Stream\",\n"
		"                \"categoryColor\": [\n"
		"                    198,\n"
		"                    40,\n"
		"                    222\n"
		"                ],\n"
		"                \"streamId\": \"288\",\n"
		"                \"streamTitle\": \"Original Stingwax Mix\"\n"
		"            },\n"
		"            {\n"
		"                \"categoryID\": \"99\",\n"
		"                \"categoryName\": \"Music Cocktail\",\n"
		"                \"categoryDesc\": \"A Robust Blend of Categories\",\n"
		"                \"categoryColor\": [\n"
		"                    255,\n"
		"                    119,\n"
		"                    0\n"
		"                ],\n"
		"                \"streamId\": \"296\",\n"
		"                \"streamTitle\": \"MC1IND\"\n"
		"            },"
		"        ]\n"
		"    }\n"
		"]";

@implementation DataPlaylistCategories_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
	oneStream = [NSJSONSerialization JSONObjectWithData:[oneStreamOneCategoryJSONString dataUsingEncoding:NSUTF8StringEncoding]
	                                            options:0
		                                          error:nil];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
	oneStream = nil;
    [super tearDown];
}

- (void)testNilIsNotAcceptableParameter
{
	XCTAssertThrows([DataPlaylistCategories modelCategoriesWithArray:nil error:NULL], @"Lack of data should be handled elsewhere");
}

- (void)testArrayWithOneStreamReturnsOneCategory
{
	// Given
	NSArray *testStreamData = oneStream[0][@"streamInfo"];
	NSDictionary *categoryTest = testStreamData[0];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData error:NULL];

	// Then
	assertThatInteger(result.count, is(equalToInteger(1)));
}

- (void)testInitReturnsCorrectCategoryData
{
	// Given
	NSArray *testStreamData = oneStream[0][@"streamInfo"];
	NSDictionary *categoryTest = testStreamData[0];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData
	                                                             error:NULL];

	SWPlaylistCategory *categoryResult = result[0];
	// Then

	assertThat(categoryResult.categoryID, is(equalTo(categoryTest[@"categoryID"])));
	assertThat(categoryResult.categoryName, is(equalTo(categoryTest[@"categoryName"])));
	assertThat(categoryResult.categoryDesc, is(equalTo(categoryTest[@"categoryDesc"])));
	assertThatInteger(categoryResult.streams.count, is(equalToInteger(1)));
}

- (void)testInitReturnsCorrectColor
{
	// Given
	NSArray *testStreamData = oneStream[0][@"streamInfo"];
	NSDictionary *categoryTest = testStreamData[0];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData
	                                                             error:NULL];

	SWPlaylistCategory *categoryResult = result[0];

	// Then

	float testRed = [categoryTest[@"categoryColor"][0] intValue] / 255.0;
	float testGreen = [categoryTest[@"categoryColor"][1] intValue] / 255.0;
	float testBlue = [categoryTest[@"categoryColor"][2] floatValue] / 255.0;

	assertThatFloat(categoryResult.categoryColor.red, is(equalToFloat(testRed)));
	assertThatFloat(categoryResult.categoryColor.green, is(equalToFloat(testGreen)));
	assertThatFloat(categoryResult.categoryColor.blue, is(equalToFloat(testBlue)));
}

- (void)testArrayWithTwoStreamsOneCategoryReturnsOneCategory
{
	// Given
	NSArray *twoStreamsOneCategory = [NSJSONSerialization JSONObjectWithData:[twoStreamOneCategoryJSONString dataUsingEncoding:NSUTF8StringEncoding]
	                                                                 options:0
		                                                               error:nil];
	NSArray *testStreamData = twoStreamsOneCategory[0][@"streamInfo"];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData
	                                                             error:NULL];

	assertThatInteger(result.count, is(equalToInteger(1)));
}

- (void)testArrayWithTwoStreamsOneCategoryReturnsTwoStreams
{
	// Given
	NSArray *twoStreamsOneCategory = [NSJSONSerialization JSONObjectWithData:[twoStreamOneCategoryJSONString dataUsingEncoding:NSUTF8StringEncoding]
	                                                                 options:0
		                                                               error:nil];
	NSArray *testStreamData = twoStreamsOneCategory[0][@"streamInfo"];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData
	                                                             error:NULL];

	SWPlaylistCategory *categoryResult = result[0];

	assertThatInteger(categoryResult.streams.count, is(equalToInteger(2)));
}

- (void)testArrayWithTwoStreamsTwoCategoriesReturnsTwoCategories
{
	// Given
	NSArray *twoStreamsTwoCategory = [NSJSONSerialization JSONObjectWithData:[twoStreamTwoCategoryJSONString dataUsingEncoding:NSUTF8StringEncoding]
	                                                                 options:0
		                                                               error:nil];
	NSArray *testStreamData = twoStreamsTwoCategory[0][@"streamInfo"];

	// When
	NSArray *result = [SWPlaylistCategory modelCategoriesWithArray:testStreamData
	                                                             error:NULL];

	assertThatInteger(result.count, is(equalToInteger(2)));
}

@end
