//
//  AppState.h ~ Singleton Global Class
//

#import "SWAppState.h"
#import "StingWax-Keys.h"
#import "NSObject+SWAssociatedValues.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"
#import "SWAppDelegate.h"
#import "SWSubscriptionViewController.h"


SWAppState *appState = nil;
@implementation SWAppState {
    NSNumber *_timeRemainingForCurrentUser;
    SWAppDelegate *appDelegate;
    SWSubscriptionViewController *objSWSubscriptionViewController;
}

@synthesize currentUser = _currentUser;
@synthesize currentPlayList = _currentPlayList;
@synthesize currentPlayListInfo = _currentPlayListInfo;
@synthesize currentSong = _currentSong;


#pragma mark - Variables

- (NSTimeInterval)timeLeftForCurrentUser
{
    if (!_timeRemainingForCurrentUser) {
        _timeRemainingForCurrentUser = @(self.currentUser.hourRem.integerValue);
    }
    return _timeRemainingForCurrentUser.doubleValue;
}

- (void)setTimeLeftForCurrentUser:(NSTimeInterval)timeLeftForCurrentUser
{
    _timeRemainingForCurrentUser = @(timeLeftForCurrentUser);
}

- (SWUser *)currentUser {
    return _currentUser;
}

- (void)setCurrentUser:(SWUser *)currentUser {
    _currentUser = currentUser;
    _timeRemainingForCurrentUser = nil;
    [[NSUserDefaults standardUserDefaults] setObject:_currentUser.dictionaryRepresentation forKey:kLastLoggedInUser];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCurrentPlayList:(SWPlaylist *)currentPlayList {
    _currentPlayList = currentPlayList;
    _currentPlayListInfo = nil;
    if (_currentPlayList) {
        [_eventQueue postPlayListPlayed];
    }
}


- (void)setCurrentPlayListInfo:(SWPlaylistInfo *)currentPlayListInfo {
    _currentPlayListInfo = currentPlayListInfo;
}

- (void)setCurrentSong:(SWSong *)currentSong
{
    // Everytime a song is changed.. trigger a tracker.
    _currentSong = currentSong;
    // Prob don't need this.. but.. doing it for safety.
    if (_currentSong) {
        [_eventQueue postSongPlayed];
    }
}


#pragma mark - Object lifecycle
- (id)init {
    self = [super init];
    if (self) {
        self.isMyPlayerRunning = FALSE;
        [self initAppState];
        appState = self;
        _display	= [SWDisplay new];
        _eventQueue = [SWEventQueue new];
        
    }
    return self;
}

- (void)initAppState {
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SWShowSubscriptionScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSubscriptionScreen:) name:SWShowSubscriptionScreen object:nil];
    
    // Set up Reachability
    _internetReachable = [Reachability reachabilityForInternetConnection];
    [_internetReachable startNotifier];
    _oldNetworkStatus = [_internetReachable currentReachabilityStatus];
    _currentUser = nil;
}


#pragma mark - Internet Connectivity
- (void)checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    
    NetworkStatus internetStatus = [_internetReachable currentReachabilityStatus];
    if (_oldNetworkStatus != internetStatus) {
        // Internet status has a new value!!
        _oldNetworkStatus = internetStatus;
        switch (internetStatus) {
            case NotReachable: {
                NSLog(@"The internet is down.");
                [appState.eventQueue postInternetReachabilityUnavailable];
                break;
            }
            case ReachableViaWiFi:
            case ReachableViaWWAN: {
                NSLog(@"The internet is available.");
                [appState.eventQueue postInternetReachabilityAvailable];
                break;
            }
        }
    }
}


