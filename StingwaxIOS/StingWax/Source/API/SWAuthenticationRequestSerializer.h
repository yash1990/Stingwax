//
//  SWAuthenticationRequestSerializer.h
//  StingWax
//
//  Created by Steve Malsam on 11/21/13.
//
//

#import "AFURLRequestSerialization.h"

@interface SWAuthenticationRequestSerializer : AFJSONRequestSerializer

@property (nonatomic, strong) NSString *authToken;

- (instancetype)initWithAuthToken:(NSString *)token;

@end
