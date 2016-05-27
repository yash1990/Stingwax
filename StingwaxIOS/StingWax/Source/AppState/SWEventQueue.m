//
//  EventQueue.m
//
//

#import "SWEventQueue.h"

#import "SWAPI.h"
#import "SWAppState.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"

@interface SWEventQueue ()
{
    NSTimer *_trackSongTimer; // used to track new songs thirty seconds into the track.
}

@end



@implementation SWEventQueue

#pragma mark - Object lifecycle

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)postUserLoggedOut
{
    [_trackSongTimer invalidate];
    _trackSongTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SWUserLoggedOutNotification object:nil];
}

- (void)postPlayListPlayed
{
    [_trackSongTimer invalidate];
    _trackSongTimer = nil;
    
    [[SWAPI sharedAPI] setPlayListPlayedForUserID:appState.currentUser.userId playlist:appState.currentPlayList completion:^(BOOL success, NSError *error) {
        if (success) {
            
        }
        else {
            // Playlist not reported... not going to do anything here.
            NSLog(@"Playlist not reported.");
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                    NSLog(@"Invalid Session Reason For:%@",error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
    }];
}


/**
 * Method name: queueSongPlayed
 * Description: This method is very important to notify the server new songs have begun.. it should be called after
 new tracks begin..  Next, Previous, New tracks beginning, Tapping a track from song list.
 
 This method is triggered when currentSong changes within AppState
 
 */
- (void)postSongPlayed
{
    // Clear out old timer
    [_trackSongTimer invalidate];
    
    _trackSongTimer = [NSTimer scheduledTimerWithTimeInterval:kValueReportedSongDelay
                                                       target:self
                                                     selector:@selector(sendTracker:)
                                                     userInfo:nil
                                                      repeats:NO];
}

/**
 * Method name: sendTracker
 * Description: Sends the song played to the server for tracking...
 
 */
- (void)sendTracker:(NSTimer *)timer
{
    // Clear out old timer
    [_trackSongTimer invalidate];
    _trackSongTimer = nil;
    
    [[SWAPI sharedAPI] setSongPlayedForUserID:appState.currentUser.userId
                                     playlist:appState.currentPlayList
                                 playlistInfo:appState.currentSong
                                   completion:^(BOOL success, NSError *error)
    {
        if (!success) {
            // Song was not reported.. should be stored in object archive for retrieval later.
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                    NSLog(@"Invalid Session Reason For:%@",error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
    }];
}



#pragma mark - UIApplication Notifications

- (void)postResignActive
{
    // -- IMPORTANT!!! -- kill this..
    [_trackSongTimer invalidate];
    _trackSongTimer = nil;
}


#pragma mark - Reachability

- (void)postInternetReachabilityAvailable
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QueueInternetReachabilityAvailable" object:nil];
}

- (void)postInternetReachabilityUnavailable
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"QueueInternetReachabilityUnavailable" object:nil];
}

@end