#pragma mark - NSUserDefaults Helper Methods
- (NSMutableDictionary *)userInfoDictionaryForUserId:(NSString *)userId
{
    if (!userId) {
        return nil;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *userInfo = [defaults dictionaryForKey:@"UserInfo"];
    if (!userInfo) {
        userInfo = [NSDictionary dictionary];
        [defaults setObject:userInfo forKey:@"UserInfo"];
        [defaults synchronize];
    }
    return [userInfo[userId.uppercaseString] mutableCopy];
}

- (void)setUserInfoDictionary:(NSDictionary *)specificUserInfo forUserId:(NSString *)userId
{
    if (!userId) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userInfo = [defaults dictionaryForKey:@"UserInfo"].mutableCopy;
    if (!userInfo) {
        userInfo = [NSMutableDictionary dictionary];
    }
    [userInfo setValue:specificUserInfo forKey:userId.uppercaseString];
    [defaults setObject:userInfo forKey:@"UserInfo"];
    [defaults synchronize];
}


#pragma mark - Song Skipping

- (NSDictionary*)skippedSongCountForUserId:(NSString *)userId {
    NSDictionary *specificUserInfo = [self userInfoDictionaryForUserId:userId];
    
    if (specificUserInfo) {
       return  @{ @"SkippedSongCount":specificUserInfo[@"SkippedSongCount"],
           @"SkippedStartingDateTime":specificUserInfo[@"SkippedStartingDateTime"]};
    }
    else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nowDate = [dateFormat dateFromString:[dateFormat stringFromDate:[NSDate date]]];
        return @{@"SkippedSongCount":@"0",@"SkippedStartingDateTime":[dateFormat stringFromDate:nowDate]};
    }
//    return [specificUserInfo[@"SkippedSongCount"] unsignedIntegerValue];
}

- (void)setSkippedSongCount:(NSString *)skippedSongCount forUserId:(NSString *)userId AndWithDateTime:(NSString *)dateTime {
    NSMutableDictionary *specificUserInfo = [self userInfoDictionaryForUserId:userId];
    if (!specificUserInfo) {
        specificUserInfo = [NSMutableDictionary dictionary];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [dateFormat dateFromString:[dateFormat stringFromDate:[NSDate date]]];
    
    [specificUserInfo setValue:(skippedSongCount?skippedSongCount:@"0") forKey:@"SkippedSongCount"];
    [specificUserInfo setValue:(dateTime?dateTime:[dateFormat stringFromDate:nowDate]) forKey:@"SkippedStartingDateTime"];
    [self setUserInfoDictionary:specificUserInfo forUserId:userId];
}

#pragma mark - Session Restarting
- (void)tryRestartingPreviousSessionForUserId:(NSString *)userId {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IsAlertShowing"]) {
        return;
    }
    if ([self canRestartPreviousSessionForUserId:appState.currentUser.userId]) {
        [self askToRestartPreviousSessionForUserId:appState.currentUser.userId];
    }
}

-(BOOL) doesAlertViewExist {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0) {
            
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if (alert || action)
                return YES;
        }
    }
    return NO;
}

- (BOOL)canRestartPreviousSessionForUserId:(NSString *)userId {
    NSDictionary *specificUserInfo = [self userInfoDictionaryForUserId:userId];
    return specificUserInfo[@"lastPlayedPlaylistID"] && specificUserInfo[@"lastPlayedTrackNumber"] && specificUserInfo[@"lastPlayedTrackTime"];
}

