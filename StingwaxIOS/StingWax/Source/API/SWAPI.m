//
//  API.m
//  StingWax
//
//  Created by Mark Perkins on 6/20/13.
//
//

#import "SWAPI.h"
#import "SWPlaylist.h"
#import "SWPlaylistCategory.h"
#import "SWNewMixes.h"
#import "SWUserNotificationList.h"
#import "SWAuthenticationRequestSerializer.h"
#import "SWAppState.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "StingWax-Constant.h"
#define kAPIHost @"https://stingwax.com"
#define kAPIPath @"api/api2.php"
#define kAPIPathFull @"https://stingwax.com/api/api2.php"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@interface SWAPI ()
@property (copy, nonatomic) void(^loginBlock)(void);
@property (copy, nonatomic) void(^logoutBlock)(void);
@end


@implementation SWAPI
@synthesize validSession = _validSession;
#pragma mark - Singleton methods
+ (SWAPI*)sharedAPI
{
    static SWAPI *_sharedInstance;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIHost]];
    });
    return _sharedInstance;
}

#pragma mark - init
//intialize the API class with the destination host name
- (SWAPI *)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        _validSession = NO;
    }
    return self;
}

- (void)postInvalidSessionNotification:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:sender];
}


- (NSError *)getError:(NSDictionary *)dataDictionary
{
    NSError *newError = nil;
    NSString *localizedDescriptionKey = @"An unknown error has occured.";
    if (dataDictionary[@"error"]) {
        localizedDescriptionKey = dataDictionary[@"error"];
    }
    newError = [NSError errorWithDomain:SWAPIErrorDomain
                                   code:[dataDictionary[@"success"] intValue]
                               userInfo:@{
                                          NSLocalizedDescriptionKey : localizedDescriptionKey
                                          }];
    return newError;
}

// Used to retrive information from the server via posting
- (void)commandWithParams:(NSDictionary *)params onCompletion:(void (^)(AFHTTPRequestOperation *, id ))completionBlock onFailure:(FailureResponseBlock)failureBlock
{
    [self POST:kAPIPath parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {
    
    }
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           completionBlock(operation, responseObject);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           failureBlock(error);
       }];
}


#pragma mark - New User Registration
- (void)logInWithNewUserData:(NSDictionary *)userData completion:(DataUserResponseBlock)completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager POST:kAPIPathFull parameters:userData success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSDictionary *dataDictionary = responseObject[0];
        //check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            NSDictionary *headers = operation.response.allHeaderFields;
            NSString *authToken = headers[@"Authentication"];
            [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kLastAuthToken];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SWAuthenticationRequestSerializer *serializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:authToken];
            [self setRequestSerializer:serializer];
            self.validSession = YES;
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsCurrentUserLoggedIn];
            completionBlock([SWUser modelObjectWithDictionary:dataDictionary], nil);
        }
        else {
            // request was unsuccessful
            NSError *newError;
            @try {
                if ([dataDictionary[@"result"] isEqualToString:@"111"]) {
                  newError =  [NSError errorWithDomain:SWAPIErrorDomain
                                        code:111
                                    userInfo:@{
                                               NSLocalizedDescriptionKey : dataDictionary[@"message"]
                                               }];
                }
                else {
                    newError = [self getError:dataDictionary];
                }
            }
            @catch (NSException *exception) {
                newError = [self getError:dataDictionary];
            }

            completionBlock(nil, newError);
        }

    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completionBlock(nil, error);
    }];
}


