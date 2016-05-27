//
//  SWKeepAlive.m
//  StingWax
//
//  Created by Jeffrey Berthiaume on 5/9/14.
//  Copyright (c) 2014 MEDL Mobile, Inc. All rights reserved.
//

#import "SWKeepAlive.h"

@interface SWKeepAliveDelegate : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSHTTPURLResponse *urlResponse;
@property (nonatomic, strong) NSMutableData *data;

@end

static NSCondition *keepAliveLock;
static NSOperationQueue *keepAliveQueue;
static BOOL keepAlive;

@implementation SWKeepAlive

+ (void)load {
    keepAliveQueue = [[NSOperationQueue alloc] init];
    keepAliveQueue.maxConcurrentOperationCount = 1;
    keepAliveLock = [[NSCondition alloc] init];
    keepAlive = NO;
}

+ (void)startKeepWebSessionAlive {
    [keepAliveLock lock];
    keepAlive = YES;
    [keepAliveQueue cancelAllOperations];
    [self addKeepAliveRequest];
    [keepAliveLock unlock];
}

+ (void)addKeepAliveRequest {
    if (keepAlive) {
        [keepAliveQueue addOperation:[NSBlockOperation blockOperationWithBlock:^(void) {
            @autoreleasepool {
                
//                NSURL *url = [NSURL URLWithString:@"https://stingwax.com/BETA/images/img_whitelock.png"];
                NSURL *url = [NSURL URLWithString:@"https://www.stingwax.com/images/stingwax-logo.png"];
                // Create the request.
                NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
                                                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData // Ignore ALL cached data, we're doing this to keep the cookie up to date, not for the data.
                                                                    timeoutInterval:60.0];
                
                // create the connection with the request
                NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:[SWKeepAliveDelegate new]];
                // and start loading the data
                [connection start];
                
                CFRunLoopRun();
            }
        }]];
        [keepAliveQueue addOperation:[NSBlockOperation blockOperationWithBlock:^(void) {
            for (NSInteger i = 0; i < 2*60 && keepAlive; i++) sleep(1); // 2 minute sleep
            [keepAliveLock lock];
            if (keepAlive) [self addKeepAliveRequest];
            [keepAliveLock unlock];
        }]];
    }
}

+ (void)stopKeepWebSessionAlive {
    [keepAliveLock lock];
    keepAlive = NO;
    [keepAliveQueue cancelAllOperations];
    [keepAliveLock unlock];
}

@end


@implementation SWKeepAliveDelegate

#pragma mark - NSURLConnectionDelegate methods
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    /*if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
     if ([trustedHosts containsObject:challenge.protectionSpace.host])*/
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.urlResponse = (NSHTTPURLResponse*) response;
    self.data = [[NSMutableData alloc] initWithCapacity:2048];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:self.data];
    if (image) {
        // The image will only be created if we got valid image bytes back
//        NSLog (@"\n\nJBB: The connection worked!  Got Image.  Response: %@\n\n\n", self.urlResponse);
    } else {
        // Happens if we got something we couldn't turn into an image
        // This is still not necessarily a failure, as we hit the server and updated the cookie, we just
        // didn't an image back for some reason.
//        NSLog (@"\n\nJBB: The connection worked!  Did not get Image. Response: %@\n\n\n", self.urlResponse);
    }
    CFRunLoopStop(CFRunLoopGetCurrent());
}


@end