- (void)askToRestartPreviousSessionForUserId:(NSString *)userId {
    
    NSString *cancelButtonTitle = @"New Session";
    NSString *resumePlayingTitle = @"Resume Playing";
    [UIAlertView showWithTitle:@"Resume Previous Session"
                       message:@"Would you like to resume playing from where you left off last time?"
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:@[resumePlayingTitle]
                       handler:^(TPAlertViewHandlerParams *const params) {
                           if (params.handlerType == TPAlertViewTappedButton) {
                               if ([params.buttonTitle isEqualToString:cancelButtonTitle]) {
                                   [self clearPlaylistAndSongInfoForUserId:userId];
                                   [appState clearPlaylistAndSongInfoForUserId:appState.currentUser.userId];
                                   appDelegate = [SWAppDelegate sharedDelegate];
                                   if (appDelegate.Tab0NavBarcontroller) {
                                       [appDelegate.mainTabBarcontroller setSelectedIndex:0];
                                       [appDelegate.Tab0NavBarcontroller popToRootViewControllerAnimated:TRUE];
                                   }
                                   
                               }
                               else if ([params.buttonTitle isEqualToString:resumePlayingTitle]) {
                                   [self loadPlaylistAndSongInfoForUserId:userId];
                                   [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"stringwax.isResumeFunctionality"];
                               }
                           }
                           if (params.handlerType == TPAlertViewDidDismiss) {
                               NSLog(@"IsAlertShowing set:FALSE");
                               [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"IsAlertShowing"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           }else if (params.handlerType == TPAlertViewDidPresent){
                               NSLog(@"IsAlertShowing set:TRUE");
                               [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"IsAlertShowing"];
                               [[NSUserDefaults standardUserDefaults] synchronize];
                           }
                       }];
}

- (void)saveCurrentPlaylistAndSongInfoForUserId:(NSString *)userId
{
    if (!self.currentPlayList.streamId) {
        return;
    }
    
    NSMutableDictionary *specificUserInfo = [self userInfoDictionaryForUserId:userId];
    if (!specificUserInfo) {
        specificUserInfo = [NSMutableDictionary dictionary];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nowDate = [dateFormat dateFromString:[dateFormat stringFromDate:[NSDate date]]];

        specificUserInfo[@"SkippedSongCount"] = @"0";
        specificUserInfo[@"SkippedStartingDateTime"] = nowDate;
    }
    
    specificUserInfo[@"lastPlayedPlaylistID"] = self.currentPlayList.streamId;
    specificUserInfo[@"lastPlayedTrackNumber"] = @(self.currentPlayList.currentTrackNumber);
    specificUserInfo[@"lastPlayedTrackTime"] = @(self.currentPlayList.currentTrackTime);
    [self setUserInfoDictionary:specificUserInfo forUserId:userId];
}

- (void)loadPlaylistAndSongInfoForUserId:(NSString *)userId
{
    if ([self canRestartPreviousSessionForUserId:userId]) {
        NSDictionary *specificUserInfo = [self userInfoDictionaryForUserId:userId];
        id lastPlayedPlaylistID = specificUserInfo[@"lastPlayedPlaylistID"];
        id lastPlayedTrackNumber = specificUserInfo[@"lastPlayedTrackNumber"];
        id lastPlayedTrackTime = specificUserInfo[@"lastPlayedTrackTime"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SWReloadPlayerNotification object:self
                                                          userInfo:@{@"userID" : userId,
                                                                     @"lastPlayedPlaylistID" : lastPlayedPlaylistID,
                                                                     @"lastPlayedTrackNumber" : lastPlayedTrackNumber,
                                                                     @"lastPlayedTrackTime" : lastPlayedTrackTime}];
        
//        [self clearPlaylistAndSongInfoForUserId:userId];
    }
}

- (void)clearPlaylistAndSongInfoForUserId:(NSString *)userId
{
    [self setUserInfoDictionary:nil forUserId:userId];
}


#pragma mark - Time Expiration Handlers

- (BOOL)isTimeExpiredForCurrentUser
{
    return ![self currentUserHasUnlimitedAccount] && [self timeLeftForCurrentUser] <= 0.0;
}

- (BOOL)isAccountExpiredForCurrentUser
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *expDate = [dateFormatter dateFromString:self.currentUser.exDate];
    return [expDate timeIntervalSinceNow] < 0;
}

- (BOOL)currentUserHasUnlimitedAccount {
    NSArray *unlimitedAccountIds = @[@"6", @"7"];
    return [unlimitedAccountIds containsObject:self.currentUser.subscriptionId];
}


#pragma mark - Notifications
- (void)userLoggedOut:(NSNotification *)notification {
    // do anything that needs to be done to log the current user out.
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastLoggedInUser];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastAuthToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Documents
- (NSString *)pathInDocumentDirectory:(NSString *)fileName
{
    //list of documentDirectories in on our device sandbox
    NSArray *documentDirectories= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    //there is only one on iPhone/iPad
    NSString *documentDirectory = documentDirectories[0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

-(void)showSubscriptionScreen:(NSNotification*)notification {

    if (self.currentUser.userId) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        if(!objSWSubscriptionViewController) {
            objSWSubscriptionViewController = [storyboard instantiateViewControllerWithIdentifier:@"SWSubscriptionViewController"];
        }        
        if (!objSWSubscriptionViewController.isSubscriptionViewShowing) {
            [[SWAppDelegate sharedDelegate].window.rootViewController presentViewController:objSWSubscriptionViewController animated:TRUE completion:^{
                
            }];
        }
    }
}

@end