#pragma mark - User (login/logout/session)
- (void)logInWithUserID:(NSString *)userId password:(NSString *)password completion:(DataUserResponseBlock)completionBlock
{
    
    SWAPI * __weak weakSelf = self;
    self.loginBlock = ^{
        SWAPI * __strong self = weakSelf;
        NSDictionary *dict = @{@"methodIdentifier": @"getLoggedIn", @"email": userId, @"password": password};
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData };
        [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
            NSDictionary *dataDictionary = data[0];
            //check data for success or error
            if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
                NSDictionary *headers = op.response.allHeaderFields;
                NSString *authToken = headers[@"Authentication"];
                [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kLastAuthToken];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                SWAuthenticationRequestSerializer *serializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:authToken];
                [self setRequestSerializer:serializer];
                self.validSession = YES;
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsCurrentUserLoggedIn];
                completionBlock([SWUser modelObjectWithDictionary:dataDictionary], nil);
            }
            else {
                // request was unsuccessful
                NSError *newError = [self getError:dataDictionary];
                completionBlock(nil, newError);
            }
            self.loginBlock = nil;
            if (self.logoutBlock) {
                self.logoutBlock();
            }
        } onFailure:^(NSError *responseError) {
            //request was unsuccessful
            NSLog(@"Request error details: %@",responseError.localizedDescription);
            completionBlock(nil, responseError);
            self.loginBlock = nil;
            self.logoutBlock = nil;
        }];
    };
    
    if (!self.logoutBlock) {
        self.loginBlock();
    }
}

#pragma mark - Facebook User (login/logout/session)
- (void)logInWithFBWithUserID:(NSString *)userId completion:(DataUserResponseBlock)completionBlock
{
    
    SWAPI * __weak weakSelf = self;
    self.loginBlock = ^{
        SWAPI * __strong self = weakSelf;
        NSDictionary *dict = @{@"methodIdentifier": @"getLoggedInFB", @"fbid": userId};
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData };
        [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
            NSDictionary *dataDictionary = data[0];
            //check data for success or error
            if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
                NSDictionary *headers = op.response.allHeaderFields;
                NSString *authToken = headers[@"Authentication"];
                [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kLastAuthToken];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                SWAuthenticationRequestSerializer *serializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:authToken];
                [self setRequestSerializer:serializer];
                self.validSession = YES;
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsCurrentUserLoggedIn];
                completionBlock([SWUser modelObjectWithDictionary:dataDictionary], nil);
            }
            else {
                // request was unsuccessful
                NSError *newError = [self getError:dataDictionary];
                completionBlock(nil, newError);
            }
            self.loginBlock = nil;
            if (self.logoutBlock) {
                self.logoutBlock();
            }
        } onFailure:^(NSError *responseError) {
            //request was unsuccessful
            NSLog(@"Request error details: %@",responseError.localizedDescription);
            completionBlock(nil, responseError);
            self.loginBlock = nil;
            self.logoutBlock = nil;
        }];
    };
    
    if (!self.logoutBlock) {
        self.loginBlock();
    }
}

#pragma mark - Twitter User (login/logout/session)
- (void)logInWithTWWithUserID:(NSString *)userId completion:(DataUserResponseBlock)completionBlock
{
    
    SWAPI * __weak weakSelf = self;
    self.loginBlock = ^{
        SWAPI * __strong self = weakSelf;
        NSDictionary *dict = @{@"methodIdentifier": @"getLoggedInTW", @"twid": userId};
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData };
        [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
            NSDictionary *dataDictionary = data[0];
            //check data for success or error
            if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
                NSDictionary *headers = op.response.allHeaderFields;
                NSString *authToken = headers[@"Authentication"];
                [[NSUserDefaults standardUserDefaults] setObject:authToken forKey:kLastAuthToken];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                SWAuthenticationRequestSerializer *serializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:authToken];
                [self setRequestSerializer:serializer];
                self.validSession = YES;
                [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsCurrentUserLoggedIn];
                completionBlock([SWUser modelObjectWithDictionary:dataDictionary], nil);
            }
            else {
                // request was unsuccessful
                NSError *newError = [self getError:dataDictionary];
                completionBlock(nil, newError);
            }
            self.loginBlock = nil;
            if (self.logoutBlock) {
                self.logoutBlock();
            }
        } onFailure:^(NSError *responseError) {
            //request was unsuccessful
            NSLog(@"Request error details: %@",responseError.localizedDescription);
            completionBlock(nil, responseError);
            self.loginBlock = nil;
            self.logoutBlock = nil;
        }];
    };
    
    if (!self.logoutBlock) {
        self.loginBlock();
    }
}

