//
//  StingwaxAuthenticationRequestSerializer.m
//  StingWax
//
//  Created by Steve Malsam on 11/21/13.
//
//

#import "SWAuthenticationRequestSerializer.h"

@implementation SWAuthenticationRequestSerializer

- (instancetype)initWithAuthToken:(NSString *)token
{
	if ((self = [super init])) {
		_authToken = token;
	}
	return self;
}

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(NSDictionary *)parameters error:(NSError * __autoreleasing *)error
{
	[self setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	// Add authentication token
    NSLog(@"Authorization:%@",self.authToken);
//    self.authToken = @"c2a7faec8bf0c3bfd1a3e431b500216a12";
	[self setValue:self.authToken forHTTPHeaderField:@"Authorization"];
	return [super requestBySerializingRequest:request withParameters:parameters error:error];
}



@end
