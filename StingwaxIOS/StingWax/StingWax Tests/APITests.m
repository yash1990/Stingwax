//
//  APITests.m
//  StingWax
//
//  Created by Steve Malsam on 11/18/13.
//
//

// Class Under Test
#import "SWAPI.h"

// Collaborators

// Test Support
#import <XCTest/XCTest.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
//#import "Nocilla.h"
//#import "StingwaxApiConnection.h"
#import "OHHTTPStubs.h"

//// Expose private interface for testing
//@interface StingwaxApiConnection(testing)
//
//- (AFHTTPRequestOperation *)operationWithParams:(NSDictionary *)params onCompletion:(ArrayResponseBlock)completion;
//
//@end

@interface APITests : XCTestCase

@end

@implementation APITests

NSString *logOnUserJSONString = @"[\n"
		"    {\n"
		"        \"success\": \"1\",\n"
		"        \"error\": \"Your subscription has expired.\",\n"
		"        \"userId\": \"438\",\n"
		"        \"userType\": \"4\",\n"
		"        \"hourRem\": \"175057\",\n"
		"        \"startDate\": \"2013-11-14 07:53:57\",\n"
		"        \"exDate\": \"2013-11-15 15:28:55\"\n"
		"    }\n"
		"]";

NSString *testUserID = @"438";

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.

	[super tearDown];
}

//- (void)testLogingInSendsCorrectParams
//{
//	// Given
//	StingwaxApiConnection *sut = [StingwaxApiConnection sharedInstance];
//	NSString *userID = @"jleidigh";
//	NSString *password = @"Guada123";
//
//	id sutMock = [OCMockObject partialMockForObject:sut];
//
//	[[sutMock expect] operationWithParams:[OCMArg checkWithBlock:^BOOL(id obj) {
//		NSDictionary *params = obj;
//		if (![params[@"methodIdentifier"] isEqualToString:@"getLoggedIn"])
//			return NO;
//		if (![params[@"userName"] isEqualToString:userID])
//			return NO;
//		if (![params[@"password"] isEqualToString:password])
//			return NO;
//
//		return YES;
//	}] onCompletion:[OCMArg any]];
//
//	// When
//	[sut logOnUser:userID
//	  withPassword:password
//	 andCompletion:nil];
//
//	// Then
//	[sutMock verify];
//}
//
//- (void)testLogOnUserCallsBlockForSuccessfulRequest
//{
//	// Given
//	StingwaxApiConnection *sut = [StingwaxApiConnection sharedInstance];
//	NSString *userID = @"jleidigh";
//	NSString *password = @"Guada123";
//
//	id sutMock = [OCMockObject partialMockForObject:sut];
//
//	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
//		return YES;
//	} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
//		return [OHHTTPStubsResponse responseWithData:[logOnUserJSONString dataUsingEncoding:NSUTF8StringEncoding]
//                                          statusCode:200
//                                             headers:nil];
//	}];
//
//	// When
//	[sut logOnUser:userID
//	  withPassword:password
//	 andCompletion:^(SWUser *user, NSError *error) {
//		 assertThat(user, is(notNilValue()));
//	 }];
//}

@end