#pragma mark - Subcription
- (void)getSubcriptionWithUserId:(NSString *)userId subscriptionID:(NSString *)sub_id completion:(BOOLResponseBlock)completionBlock
{
    NSLog(@"API Called: UpdateUserPlan");
    NSDictionary *dict = @{@"methodIdentifier" : @"UpdateUserPlan", @"userId": userId, @"subid": sub_id};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, id data) {
        NSDictionary *dataDictionary = data;
        NSLog(@"Request Password dataDictionary: %@",dataDictionary);
        //check data for success or error
        if ([dataDictionary objectForKey:@"result"]) {
            // messsage contains alert
            if ([[NSString stringWithFormat:@"%@",dataDictionary[@"result"]] isEqualToString:@"1"]) {
                completionBlock(TRUE, nil);
            }
            else {
                // request was unsuccessful
                NSError *newError = [self getError:dataDictionary];
                NSLog(@"Request error details: %@",newError);
                completionBlock(FALSE, newError);
            }
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            NSLog(@"Request error details: %@",newError);
            completionBlock(FALSE, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(FALSE, responseError);
    }];
}


#pragma mark -

- (void)sendCarrierInfo_Withcompletion:(BOOLResponseBlock)completionBlock{
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSLog(@"App carrier : %@",[carrier carrierName]);
    
    if (carrier) {
        NSString *carrierMCC = [carrier mobileCountryCode];
        NSString *carrierMNC = [carrier mobileNetworkCode];
        //        Testing
        //        NSString *carrierMCC = @"404";
        //        NSString *carrierMNC = @"64";
        
        if (([carrierMCC length] > 0) && ([carrierMNC length] > 0 )) {
            NSDictionary *dictNetwork = @{@"methodIdentifier": @"usernetworkapponly", @"userId": appState.currentUser.userId, @"mcc":carrierMCC, @"mnc":carrierMNC};
            
            NSError *errorNetwork = nil;
            NSData *jsonDataNetwork = [NSJSONSerialization dataWithJSONObject:dictNetwork options:NSJSONWritingPrettyPrinted error:&errorNetwork];
            if (errorNetwork) {
                NSLog(@"%@",errorNetwork.localizedDescription);
            }
            NSDictionary *paramsDictionaryNetwork = @{@"requestJSON" : jsonDataNetwork };
            
            [self commandWithParams:paramsDictionaryNetwork onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
                NSDictionary *dataDictionary = data[0];
                //check data for success or error
                if ([dataDictionary[@"result"] isEqualToString:@"1"]) {
                    NSLog(@"App carrier : Success");
                    completionBlock(TRUE, nil);
                }
            } onFailure:^(NSError *responseError) {
                NSLog(@"App carrier : ERROR");
                completionBlock(FALSE, responseError);
            }];
        }
    }else{
        NSLog(@"No carrier : ERROR");
        NSError *error = [NSError errorWithDomain:@"Error" code:7 userInfo:@{NSLocalizedDescriptionKey:@"No Carrier"}];
        completionBlock(FALSE, error);
    }
    
}

