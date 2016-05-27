//
//  AppState.h
//

#import <Foundation/Foundation.h>

#import "SWDisplay.h"
//#import "Alerts.h"
#import "SWEventQueue.h"
#import "Reachability.h"
#import "SWUser.h"
#import "SWPlaylist.h"
#import "SWPlaylistInfo.h"
#import "SWSong.h"
#import "SWBaseViewController.h"
#import "SWPlayerViewController.h"
@class SWPlayerViewController;

@interface SWAppState : NSObject

//External Global Singleton for AppState
extern SWAppState* appState;


#pragma mark - Properties
//@property (nonatomic, strong) Alerts *alerts;
@property (nonatomic, strong) SWDisplay *display;
@property (nonatomic, strong) SWEventQueue *eventQueue;
@property (nonatomic, strong) Reachability *internetReachable;
@property (nonatomic) NetworkStatus oldNetworkStatus;
@property (nonatomic) bool isMyPlayerRunning;

@property (nonatomic, strong) SWUser *currentUser;
@property (nonatomic) SWPlaylist *currentPlayList;
@property (nonatomic) SWPlaylistInfo *currentPlayListInfo;
@property (nonatomic) SWSong *currentSong;
@property (nonatomic, strong) SWPlayerViewController *currentPlayerViewController;
// Song Skipping
- (NSDictionary*)skippedSongCountForUserId:(NSString *)userId;
- (void)setSkippedSongCount:(NSString *)skippedSongCount forUserId:(NSString *)userId AndWithDateTime:(NSString *)dateTime;

// Session restarting
- (void)tryRestartingPreviousSessionForUserId:(NSString *)userId;
- (BOOL)canRestartPreviousSessionForUserId:(NSString *)userId;
- (void)saveCurrentPlaylistAndSongInfoForUserId:(NSString *)userId;
- (void)loadPlaylistAndSongInfoForUserId:(NSString *)userId;
- (void)clearPlaylistAndSongInfoForUserId:(NSString *)userId;

// Expired Time Handling
- (BOOL)isTimeExpiredForCurrentUser;
- (BOOL)currentUserHasUnlimitedAccount;
- (BOOL)isAccountExpiredForCurrentUser;

@property (nonatomic) NSTimeInterval timeLeftForCurrentUser;


#pragma mark - NSCoding Archive
- (NSString *)pathInDocumentDirectory:(NSString *)fileName;

- (NSMutableDictionary *)userInfoDictionaryForUserId:(NSString *)userId;
- (void)setUserInfoDictionary:(NSDictionary *)specificUserInfo forUserId:(NSString *)userId;

@end



