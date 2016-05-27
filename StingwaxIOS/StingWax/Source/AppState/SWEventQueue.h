//
//  EventQueue.h
//  
//

#import <Foundation/Foundation.h>

@interface SWEventQueue : NSObject

#pragma mark - API Events

- (void)postUserLoggedOut;

- (void)postPlayListPlayed; // handles the rporting of streams (playlists) played to the server.
- (void)postSongPlayed; // this handles the reporting of tracks played to the server.


#pragma mark - UIApplication Notifications

- (void)postResignActive;


#pragma mark - Internet Reachability

- (void)postInternetReachabilityUnavailable;
- (void)postInternetReachabilityAvailable;

@end