- (void)logOutWithCompletion:(BOOLResponseBlock)completionBlock
{
    SWAPI * __weak weakSelf = self;
    self.logoutBlock = ^{
        SWAPI * __strong self = weakSelf;
        NSLog(@"Logout API Called :SDHR");
        NSDictionary *dict;
        if (appState.currentUser.userId && appState.currentUser.hourRem) {
            dict = @{ @"methodIdentifier": @"getLogout", @"userId": appState.currentUser.userId, @"hoursRem": appState.currentUser.hourRem };
        }
        else {
            NSDictionary *lastKnownUserDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kLastLoggedInUser];
            NSString *lastKnownAuthToken = [[NSUserDefaults standardUserDefaults] stringForKey:kLastAuthToken];
            if (!lastKnownUserDict || !lastKnownAuthToken) {
                if (completionBlock) {
                    NSError *error = [self getError:@{ @"success" : @(404),
                                                       @"error" : @"Could not log out previous user because previous user and auth token do not exist."
                                                       }];
                    completionBlock(NO, error);
                }
                return;
            }
            self.requestSerializer = [[SWAuthenticationRequestSerializer alloc] initWithAuthToken:lastKnownAuthToken];
            SWUser *lastKnownUser = [SWUser modelObjectWithDictionary:lastKnownUserDict];
            dict = @{ @"methodIdentifier": @"getLogout", @"userId": lastKnownUser.userId, @"hoursRem": lastKnownUser.hourRem };
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        
        NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
        [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
            NSDictionary *dataDictionary = data[0];
            //            [appState.eventQueue postUserLoggedOut];
            //check data for success or error
            if ([dataDictionary[@"success"] isEqualToString:@"1"] || [dataDictionary[@"success"] isEqualToString:@"403"])
            {
                if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
                    NSLog(@"logout success 1");
                    self.validSession = NO;
                    completionBlock(YES, nil);
                }
                else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
                    // Oh noes, we couldn't log out because we were already
                    // logged out due to being idle. Whatever shall we do?
                    NSLog(@" logout success 403");
                    self.validSession = NO;
                    completionBlock(YES, nil);
                }
            }
            else {
                // request was unsuccessful
                NSLog(@"logout request was unsuccessful");
                NSError *newError = [self getError:dataDictionary];
                completionBlock(NO, newError);
            }
            self.logoutBlock = nil;
            if (self.loginBlock) {
                self.loginBlock();
            }
            NSLog(@"check this %s",__PRETTY_FUNCTION__);
        } onFailure:^(NSError *responseError) {
            //            [appState.eventQueue postUserLoggedOut];
            //request was unsuccessful
            NSLog(@"logout Request error details: %@",responseError.localizedDescription);
            completionBlock(NO, responseError);
            self.logoutBlock = nil;
            self.loginBlock = nil;
            NSLog(@"%s",__PRETTY_FUNCTION__);
        }];
    };
    
    if (!self.loginBlock) {
        self.logoutBlock();
    }
}
/*
 - (void)requestPasswordRecovery:(NSString *)recoveryEmail completion:(BOOLResponseBlock)completionBlock
 {
 NSDictionary *dict = @{@"methodIdentifier" : @"forgetMyPassword", @"userEmail": recoveryEmail};
 NSError *error = nil;
 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
 if (error) {
 NSLog(@"%@",error.localizedDescription);
 }
 NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
 [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
 NSDictionary *dataDictionary = data[0];
 //check data for success or error
 if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
 // messsage contains alert
 completionBlock(YES, nil);
 }
 else {
 // request was unsuccessful
 NSError *newError = [self getError:dataDictionary];
 completionBlock(NO, newError);
 }
 } onFailure:^(NSError *responseError) {
 //request was unsuccessful
 NSLog(@"Request error details: %@",responseError.localizedDescription);
 completionBlock(NO, responseError);
 }];
 }*/
//
- (void)requestPasswordRecovery:(NSString *)recoveryEmail completion:(BOOLResponseBlock)completionBlock
{
    NSDictionary *dict = @{@"methodIdentifier" : @"forgetMyPassword", @"userEmail": recoveryEmail};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        NSLog(@"Request Password dataDictionary: %@",dataDictionary);
        //check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            // messsage contains alert
            completionBlock(dataDictionary, nil);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            NSLog(@"Request error details: %@",newError);
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(NO, responseError);
    }];
}
//

/**
 * Method name: setTimeTracked
 * Description: Set time tracked -
 */
- (void)setTimeTracked:(NSString *)userId withTime:(NSNumber *)timeUsed completion:(JSONResponseBlock)completionBlock
{
    NSDictionary *dict = @{
                           @"methodIdentifier" : @"setTimeTracked",
                           @"userId" : userId,
                           @"timeUsed" : timeUsed
                           };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data.firstObject;
        NSLog(@"%@", dataDictionary);
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completionBlock(dataDictionary, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(dataDictionary, newError);
        }
        else {
            // request was unsuccessful
            completionBlock(dataDictionary, nil);
        }
    } onFailure:^(NSError *responseError) {
        // request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}


#pragma mark - Data Gathering

- (void)getPlaylistsForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock
{
    NSLog(@"Loading PlayList Data With:%@",userId);
    NSLog(@"User PlayList Session Valid:%@",self.isValidSession ? @"YES" : @"NO");
    if (!self.isValidSession) {
        return;
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"getMyStreams" forKey:@"methodIdentifier"];
    [dict setValue:userId forKey:@"userId"]; //was numeric
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            // check return object count
            NSUInteger count = [dataDictionary[@"streamInfo"] count];
            if (count < 1) {
                completionBlock(nil, nil);
                return;
            }
            NSArray *returnArray = [SWPlaylistCategory modelCategoriesWithArray:dataDictionary[@"streamInfo"] error:nil];
            completionBlock([returnArray mutableCopy], nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}

- (void)getFavoritesForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock
{
    if (!self.isValidSession) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"getMyFavorites" forKey:@"methodIdentifier"];
    [dict setValue:userId forKey:@"userId"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            //check return object count
            NSUInteger count = [dataDictionary[@"streamInfo"] count];
            if (count < 1) {
                completionBlock(nil, nil);
                return;
            }
            NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:count];
            for (id object in dataDictionary[@"streamInfo"]) {
                [returnArray addObject:[SWPlaylist modelObjectWithDictionary:object]];
            }
            completionBlock(returnArray, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}

- (void)getPurePlayListingsForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock
{
    NSLog(@"Loading PurePlayList Data With:%@",userId);
    NSLog(@"User PurePlayList Session Valid:%@",self.isValidSession ? @"YES" : @"NO");
    if (!self.isValidSession) {
        return;
    }
    NSDictionary *dict = @{@"methodIdentifier" : @"getMyPurePlay", @"userId" : userId};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
        NSLog(@"%@",error.localizedDescription);
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSMutableArray *data) {
        NSDictionary *dataDictionary = data[0];
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            if ([dataDictionary[@"streamInfo"] count] < 1) {
                completionBlock(nil, nil);
                return;
            }
            NSMutableArray *returnArray = [SWPlaylistCategory modelCategoriesWithArray:dataDictionary[@"streamInfo"] error:nil].mutableCopy;
            completionBlock(returnArray, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        NSLog(@"Pure Playlist Error Details: %@", responseError);
        completionBlock(nil, responseError);
    }];
}


- (void)getPlayListInfoForPlayListID:(NSString *)streamID withUserID:(NSString *)userId completion:(DataPlayListInfoReponseBlock)completionBlock
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.isValidSession) {
        return;
    }
    NSDictionary *dict = @{@"methodIdentifier" : @"getSongListing", @"streamId" : streamID, @"userId" : userId};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            
            //check return object count
            NSUInteger count = [dataDictionary[@"streamInfo"] count];
            if (count < 1) {
                completionBlock(nil, nil);
                return;
            }
            
            NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:count];
            for (id object in dataDictionary[@"streamInfo"]) {
                [returnArray addObject:[SWPlaylistInfo modelObjectWithDictionary:object]];
            }
            completionBlock(returnArray[0], nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil , newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}

-(void)getNewMixForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock {
    if (!self.isValidSession) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"getMyNewStreams" forKey:@"methodIdentifier"];
    [dict setValue:userId forKey:@"userId"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            //check return object count
            NSUInteger count = [dataDictionary[@"streamInfo"] count];
            if (count < 1) {
                completionBlock(nil, nil);
                return;
            }
            //            NSArray *returnArray = [SWNewMixes modelNewMixesWithArray:dataDictionary[@"streamInfo"] error:nil];
            NSMutableArray *returnArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *streamInfo in dataDictionary[@"streamInfo"]) {
                SWPlaylist *stream = [SWPlaylist modelObjectWithDictionary:streamInfo];
                [returnArray addObject:stream];
            }
            completionBlock([returnArray mutableCopy], nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}

-(void)getNewMixCountForUserID:(NSString *)userId completion:(IntegerResponseBlock)completionBlock {
    if (!self.isValidSession) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"getMyNewStreamsCount" forKey:@"methodIdentifier"];
    [dict setValue:userId forKey:@"userId"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            NSUInteger count = [dataDictionary[@"count"] integerValue];
            completionBlock(count, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}


-(void)getUserCategoryNotifyListForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock {
    if (!self.isValidSession) {
        return;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"getUserCategoryNotifyList" forKey:@"methodIdentifier"];
    [dict setValue:userId forKey:@"userId"];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            //check return object count
            NSUInteger count = [dataDictionary[@"userCategorySettingsInfo"] count];
            if (count < 1) {
                completionBlock(nil, nil);
                return;
            }
            NSArray *returnArray = [SWUserNotificationList modelObjectWithArray:dataDictionary[@"userCategorySettingsInfo"]];
            completionBlock([returnArray mutableCopy], nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(nil, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(nil, responseError);
    }];
}

#pragma mark - Data Setting

- (void)setPlayListPlayedForUserID:(NSString *)userId playlist:(SWPlaylist *)playlist completion:(BOOLResponseBlock)completionBlock
{
    if (!self.isValidSession) {
        return;
    }
    if (!playlist.streamId || !appState.currentUser.userId) {
        return;
    }
    
    NSDictionary *dict = @{@"methodIdentifier": @"setStreamPlayed", @"userId": appState.currentUser.userId, @"catId": playlist.streamId};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON": jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        // check data for success or error
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completionBlock(YES, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            // Don't show the alert here because we're already showing one for when we try to get the playlist info
            completionBlock(NO, newError);
        }
        else {
            // request was unsuccessful
            NSError *newError = [self getError:dataDictionary];
            completionBlock(NO, newError);
        }
    } onFailure:^(NSError *responseError) {
        //request was unsuccessful
        NSLog(@"Request error details: %@",responseError.localizedDescription);
        completionBlock(NO, responseError);
    }];
}

- (void)setSongPlayedForUserID:(NSString *)userId playlist:(SWPlaylist *)playlist playlistInfo:(SWSong *)song completion:(BOOLResponseBlock)completionBlock
{
    NSLog(@"Reporting song played to server\nuser: %@\nplaylist: %@\nsong:%@", userId,playlist.streamTitle, song.songTitle);
    
    NSDictionary *dict = @{
                           @"methodIdentifier" : @"setSongPlayed",
                           @"title" : song.songTitle,
                           @"artist" : song.songArtist,
                           @"isrcCode" : song.songISRC,
                           @"recordLabel" : song.songLabel,
                           @"userId" : userId ? userId : @"",
                           @"categoryID":playlist.categoryId,
                           @"streamid":playlist.streamId
                           };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error making JSON data for setting song played: %@", error);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *operation, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completionBlock(YES, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(NO, newError);
        }
        else {
            NSError *newError = [self getError:dataDictionary];
            completionBlock(NO, newError);
        }
    } onFailure:^(NSError *responseError) {
        NSLog(@"ERROR setting Favorites: %@", responseError);
        completionBlock(NO, responseError);
    }];
}

-(void)setUserCategoryNotifyForUserID:(NSString *)userId CategoryID:(NSString *)catId notificationvalue:(NSString *)notiValue completion:(BOOLResponseBlock)completionBlock {
    NSLog(@"Reporting song played to server\nuser: %@\nplaylist: %@\nsong:%@", userId,catId, notiValue);
    
    NSDictionary *dict = @{@"methodIdentifier" : @"setUserCategoryNotify",
                           @"catId" : catId,
                           @"userId" : userId,
                           @"wants_notify" : notiValue
                           };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"Error making JSON data for setting song played: %@", error);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *operation, NSArray *data) {
        NSDictionary *dataDictionary = data[0];
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completionBlock(YES, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completionBlock(NO, newError);
        }
        else {
            NSError *newError = [self getError:dataDictionary];
            completionBlock(NO, newError);
        }
    } onFailure:^(NSError *responseError) {
        NSLog(@"ERROR setting Favorites: %@", responseError);
        completionBlock(NO, responseError);
    }];
}

- (void)addPlaylistID:(NSString *)playlistID  toFavoritesForUserID:(NSString *)userID completion:(BOOLResponseBlock)completion
{
    if (!self.isValidSession) {
        return;
    }
    NSDictionary *dict = @{@"methodIdentifier" : @"setMyFavorite",
                           @"streamId" : playlistID,
                           @"userId" : userID};
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Error Making JSON Data for setting favorite: %@", error);
    }
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSMutableArray *data) {
        NSDictionary *dataDictionary = data[0];
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completion(YES, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completion(NO, newError);
        }
        else {
            NSError *newError = [self getError:dataDictionary];
            completion(NO, newError);
        }
    } onFailure:^(NSError *responseError) {
        NSLog(@"ERROR setting Favorites: %@", responseError);
        completion(NO, responseError);
    }];
}

- (void)removePlaylistID:(NSString *)playlistID   fromFavoritesForUserID:(NSString *)userID completion:(BOOLResponseBlock)completion
{
    if (!self.isValidSession) {
        return;
    }
    NSDictionary *dict = @{@"methodIdentifier" : @"deleteMyFavorite",
                           @"streamId" : playlistID,
                           @"userId" : userID};
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"Error making JSON Data for removing favorite: %@", error);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *op, NSMutableArray *data) {
        NSDictionary *dataDictionary = data[0];
        if ([dataDictionary[@"success"] isEqualToString:@"1"]) {
            completion(YES, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"]) {
            if (self.validSession) {
                NSLog(@"Invalid Session Reason For:%@",dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completion(NO, newError);
        }
        else {
            NSError *newError = [self getError:dataDictionary];
            completion(NO, newError);
        }
    } onFailure:^(NSError *responseError) {
        NSLog(@"ERROR removing Favorites: %@", responseError);
        completion(NO, responseError);
    }];
}

-(BOOL)voteUpAndVoteDownToCurrentSongCatName:(NSString *)catName AndStreamName:(NSString *)streamName AndTrackName:(NSString *)trackName AndVote:(NSString *)vote completion:(BOOLResponseBlock)completion {
    
    if (!self.isValidSession)
    {
        return NO;
    }
    
    NSMutableDictionary *userInfo = [appState userInfoDictionaryForUserId:appState.currentUser.userId];
    if (userInfo)
    {
        NSArray *trackVotes = [userInfo objectForKey:@"TrackVotes"];
        if (trackVotes)
        {
            if([trackVotes containsObject:[NSString stringWithFormat:@"%@-%@-%@", catName,streamName,trackName]])
            {
                return YES;
            }
        }
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    https://stingwax.com/vote_track.php?catName=Club%20Zone&streamName=Club%20Assassin%2013&trackName=LRAD%20Ain%27t%20A%20Party&vote=1
    
    NSString *strURL = [NSString stringWithFormat:@"https://stingwax.com/vote_track.php?catName=%@&streamName=%@&trackName=%@&vote=%@",catName,streamName,trackName,vote];
    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dataDictionary[@"status"] isEqualToString:@"ok"]) {
            
            NSMutableDictionary *userInfo = [appState userInfoDictionaryForUserId:appState.currentUser.userId];
            NSArray *trackVotesArray = [userInfo objectForKey:@"TrackVotes"];
            NSMutableArray *trackVotes;
            if (trackVotesArray)
            {
                trackVotes = [trackVotesArray mutableCopy];
            }
            else
            {
                trackVotes = [NSMutableArray array];
            }
            
            [trackVotes addObject:[NSString stringWithFormat:@"%@-%@-%@", catName,streamName,trackName]];
            [userInfo setObject:trackVotes forKey:@"TrackVotes"];
            [appState setUserInfoDictionary:userInfo forUserId:appState.currentUser.userId];
            completion(YES, nil);
        }
        else if ([dataDictionary[@"error"] isEqualToString:@"ok"]) {
            completion(NO, dataDictionary[@"error"]);
        }
        else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(TRUE, error);
    }];
    
    return NO;
}

-(void)voteUpAndVoteDownToCurrentStreamCatID:(NSString *)categoryID AndStreamID:(NSString *)streamID AndVote:(NSString *)vote completion:(JSONResponseBlock)completion
{
    if (!self.isValidSession)
    {
        return;
    }
    
    NSDictionary *dict = @{@"methodIdentifier" : @"voteMix",
                           @"streamId" : streamID,
                           @"vote" : vote,
                           @"userId" : appState.currentUser.userId
                           };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"Error making JSON data for setting vote mix %@", error);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *operation, NSArray *data)
    {
        NSDictionary *dataDictionary = data[0];
        NSLog(@"%@", dataDictionary);
        if ([dataDictionary[@"success"] isEqualToString:@"1"])
        {
            completion(dataDictionary, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"])
        {
            if (self.validSession)
            {
                NSLog(@"Invalid Session Reason For:%@", dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completion(nil, newError);
        }
        else
        {
            NSError *newError = [self getError:dataDictionary];
            completion(nil, newError);
        }
    } onFailure:^(NSError *responseError)
    {
        NSLog(@"ERROR vote mix: %@", responseError);
        completion(nil, responseError);
    }];
    
    
    
    
    
    //    //    https://stingwax.com/vote.php?catID=138&vote=1&streamID=537
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //    NSString *strURL = [NSString stringWithFormat:@"https://stingwax.com/vote.php?catID=%@&vote=%@&streamID=%@",categoryID,vote,streamID];
    //    strURL = [strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    [manager GET:strURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    //    {
    //        NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
    //        if ([dataDictionary[@"status"] isEqualToString:@"ok"]) {
    //            completion(YES, nil);
    //        }
    //        else if ([dataDictionary[@"error"] isEqualToString:@"ok"]) {
    //            completion(NO, dataDictionary[@"error"]);
    //        }
    //        else {
    //            completion(NO, nil);
    //        }
    //    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //        completion(NO, error);
    //    }];
}


-(void)streamShareReport_WitStreamID:(NSString *)streamID shareFB:(NSString*)shareFB shareTW:(NSString*)shareTW shareGP:(NSString*)shareGP AndCompletion:(BOOLResponseBlock)completion
{
    if (!self.isValidSession)
    {
        return;
    }
    
    NSDictionary *dict = @{@"methodIdentifier" : @"userstreamshare",
                           @"shareFB" : shareFB,
                           @"shareTW" : shareTW,
                           @"shareGP" : shareGP,
                           @"userId" : appState.currentUser.userId,
                           @"streamId": streamID
                           };
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"Error making JSON data for setting vote mix %@", error);
    }
    
    NSDictionary *paramsDictionary = @{@"requestJSON" : jsonData};
    [self commandWithParams:paramsDictionary onCompletion:^(AFHTTPRequestOperation *operation, NSArray *data)
    {
        NSDictionary *dataDictionary = data[0];
        NSLog(@"%@", dataDictionary);
        if ([dataDictionary[@"result"] isEqualToString:@"1"])
        {
            completion(TRUE, nil);
        }
        else if ([dataDictionary[@"success"] isEqualToString:@"403"])
        {
            if (self.validSession)
            {
                NSLog(@"Invalid Session Reason For:%@", dataDictionary);
                [self postInvalidSessionNotification:dataDictionary];
            }
            
            self.validSession = NO;
            NSError *newError = [self getError:dataDictionary];
            completion(FALSE, newError);
        }
        else
        {
            NSError *newError = [self getError:dataDictionary];
            completion(FALSE, newError);
        }
    } onFailure:^(NSError *responseError)
    {
        NSLog(@"ERROR vote mix: %@", responseError);
        completion(FALSE, responseError);
    }];
}
@end
