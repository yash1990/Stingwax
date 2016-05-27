//
//  PlayerViewController.m
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import "SWPlayerViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "GBDeviceInfo.h"

#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

static const NSString* PlayerStatusContext;
static const NSString* PlayerRateContext;
static const NSString* PlayerErrorContext;
static const NSString* PlayerTimeRangesContext;
static const NSString* PlayerItemStatusContext;
static const NSString* PlayerItemBufferEmptyContext;

#if defined(DEBUG) && DEBUG
static const NSUInteger kMaxNumberOfSongChanges = 6;
#else
static const NSUInteger kMaxNumberOfSongChanges = 6;
#endif



@interface SWPlayerViewController () <SongListViewControllerDelegate,GPPShareDelegate,GPPSignInDelegate,FBSDKSharingDelegate >{
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Width_Polygone;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Width_PlayerControl;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_YelloBGView;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Width_StreamTimeTrack;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Padding_CategoryToTop;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_CategoryLabel;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Padding_StreamNameAndCategory;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_StreaName;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Padding_StreamAndSongName;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_SongName;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Padding_SongNameAndHoneyComboView;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_padding_HoneyAndPlayControl;
    
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_BottomView;
    __weak IBOutlet NSLayoutConstraint *layoutConstraint_Height_SocialButton;
    SLComposeViewController *mySLComposerSheet;
}

@property(strong, nonatomic) NSString *shareStatus;
@property(strong, nonatomic) CTCallCenter *objCTCallCenter;
@end

@implementation SWPlayerViewController
@synthesize playerItem = _playerItem,player = _player, objCTCallCenter = _objCTCallCenter;

#pragma mark - Button Back Action
-(void)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - Getters
- (BOOL)isPlaying{
    return self.player.rate > 0.0f;
}


- (void)setPlayer:(AVPlayer *)player {
    [SWLogger logEventWithObject:self selector:_cmd];
    // Remove observers of previous player
    [_player removeObserver:self forKeyPath:@"status" context:&PlayerStatusContext];
    [_player removeObserver:self forKeyPath:@"rate" context:&PlayerRateContext];
    [_player removeObserver:self forKeyPath:@"error" context:&PlayerErrorContext];
    [_player removeObserver:self forKeyPath:@"currentItem.loadedTimeRanges" context:&PlayerTimeRangesContext];
    
    // Set player to new player
    _player = player;
    if (player !=nil) {
        self.wasPlaying = true;
        self.wasResumeByCall = FALSE;
    }
    // Add observers of new player
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&PlayerStatusContext];
    [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:&PlayerRateContext];
    [_player addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:&PlayerErrorContext];
    [_player addObserver:self forKeyPath:@"currentItem.loadedTimeRanges" options:NSKeyValueObservingOptionNew context:&PlayerTimeRangesContext];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    // Remove observers of previous playerItem
    [_playerItem removeObserver:self forKeyPath:@"status" context:&PlayerItemStatusContext];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:&PlayerItemBufferEmptyContext];
    [notifCenter removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [notifCenter removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    [notifCenter removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
    [notifCenter removeObserver:self name:AVPlayerItemTimeJumpedNotification object:_playerItem];
    
    // Set playerItem to new playerItem
    _playerItem = playerItem;
    
    // Add observers of new playerItem
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:&PlayerItemStatusContext];
    [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:&PlayerItemBufferEmptyContext];
    [notifCenter addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    [notifCenter addObserver:self selector:@selector(playerItemTimeJumped:) name:AVPlayerItemTimeJumpedNotification object:_playerItem];
    [notifCenter addObserver:self selector:@selector(playerItemFailedToPlayToEnd:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
    [notifCenter addObserver:self selector:@selector(playerItemPlaybackStalled:) name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
}

- (void)addObservers {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(applicationDidEnterBackgroundNotif:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notifCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotif:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter addObserver:self selector:@selector(applicationDidBecomeActiveNotif:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notifCenter addObserver:self selector:@selector(audioSessionInterruptionHandler:) name:AVAudioSessionInterruptionNotification object:nil];
    [notifCenter addObserver:self selector:@selector(audioSessionRouteChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
    [notifCenter addObserver:self selector:@selector(stingWaxRemoteControlReceived:) name:SWReceivedRemoteControlEvent object:nil];
    [notifCenter addObserver:self selector:@selector(audioSessionMediaServicesReset) name:AVAudioSessionMediaServicesWereResetNotification object:nil];
}

- (void)removeObservers {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [notifCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [notifCenter removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [notifCenter removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [notifCenter removeObserver:self name:SWReceivedRemoteControlEvent object:nil];
    [notifCenter removeObserver:self name:AVAudioSessionMediaServicesWereResetNotification object:nil];
}

#pragma mark  - Set Current Track Number
- (void)setCurrentTrackNumber:(NSInteger)currentTrackNumber {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    NSInteger newTrackNumber = currentTrackNumber;
    if (newTrackNumber >= (NSInteger)appState.currentPlayListInfo.songInfo.count) {
        newTrackNumber = 0;
    }
    if (newTrackNumber < 0) {
        newTrackNumber = appState.currentPlayListInfo.songInfo.count - 1;
    }
    _currentTrackNumber = newTrackNumber;
    // Update times (track time and total playlist time)
    self.currentTrackTime = 0.0f;
    if (_currentTrackNumber < (NSInteger)appState.currentPlayListInfo.songStartTimes.count) {
        self.currentPlayListTime = [appState.currentPlayListInfo.songStartTimes[_currentTrackNumber] doubleValue] + self.currentTrackTime;
    }
    else {
        NSLog(@"*** Error! Tried to set current track number to a number greater than the number of songs in the current playlist!\nappState.currentPlayListInfo: %@", appState.currentPlayListInfo);
        self.currentPlayListTime = 0.0f;
    }
    // Update appState
    if (newTrackNumber < (NSInteger)appState.currentPlayListInfo.songInfo.count) {
        appState.currentSong = appState.currentPlayListInfo.songInfo[newTrackNumber];
    }
    else {
        NSLog(@"*** Error! Tried to set current song to a track number that is greater than the number of songs in the current playlist!\nappState.currentPlaylistInfo: %@", appState.currentPlayListInfo);
        appState.currentSong = nil;
    }
    
    appState.currentPlayList.currentTrackNumber = newTrackNumber;
    appState.currentPlayList.currentTrackTime = 0.0f;
    // Update child view controllers
    self.songListViewController.currentTrackNumber = newTrackNumber;
    // Update UI
    [self updateLabels];
    [self updatePrevNextButtons];
    [self updateNowPlayingInfoCenter];
}

#pragma mark - Setup Style
- (void)setupStyle {
    [SWLogger logEventWithObject:self selector:_cmd];
    self.btnNext.exclusiveTouch = YES;
    self.btnPrev.exclusiveTouch = YES;
    self.btnPlayPause.exclusiveTouch = YES;
    self.btnViewSongList.exclusiveTouch = YES;
    self.btnFav.exclusiveTouch = YES;
}


#pragma mark - View Hierarchy
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupStyle];
    [self addObservers];
    
    self.progressBar.layer.cornerRadius = 8.0f;
    [self.progressBar setClipsToBounds:TRUE];
    
    self.btnPlayPause.enabled = NO;
    self.btnNext.enabled = NO;
    self.btnPrev.enabled = NO;
    self.lblCurrentSong.text = @"";
    self.lblMix.text = @"";
    self.timeRemainingLabel.text = @"00:00:00";
    self.lblDuration.text = @"00:00:00";
    self.lblCategoryName.text = appState.currentPlayList.categoryTitle.uppercaseString;
    self.lblCategoryName.textColor = appState.currentPlayList.colorStream;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForPlayerStatus:) name:@"SWPlayerStatus.Status" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharingStatus) name:ACAccountStoreDidChangeNotification object:nil];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnViewSongListTapped:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:leftSwipe];
    [self.view addGestureRecognizer:rightSwipe];
    
    //    [GPPSignInButton class];
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = @"182469158060-jecjgku3kphv5v5p74i02ia0so4tssk8.apps.googleusercontent.com";
    signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    signIn.delegate = self;
    
    self.objCTCallCenter = [[CTCallCenter alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Start %s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:FALSE];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.btnFav.enabled = NO;
    self.btnFav.selected = FALSE;
    self.progressBarWidth.constant = 0;
    [SWLogger logEvent:@"Get Favorite status"];
    [[SWAPI sharedAPI] getFavoritesForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error) {
        if (!error) {
            for (SWPlaylist *playlist in data) {
                if ([playlist.streamId isEqualToString:appState.currentPlayList.streamId]) {
                    self.btnFav.selected = YES;
                    break;
                }
            }
            [SWLogger logEvent:@"Get Favorite status succeeded"];
            NSLog(@"Got favorite status for current stream");
        }
        else {
            NSLog(@"Error loading favorite status for current stream");
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Get Favorite status: %@", error]];
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error  in %s", __PRETTY_FUNCTION__);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
        self.btnFav.enabled = YES;
    }];
    
    if (self.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        self.honeycombViewController.wasAnimatingHoneycombView = NO;
        [self.honeycombView stopAnimatingImmediately:YES];
    }
    
    if (![GPPSignIn sharedInstance].authentication || ![[GPPSignIn sharedInstance].scopes containsObject:kGTLAuthScopePlusLogin]) {
        [self.btnGPPSignInButton setHidden:FALSE];
        [self.btnGooglePlus setHidden:TRUE];
    }
    else{
        [self.btnGPPSignInButton setHidden:TRUE];
        [self.btnGooglePlus setHidden:FALSE];
    }
    self.btnGPPSignInButton.style = kGPPSignInButtonStyleIconOnly;
    //    self.btnGPPSignInButton.colorScheme = kGPPSignInButtonColorSchemeLight;
    [self.btnGPPSignInButton setImage:self.btnGooglePlus.imageView.image forState:UIControlStateNormal];
    [self.btnGPPSignInButton setImage:self.btnGooglePlus.imageView.image forState:UIControlStateSelected];
    [self.btnGPPSignInButton setImage:self.btnGooglePlus.imageView.image forState:UIControlStateHighlighted];
    [self.btnGPPSignInButton.layer setCornerRadius:14];
    [self.btnGPPSignInButton.layer setMasksToBounds:TRUE];
    
    layoutConstraint_Width_Polygone.constant = ceilf(self.view.frame.size.width/1.6);
    layoutConstraint_Width_PlayerControl.constant = ceilf(self.view.frame.size.width/2.3);
    layoutConstraint_Height_YelloBGView.constant = ceilf((self.view.frame.size.height*4)/100);
    layoutConstraint_Width_StreamTimeTrack.constant = ceilf((self.view.frame.size.height*2.6)/100);
    layoutConstraint_Padding_CategoryToTop.constant = ceilf((self.view.frame.size.height*3.25)/100);
    layoutConstraint_Height_CategoryLabel.constant = ceilf((self.view.frame.size.height*3.6)/100);
    layoutConstraint_Padding_StreamNameAndCategory.constant = ceilf((self.view.frame.size.height*1.96)/100);
    layoutConstraint_Height_StreaName.constant = ceilf((self.view.frame.size.height*2.3)/100);
    layoutConstraint_Padding_StreamAndSongName.constant = ceilf((self.view.frame.size.height*2.29)/100);
    layoutConstraint_Height_SongName.constant = ceilf((self.view.frame.size.height*6.7)/100);
    layoutConstraint_Padding_SongNameAndHoneyComboView.constant = ceilf((self.view.frame.size.height*1.47)/100);
    layoutConstraint_padding_HoneyAndPlayControl.constant = ceilf((self.view.frame.size.height*2.94)/100);
    layoutConstraint_Height_BottomView.constant = ceilf((self.view.frame.size.height*13.91)/100);
    layoutConstraint_Height_SocialButton.constant = ceilf((self.view.frame.size.height*5.25)/100);
    
    self.btn_VoteDown.hidden = TRUE;
    self.btn_VoteUp.hidden = TRUE;
    __weak __typeof__(self) weakSelf = self;
    [self.objCTCallCenter setCallEventHandler:^(CTCall *call)
    {
        NSLog(@"Event handler called");
        
        if ([call.callState isEqualToString: CTCallStateDisconnected])
        {
            NSLog(@"CallId's:%@",call.callID);
            NSLog(@"***** After  Starting    ******************************************************************");
            NSLog(@"After Called");
            NSLog(@"wasResumeByCall :%@",weakSelf.wasResumeByCall?@"TRUE":@"FALSE");
            NSLog(@"wasPlaying :%@",weakSelf.wasPlaying?@"TRUE":@"FALSE");
            if (weakSelf.wasResumeByCall) {
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.player pause];
//                    [weakSelf.btnPlayPause setImage:[[UIImage imageNamed:@"btn_Play_Song"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
//                    weakSelf.honeycombViewController.wasAnimatingHoneycombView = NO;
//                    [weakSelf.honeycombView stopAnimatingImmediately:YES];
//                    [weakSelf.activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:TRUE];
                    weakSelf.wasPlaying = TRUE;
                    //                    weakSelf.isBuffering = TRUE;
                    [weakSelf play];
                });
                
                NSLog(@"Disconnected");
            }
            NSLog(@"****** After Ending  **********************************************************************");
        }else if ([call.callState isEqualToString: CTCallStateConnected]){
            
        }
        else
        {
            NSLog(@"***** Before Starting     ***********************************************************************");
            weakSelf.wasResumeByCall = weakSelf.wasPlaying;
            NSLog(@"Before Called");
            NSLog(@"wasResumeByCall :%@",weakSelf.wasResumeByCall?@"TRUE":@"FALSE");
            NSLog(@"wasPlaying :%@",weakSelf.wasPlaying?@"TRUE":@"FALSE");
            weakSelf.wasPlaying = FALSE;
            [weakSelf.player pause];
            [weakSelf.btnPlayPause setImage:[[UIImage imageNamed:@"btn_Play_Song"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            weakSelf.honeycombViewController.wasAnimatingHoneycombView = NO;
            [weakSelf.honeycombView stopAnimatingImmediately:YES];
            weakSelf.isBeingInterruptedByCall = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:SWMyPlayerRunningNotification object:@0];
            
            NSLog(@"IncommiBg");
            NSLog(@"****** before Ending  **********************************************************************");
        }
    }];
    
    NSLog(@"Complete %s",__PRETTY_FUNCTION__);
}

- (void)viewDidAppear:(BOOL)animated {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidAppear:animated];
    // Register to start receiving remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

#pragma mark - DataSource
- (void)loadPlaylist:(SWPlaylist *)playlist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [self resetUI];
    self.btnViewSongList.enabled = NO;
    [SWLogger logEvent:@"Get Playlist Info"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:TRUE];
    });
    
    self.progressBarWidth.constant = 0;
    //Current playlist is set.. now to retrieve the stream listing for that playlist.
    [[SWAPI sharedAPI] getPlayListInfoForPlayListID:playlist.streamId withUserID:appState.currentUser.userId completion:^(SWPlaylistInfo *playListInfo, NSError *error1) {
        NSLog(@"getPlayListInfoForPlayListID Completion");
        [SVProgressHUD dismiss];
        [SWLogger logEvent:@"Get Playlist Info finished"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:TRUE];
        });
        if (!error1) {
            if (playListInfo != nil) {
                self.btnViewSongList.enabled = YES;
                // Set current playlist information as global property
                appState.currentPlayListInfo = playListInfo;
                // set the current song for global access.
                self.currentTrackNumber = trackNumber.integerValue;
                // set local values for determing what is going on.
                self.totalTrackCount = [appState.currentPlayListInfo.songInfo count];
                NSURL *url = [NSURL URLWithString:appState.currentPlayListInfo.streamPath];
                [SWLogger logEvent:[NSString stringWithFormat:@"Load Playlist with url: %@", url]];
                [self loadPlayListWithURL:url completion:^(NSError *error2) {
                    [SWLogger logEvent:[NSString stringWithFormat:@"Load Playlist completed for url: %@", url]];
                    if (!error2) {
                        NSInteger newTrackNumber = trackNumber.integerValue;
                        if (trackNumber && trackTime) {
                            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"stringwax.isResumeFunctionality"]) {
                                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"stringwax.isResumeFunctionality"]) {
                                    [self playTrackNumber:newTrackNumber atTime:[trackTime integerValue] seekToTime:YES completion:nil];
                                    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"stringwax.isResumeFunctionality"];
                                }
                                else {
                                    if (trackTime.integerValue>1) {
                                        for (int i = 0; i<appState.currentPlayListInfo.songStartTimes.count; i++) {
                                            NSNumber *startTime = [appState.currentPlayListInfo.songStartTimes objectAtIndex:i];
                                            newTrackNumber = newTrackNumber + 1;
                                            if (startTime.integerValue > trackTime.integerValue) {
                                                break;
                                            }
                                        }
                                    }
                                    [self playTrackNumber:newTrackNumber atTime:0 seekToTime:YES completion:nil];
                                }
                            }
                            else {
                                if (trackTime.integerValue>1) {
                                    for (int i = 0; i<appState.currentPlayListInfo.songStartTimes.count; i++) {
                                        NSNumber *startTime = [appState.currentPlayListInfo.songStartTimes objectAtIndex:i];
                                        newTrackNumber = newTrackNumber + 1;
                                        if (startTime.integerValue > trackTime.integerValue) {
                                            break;
                                        }
                                    }
                                }
                                [self playTrackNumber:newTrackNumber atTime:0 seekToTime:YES completion:nil];
                            }
                        }
                        self.btnPlayPause.enabled = YES;
                        // change lbl's to starting values
                        self.lblProgress.text = [SWDateTimeHelper convertTimeMinSec:0];
                        self.lblDuration.text = [SWDateTimeHelper convertTimeFullFormat:0];
                        // change tracks name and information
                        [self updateLabels];
                        [self updatePrevNextButtons];
                        [SWLogger logEvent:[NSString stringWithFormat:@"Load Playlist succeeded for url: %@", url]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:SWPlayerDidLoadPlaylist object:appState.currentPlayList];
                    }
                    else {
                        [SWLogger logEvent:[NSString stringWithFormat:@"Error on Load Playlist for url: %@, %@", url, error2]];
                        // TODO: handle error
                        [self resetUI];
                        self.lblCurrentSong.text = @"Error loading playlist";
                        if ([error2.domain isEqualToString:SWAPIErrorDomain]) {
                            if (error2.code == kSWErrorInvalidLogin) {
                                NSLog(@"Error 2 in %s", __PRETTY_FUNCTION__);
                                [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error2];
                                [self dismissViewControllerAnimated:TRUE completion:^{}];
                            }
                        }
                    }
                }];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Get Playlist: %@", error1]];
            // TODO: handle error
            [self resetUI];
            self.lblCurrentSong.text = @"Error loading playlist";
            self.btnViewSongList.enabled = NO;
            if ([error1.domain isEqualToString:SWAPIErrorDomain]) {
                if (error1.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error 1 in %s", __PRETTY_FUNCTION__);
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error1];
                }
            }
        }
    }];
}

#pragma mark - UI
- (void)resetUI {
    [SWLogger logEventWithObject:self selector:_cmd];
    self.btnPlayPause.enabled = NO;
    self.btnPrev.enabled = NO;
    self.btnNext.enabled = NO;
    self.lblCategoryName.text = appState.currentPlayList.categoryTitle.uppercaseString;
    self.lblCategoryName.textColor = appState.currentPlayList.colorStream;
}

- (void)updatePrevNextButtons {
    [SWLogger logEventWithObject:self selector:_cmd];
    self.btnNext.enabled = self.currentTrackNumber < self.totalTrackCount - 2;
    self.btnPrev.enabled = self.currentTrackNumber > 0;
}

- (void)updateLabels {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSArray *words = [appState.currentPlayList.categoryTitle.uppercaseString componentsSeparatedByString:@" "];
    
    UIFont *RelawayFont = [UIFont fontWithName:@"Relaway" size:14];
    UIFont *RelawayBoldFont = [UIFont fontWithName:@"Raleway-Bold" size:14];
    
    
    GBDeviceInfo *deviceInfo = [GBDeviceInfo deviceInfo];
    if (deviceInfo.display == GBDeviceDisplayiPhone35Inch || deviceInfo.display == GBDeviceDisplayiPhone4Inch) {
        RelawayFont = [UIFont fontWithName:@"Raleway" size:21];
        RelawayBoldFont = [UIFont fontWithName:@"Raleway-Bold" size:21];
    }
    else if (deviceInfo.display == GBDeviceDisplayiPhone47Inch) {
        RelawayFont = [UIFont fontWithName:@"Raleway" size:22];
        RelawayBoldFont = [UIFont fontWithName:@"Raleway-Bold" size:22];
    }
    else{
        RelawayFont = [UIFont fontWithName:@"Raleway" size:23];
        RelawayBoldFont = [UIFont fontWithName:@"Raleway-Bold" size:23];
    }
    
    //    UIFont *ArialFont = [UIFont fontWithName:@"HelveticaNeue" size:21.0];
    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: RelawayFont forKey:NSFontAttributeName];
    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: arialdict];
    if (words.count>1) {
        //        UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:21.0];
        NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:RelawayBoldFont forKey:NSFontAttributeName];
        NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc]initWithString:words[1] attributes:veradnadict];
        NSMutableAttributedString *SpaceString = [[NSMutableAttributedString alloc] initWithString:@" "];
        [AattrString appendAttributedString:SpaceString];
        [AattrString appendAttributedString:VattrString];
    }
    
    self.lblCategoryName.attributedText = AattrString;
    self.lblCategoryName.textColor = appState.currentPlayList.colorStream;
    
    UIFont *HelveticaFontBold = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    NSDictionary *trackNamedict = [NSDictionary dictionaryWithObject: HelveticaFontBold forKey:NSFontAttributeName];
    NSMutableAttributedString *trackString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@", appState.currentSong.songTitle, appState.currentSong.songArtist] attributes: trackNamedict];
    
    self.lblCurrentSong.attributedText = trackString;
    self.lblMix.font = [UIFont fontWithName:@"Relaway" size:12.0];
    self.lblMix.text = appState.currentPlayList.streamTitle.uppercaseString;
}

- (void)updateNowPlayingInfoCenter {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary dictionary];
    [nowPlayingInfo setValue:appState.currentSong.songTitle forKey:MPMediaItemPropertyTitle];
    [nowPlayingInfo setValue:appState.currentSong.songArtist forKey:MPMediaItemPropertyArtist];
    [nowPlayingInfo setValue:appState.currentPlayList.categoryTitle forKey:MPMediaItemPropertyAlbumTitle];
    [nowPlayingInfo setValue:@([appState.currentPlayListInfo.songInfo count]) forKey:MPMediaItemPropertyAlbumTrackCount];
    [nowPlayingInfo setValue:@(appState.currentPlayList.currentTrackNumber) forKey:MPMediaItemPropertyAlbumTrackNumber];
    [nowPlayingInfo setValue:@(appState.currentSong.songLength) forKey:MPMediaItemPropertyPlaybackDuration];
    [nowPlayingInfo setValue:@(1.0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    [nowPlayingInfo setValue:@(appState.currentPlayList.currentTrackTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = nowPlayingInfo;
}

#pragma mark  Vote Up And Down
#pragma mark - Button Three Dot Pressed
-(void)btnThreeDotTapped:(id)sender {
    UIButton *btnSender = (UIButton*)sender;
    //    btnSender.enabled = FALSE;
    if (btnSender.tag == 1) {
        btnSender.tag = 2;
        self.btn_VoteUp.hidden = FALSE;
        self.btn_VoteDown.hidden = FALSE;
        
    }
    else {
        btnSender.tag = 1;
        self.btn_VoteUp.hidden = TRUE;
        self.btn_VoteDown.hidden = TRUE;
    }
}

-(IBAction)btnVoteUpTapped:(id)sender {
    NSString *strTitle1 = @"Current Mix";
    NSString *strTitle2 = @"Current Track";
    [UIAlertView showWithMessage:@"Vote Up" cancelButtonTitle:nil otherButtonTitles:@[strTitle1,strTitle2,@"Cancel"] handler:^(TPAlertViewHandlerParams *const params) {
        if (params.handlerType == TPAlertViewTappedButton) {
            if ([params.buttonTitle isEqualToString:strTitle1]) {
                [[SWAPI sharedAPI] voteUpAndVoteDownToCurrentStreamCatID:appState.currentPlayList.categoryId AndStreamID:appState.currentPlayList.streamId AndVote:@"1" completion:^(NSDictionary* data, NSError *error) {
                    if (error)
                    {
                        [UIAlertView showWithTitle:@"Thanks!" message:[error localizedDescription] cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:nil];
                    }
                    else
                    {
                        [UIAlertView showWithTitle:@"Thank you!" message:data[@"message"] cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:nil];
                    }
                }];
            }
            else if ([params.buttonTitle isEqualToString:strTitle2]) {
                
                if([[SWAPI sharedAPI] voteUpAndVoteDownToCurrentSongCatName:appState.currentPlayList.categoryTitle AndStreamName:appState.currentPlayList.streamTitle AndTrackName:appState.currentSong.songTitle AndVote:@"1" completion:^(BOOL success, NSError *error) {
                    NSString *message = nil;
                    if (success)
                    {
                        message = @"This helps us measure how much people like or dislike this track. Your input was received and this will help us improve our service.";
                    }
                    else
                    {
                        message = @"We're sorry there was an error with you up-vote. Please try again later.";
                    }
                    [UIAlertView showWithTitle:@"Thank you!" message:message cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
                    }];
                }])
                {
                    [UIAlertView showWithTitle:@"Thanks!" message:@"You've already voted this track." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
                    }];
                }
            }
        }
    }];
}

-(IBAction)btnVoteDownTapped:(id)sender {
    NSString *strTitle1 = @"Current Mix";
    NSString *strTitle2 = @"Current Track";
    [UIAlertView showWithMessage:@"Vote Down" cancelButtonTitle:nil otherButtonTitles:@[strTitle1,strTitle2,@"Cancel"] handler:^(TPAlertViewHandlerParams *const params) {
        if (params.handlerType == TPAlertViewTappedButton) {
            if ([params.buttonTitle isEqualToString:strTitle1]) {
                [[SWAPI sharedAPI] voteUpAndVoteDownToCurrentStreamCatID:appState.currentPlayList.categoryId AndStreamID:appState.currentPlayList.streamId AndVote:@"-1" completion:^(NSDictionary *data, NSError *error) {
                    if (error)
                    {
                        [UIAlertView showWithTitle:@"Thanks!" message:[error localizedDescription] cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:nil];
                    }
                    else
                    {
                        [UIAlertView showWithTitle:@"Thank you!" message:data[@"message"] cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:nil];
                    }
                }];
            }
            else if ([params.buttonTitle isEqualToString:strTitle2]) {
                if([[SWAPI sharedAPI] voteUpAndVoteDownToCurrentSongCatName:appState.currentPlayList.categoryTitle AndStreamName:appState.currentPlayList.streamTitle AndTrackName:appState.currentSong.songTitle AndVote:@"0"                                                               completion:^(BOOL success, NSError *error) {
                    NSString *message = nil;
                    if (success)
                    {
                        message = @"This helps us measure how much people like or dislike this track. Your input was received and this will help us improve our service.";
                    }
                    else
                    {
                        message = @"We're sorry there was an error with you down-vote. Please try again later.";
                    }
                    
                    [UIAlertView showWithTitle:@"Thank you!" message:message cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
                    }];
                }])
                {
                    [UIAlertView showWithTitle:@"Thanks!" message:@"You've already voted this track." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
                    }];
                }
                
            }
        }
    }];
}

#pragma mark - Interface Interactions
-(IBAction)btnViewSongListTapped:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performSegueWithIdentifier:@"SongListSegue" sender:self];
}

- (void)viewSongList {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performSegueWithIdentifier:@"Song List" sender:nil];
}

-(void)btnFavTapped:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.btnFav.enabled = NO;
    if (![self.btnFav isSelected]) {
        [[SWAPI sharedAPI] addPlaylistID:appState.currentPlayList.streamId toFavoritesForUserID:appState.currentUser.userId completion:^(BOOL success, NSError *error) {
            if (!error) {
                if (success) {
                    self.btnFav.selected = YES;
                    [SVProgressHUD showSuccessWithStatus:@"Favorited Mix"];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        [SVProgressHUD dismiss];
                    });
                    NSLog(@"Added to favorites");
                }
                else {
                    NSLog(@"Problem adding to favorites.");
                }
            }
            else {
                NSLog(@"Problem adding to favorites: %@", error);
                if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                    if (error.code == kSWErrorInvalidLogin) {
                        NSLog(@"Error inner in %s", __PRETTY_FUNCTION__);
                        [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                    }
                }
            }
            self.btnFav.enabled = YES;
        }];
    }
    else {
        [[SWAPI sharedAPI] removePlaylistID:appState.currentPlayList.streamId fromFavoritesForUserID:appState.currentUser.userId completion:^(BOOL success, NSError *error) {
            if (!error) {
                if (success) {
                    self.btnFav.selected = NO;
                    [SVProgressHUD showSuccessWithStatus:@"Unfavorited Mix"];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                        [SVProgressHUD dismiss];
                    });
                    NSLog(@"Removed from favorites");
                }
                else {
                    NSLog(@"Problem removing from favorites.");
                }
            }
            else {
                NSLog(@"Problem removing from favorites: %@", error);
                if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                    if (error.code == kSWErrorInvalidLogin) {
                        NSLog(@"Error outer in %s", __PRETTY_FUNCTION__);
                        [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                    }
                }
            }
            self.btnFav.enabled = YES;
        }];
    }
}

#pragma mark - Player Actions
- (IBAction)tapPlayPause:(id)sender {
    NSLog(@"%s And %@", __PRETTY_FUNCTION__,self.isPlaying?@"TRUE":@"FALSE");
    [SWLogger logEventWithObject:self selector:_cmd];
    // This method is toggleable already.  so it will play if paused or pause if playing
    
    if (!self.isPlaying) {
        [self play];
    }
    else {
        [self pause];
        [self setWasPlaying:FALSE];
    }
}

/**
 * Method name: play
 * Description: starts the player.. no matter what.. leaves it be if already playing.
 */
- (void)play {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    //    if (!self.isPlaying && !self.isBeingInterrupted)
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isPlaying) {
            if (self.activity.isAnimating) {
                [self.activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:TRUE];
            }
            [self.player play];
            self.isBeingInterruptedByCall = FALSE;
            self.wasResumeByCall = FALSE;
            [self setWasPlaying:TRUE];
            [self.btnPlayPause setImage:[[UIImage imageNamed:@"btn_Pause_Song"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [self.honeycombView startAnimatingImmediately:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:SWMyPlayerRunningNotification object:@1];
        }
    });
}

- (void)pause {
    [SWLogger logEventWithObject:self selector:_cmd];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
        if (self.isPlaying) {
            [self.player pause];
            [self.btnPlayPause setImage:[[UIImage imageNamed:@"btn_Play_Song"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            self.honeycombViewController.wasAnimatingHoneycombView = NO;
            [self.honeycombView stopAnimatingImmediately:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:SWMyPlayerRunningNotification object:@0];
        }
    });
    
}

- (IBAction)playNextTrack {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [self playNextTrackWithCompletion:nil];
}

- (IBAction)playPreviousTrack {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [self playPreviousTrackWithCompletion:nil];
}

- (void)playNextTrackWithCompletion:(void(^)(BOOL finished))completion {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([appState isTimeExpiredForCurrentUser]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            self.showSubscriptionAlertWhenAppBecomesActive = NO;
            [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
                if (params.handlerType == TPAlertViewDidDismiss) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                }
            }];
        }
        else {
            self.showSubscriptionAlertWhenAppBecomesActive = YES;
        }
    }
    else if ([appState isAccountExpiredForCurrentUser])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
                if (params.handlerType == TPAlertViewDidDismiss) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                }
            }];
        }
    }
    else {
        NSString *strUserSubcriptionId = appState.currentUser.subscriptionId;
        if ([strUserSubcriptionId isEqualToString:@"3"] || [strUserSubcriptionId isEqualToString:@"8"] || [strUserSubcriptionId isEqualToString:@"9"]) {
            NSString *userId = appState.currentUser.userId;
            NSDictionary *dictSkipped= [appState skippedSongCountForUserId:userId];
            if ([self timeDifferenceBetween:dictSkipped]) {
                dictSkipped= [appState skippedSongCountForUserId:userId];
                NSString *strCount = [NSString stringWithFormat:@"%ld",([[dictSkipped valueForKey:@"SkippedSongCount"] integerValue] + 1)];
                [appState setSkippedSongCount:strCount forUserId:userId AndWithDateTime:[dictSkipped valueForKey:@"SkippedStartingDateTime"]];
                [self playTrackNumber:self.currentTrackNumber + 1 atTime:0 seekToTime:YES completion:completion];
            }
            else {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    self.showMaxSongSkipsReachedAlertWhenAppBecomesActive = NO;
                    [UIAlertView showWithTitle:@"Sorry!" message:MAX_SONG_CHANGES_REACHED handler:nil];
                }
                else {
                    self.showMaxSongSkipsReachedAlertWhenAppBecomesActive = YES;
                }
            }
        }
        else {
            [self playTrackNumber:self.currentTrackNumber + 1 atTime:0 seekToTime:YES completion:completion];
        }
    }
}



- (void)playPreviousTrackWithCompletion:(void(^)(BOOL finished))completion {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([appState isTimeExpiredForCurrentUser]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
                if (params.handlerType == TPAlertViewDidDismiss) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                }
            }];
        }
    }
    else if ([appState isAccountExpiredForCurrentUser])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
                if (params.handlerType == TPAlertViewDidDismiss) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                }
            }];
        }
    }
    else {
        NSString *strUserSubcriptionId = appState.currentUser.subscriptionId;
        if ([strUserSubcriptionId isEqualToString:@"3"] || [strUserSubcriptionId isEqualToString:@"8"] || [strUserSubcriptionId isEqualToString:@"9"]) {
            NSString *userId = appState.currentUser.userId;
            NSDictionary *dictSkipped= [appState skippedSongCountForUserId:userId];
            if ([self timeDifferenceBetween:dictSkipped]) {
                dictSkipped= [appState skippedSongCountForUserId:userId];
                NSString *strCount = [NSString stringWithFormat:@"%ld",([[dictSkipped valueForKey:@"SkippedSongCount"] integerValue] + 1)];
                [appState setSkippedSongCount:strCount forUserId:userId AndWithDateTime:[dictSkipped valueForKey:@"SkippedStartingDateTime"]];
                [self playTrackNumber:self.currentTrackNumber - 1 atTime:0 seekToTime:YES completion:completion];
            }
            else {
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                    [UIAlertView showWithTitle:@"Sorry!" message:MAX_SONG_CHANGES_REACHED handler:nil];
                }
            }
        }
        else {
            [self playTrackNumber:self.currentTrackNumber - 1 atTime:0 seekToTime:YES completion:completion];
        }
    }
}

- (void)playNextTrackButDontSeekToTimeWithCompletion:(void(^)(BOOL finished))completion {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if ([appState isTimeExpiredForCurrentUser]) {
        [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        [self cleanUpPlayer];
    }
    else {
        [self playTrackNumber:self.currentTrackNumber + 1 atTime:0 seekToTime:NO completion:nil];
    }
}

- (void)playTrackNumber:(NSInteger)trackNumber atTime:(NSTimeInterval)time seekToTime:(BOOL)shouldSeek completion:(void(^)(BOOL finished))completion {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    // increment to the next track number
    self.currentTrackNumber = trackNumber;
    self.currentTrackTime = time;
    if (shouldSeek) {
        double seekToTime = [appState.currentPlayListInfo.songStartTimes[_currentTrackNumber] doubleValue] + time;
        // send the player a seek-to-time message
        [self.player seekToTime:CMTimeMake(seekToTime, 1) completionHandler:completion];
    }
}

-(BOOL)timeDifferenceBetween:(NSDictionary *)dictSkippedData
{
    [SWLogger logEventWithObject:self selector:_cmd];
    NSString *strSkippedCount = [dictSkippedData valueForKey:@"SkippedSongCount"];
    NSString *strSkippedDateTime  = [dictSkippedData valueForKey:@"SkippedStartingDateTime"];
    
    if ([strSkippedCount integerValue] < kMaxNumberOfSongChanges) {
        if ([strSkippedCount integerValue] == 0) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            [appState setSkippedSongCount:@"0" forUserId:appState.currentUser.userId AndWithDateTime:[dateFormat stringFromDate:[NSDate date]]];
        }
        return TRUE;
    }
    else {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *nowDate = [dateFormat dateFromString:[dateFormat stringFromDate:[NSDate date]]];
        NSDate *oldDate = [dateFormat dateFromString:strSkippedDateTime];
        NSTimeInterval secondsBetween = [nowDate timeIntervalSinceDate:oldDate];
        float numberOfHours = secondsBetween / 3600;
        
        if (numberOfHours > 1) {
            [appState setSkippedSongCount:@"0" forUserId:appState.currentUser.userId AndWithDateTime:[dateFormat stringFromDate:[NSDate date]]];
            return TRUE;
        }
        else {
            return FALSE;
        }
    }
}
// Keep this here to be able to unwind back to the player!
- (IBAction)unwindToPlayer:(UIStoryboardSegue *)segue {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
}


#pragma mark - Timers
//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer {
    // checks to make sure there is a bitrate... (that the player is actually playing something!)
    [SWLogger logEventWithObject:self selector:_cmd];
    if (self.isPlaying) {
        // update the currentTime within the Playlist.
        // progress reports zero if the file is still being buffered..
        if ([self availableDuration] < appState.currentPlayListInfo.totalLength) {
            self.currentPlayListTime += 1;
        }
        else {
            self.currentPlayListTime = [self availableDuration];
        }
        // Check for track change.
        if ((appState.currentSong.songLength - self.currentTrackTime) <= 0) {
            [self playNextTrackButDontSeekToTimeWithCompletion:nil];
        }
        // display the current time within the playlist
        self.lblDuration.text = [SWDateTimeHelper convertTimeFullFormat:(appState.currentPlayListInfo.totalLength - self.currentPlayListTime)];
        // display the current time within the song's duration
        self.currentTrackTime += 1;
        appState.currentPlayList.currentTrackTime = self.currentTrackTime;
        self.lblProgress.text = [SWDateTimeHelper convertTimeMinSec:(appState.currentSong.songLength - self.currentTrackTime)];
        if (appState.currentSong.songLength > 0) {
            CGFloat progress = self.currentTrackTime / appState.currentSong.songLength;
            [UIView animateWithDuration:0.5 animations:^{
                self.progressBarWidth.constant = [[NSNumber numberWithFloat:(progress * self.progressBar.frame.size.width)] floatValue];
            }];
        }
        else {
            self.progressBarWidth.constant = 0;
        }
        if (![appState currentUserHasUnlimitedAccount]) {
            NSTimeInterval timeLeftInSeconds = [appState timeLeftForCurrentUser];
            self.timeRemainingView.hidden = NO;
            if (timeLeftInSeconds <= 0.0) {
                self.timeRemainingLabel.text = @"EXPIRED";
                [self pause];
                [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
                    if (params.handlerType == TPAlertViewDidDismiss) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                    }
                }];
                return;
            }
            NSString *timeRemainingStr;
            NSInteger hoursLeft = (NSInteger)(timeLeftInSeconds / 3600.0);
            NSInteger minutesLeft = (NSInteger)((timeLeftInSeconds - hoursLeft*3600) / 60.0);
            NSInteger secondsLeft = (NSInteger)(timeLeftInSeconds - hoursLeft*3600 - minutesLeft*60);
            timeRemainingStr = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)hoursLeft, (long)minutesLeft, (long)secondsLeft];
            self.timeRemainingLabel.text = timeRemainingStr;
            [appState setTimeLeftForCurrentUser:(timeLeftInSeconds - 1)];
        }
        else {
            self.timeRemainingLabel.text = @"";
            self.timeRemainingView.hidden = YES;
        }
    }
    else {
        //        NSLog(@"stop");
    }
}

#pragma mark - Methods
- (void)loadPlayListWithURL:(NSURL *)url completion:(void(^)(NSError *error))completion {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSString *tracksKey = @"tracks";
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
            if (status == AVKeyValueStatusLoaded) {
                if (self.playerItem) {
                    self.playerItem = nil;
                }
                if (self.player) {
                    [self pause];
                    self.player = nil;
                }
                /*
                 NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                 [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 NSDate *now = [[NSDate alloc] init];
                 NSString *theDateTime = [dateFormat stringFromDate:now];
                 
                 NSString *userId = appState.currentUser.userId;
                 [appState setSkippedSongCount:@"0" forUserId:userId AndWithDateTime:theDateTime];
                 */
                
                self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
                self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
                
                // start timer
                if (self.progressTimer) {
                    [self.progressTimer invalidate];
                    self.progressTimer = nil;
                }
                self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
                
                // Prevent phone from going to sleep
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                if (completion) {
                    completion(nil);
                }
            }
            else {
                // Deal with the error appropriately.
                NSLog(@"An error occurred loading tracks");
                if (completion) {
                    completion(error);
                }
            }
        });
    }];
}

- (void)cleanUpPlayer {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [UIApplication sharedApplication].idleTimerDisabled = NO;     // Enable phone to go back to sleep
    [SVProgressHUD dismiss];
    [self pause]; // stop the player
    self.player = nil;  // release the player
    
    // Kill the progress timer
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressTimer) {
            NSLog(@"progress time ==== %f",self.progressTimer.timeInterval);
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
        [self stopTimeTrackingTimer];
        NSLog(@"Completed Execution of - %s", __PRETTY_FUNCTION__);
    });
}

- (void)cleanUpPlayer_AndCompletionHandler:(void (^)(bool success))completionHandler {
    NSLog(@"sid : %s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [UIApplication sharedApplication].idleTimerDisabled = NO;     // Enable phone to go back to sleep
    [SVProgressHUD dismiss];
    [self pause];     // stop the player
    self.player = nil;     // release the player
    self.playerItem = nil;
    // Kill the progress timer
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressTimer) {
            NSLog(@"progress time ==== %f",self.progressTimer.timeInterval);
            [self.progressTimer invalidate];
            self.progressTimer = nil;
        }
        [self stopTimeTrackingTimer_AndCompletionHandler:^(bool success) {
            NSLog(@"sid :%s", __PRETTY_FUNCTION__);
            [self removeObservers];
            completionHandler(TRUE);
        }];
        NSLog(@"Completed Execution of - %s", __PRETTY_FUNCTION__);
    });
}


#pragma mark - AVPlayer Notifications
- (void)playerItemDidPlayToEnd:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%@", notification.name);
    [self playNextTrackButDontSeekToTimeWithCompletion:nil];     // PlayList finished...  start from beginning?
    self.isBuffering = NO;
}

- (void)playerItemTimeJumped:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
}

- (void)playerItemFailedToPlayToEnd:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%@", notification.name);
    NSDictionary *notice = [notification userInfo];
    if (notice != nil) {
        NSError *errorInfo = notice[AVPlayerItemFailedToPlayToEndTimeErrorKey];
        if (errorInfo != nil) {
            NSLog(@"%@",errorInfo.localizedDescription);
            [UIAlertView showWithMessage:errorInfo.localizedDescription handler:nil];
        }
    }
}

- (void)playerItemPlaybackStalled:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%@", notification.name);
    if (!self.isPlaying) {
        [self play];
    }
    
    NSDictionary *notice = [notification userInfo];
    if (notice != nil) {
        NSError *errorInfo = notice[@"error"];
        if (errorInfo != nil) {
            NSLog(@"%@",errorInfo.localizedDescription);
        }
    }
}

- (NSTimeInterval)availableDuration {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    if (loadedTimeRanges.count > 0) {
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        Float64 startSeconds = CMTimeGetSeconds(timeRange.start);
        Float64 durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;
        return result;
    }
    return 0;
}


#pragma mark - SongListViewControllerDelegate Methods
- (BOOL)songListViewControllerDelegate:(SWSongsViewController *)controller didTapTrack:(int)trackNumber withCompletion:(void(^)(BOOL finished))completion {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([appState isTimeExpiredForCurrentUser]) {
        [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return NO;
    }
    else if ([appState isAccountExpiredForCurrentUser])
    {
        [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return NO;
    }
    else {
        NSString *strUserSubcriptionId = appState.currentUser.subscriptionId;
        if ([strUserSubcriptionId isEqualToString:@"3"] || [strUserSubcriptionId isEqualToString:@"8"] || [strUserSubcriptionId isEqualToString:@"9"]) {
            NSString *userId = appState.currentUser.userId;
            NSDictionary *dictSkipped= [appState skippedSongCountForUserId:userId];
            if ([self timeDifferenceBetween:dictSkipped]) {
                dictSkipped= [appState skippedSongCountForUserId:userId];
                NSString *strCount = [NSString stringWithFormat:@"%ld",([[dictSkipped valueForKey:@"SkippedSongCount"] integerValue] + 1)];
                [appState setSkippedSongCount:strCount forUserId:userId AndWithDateTime:[dictSkipped valueForKey:@"SkippedStartingDateTime"]];
                [self playTrackNumber:trackNumber atTime:0 seekToTime:YES completion:completion];
                return YES;
            }
            else {
                [UIAlertView showWithTitle:@"Sorry!" message:MAX_SONG_CHANGES_REACHED handler:nil];
                return NO;
            }
        }
        else {
            [self playTrackNumber:trackNumber atTime:0 seekToTime:YES completion:completion];
            return YES;
        }
    }
}

#pragma mark -
-(void)cleanPlayerRequestFromSongsViewController:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:sender];
}

#pragma mark - Start Time For Account Timer
- (void)startTimeTrackingTimer {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.timeTrackingTimer) {
        [self.timeTrackingTimer invalidate];
        self.timeTrackingTimer = nil;
        self.lastTimeTrackerTimerFireTime = CACurrentMediaTime();
        self.timeTrackingTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateTimeTrackerTimer:) userInfo:nil repeats:YES];
    }
}

#pragma mark - Stop Time For Main Accout Timer
- (void)stopTimeTrackingTimer {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.timeTrackingTimer) {
        [self.timeTrackingTimer invalidate];
        self.timeTrackingTimer = nil;
        NSTimeInterval elapsedTime = CACurrentMediaTime() - self.lastTimeTrackerTimerFireTime;
        [self trackElapsedTime:elapsedTime];
    }
}

#pragma mark - Stop Time For Main Accout Timer With Bolck Handler
- (void)stopTimeTrackingTimer_AndCompletionHandler:(void (^)(bool success))completionHandler {
    NSLog(@"sid : %s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    if (self.timeTrackingTimer) {
        [self.timeTrackingTimer invalidate];
        self.timeTrackingTimer = nil;
        NSTimeInterval elapsedTime = CACurrentMediaTime() - self.lastTimeTrackerTimerFireTime;
        [self trackElapsedTime:elapsedTime AndCompletionHandler:^(bool success) {
            completionHandler(TRUE);
        }];
    }else{
        completionHandler(TRUE);
    }
}

- (void)updateTimeTrackerTimer:(NSTimer *)timer {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.lastTimeTrackerTimerFireTime = CACurrentMediaTime();
    NSTimeInterval elapsedTime = timer.timeInterval;
    [self trackElapsedTime:elapsedTime];
}

- (void)trackElapsedTime:(NSTimeInterval)elapsedTime {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [[SWAPI sharedAPI] setTimeTracked:appState.currentUser.userId withTime:@((NSUInteger)ceil(elapsedTime)) completion:^(NSDictionary *data, NSError *error) {
        NSLog(@"Last SetTimeTracked response: %@", data[@"timeRemaining"]);
    }];
}

#pragma mark - Track Elapsed Time
- (void)trackElapsedTime:(NSTimeInterval)elapsedTime AndCompletionHandler:(void (^)(bool success))completionHandler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [[SWAPI sharedAPI] setTimeTracked:appState.currentUser.userId withTime:@((NSUInteger)ceil(elapsedTime)) completion:^(NSDictionary *data, NSError *error) {
        NSLog(@"Last SetTimeTracked response Sid: %@", data[@"timeRemaining"]);
        completionHandler(TRUE);
        
    }];
}

#pragma mark - KVO (Player)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
    [SWLogger logEventWithObject:self selector:_cmd];
    // PlayerTimeRangesContext
    if (context == &PlayerTimeRangesContext) {
        if (_isBuffering) {
            double newDuration = [self availableDuration];
            double dChange = newDuration - self.oldDuration;
            if (dChange > 10.f) {
                self.isBuffering = NO;
                if (self.wasPlaying) {
                    [self play];
                }
            }
        }
        return;
    }
    // PlayerItemStatusContext
    if (context == &PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (self.playerItem.status) {
                case AVPlayerItemStatusFailed: {
                    [SVProgressHUD dismiss];
                    break;
                }
                case AVPlayerItemStatusReadyToPlay: {
                    [SVProgressHUD dismiss];
                    
                    // We are playing.. change button to pause
                    [self.activity performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:TRUE];
                    // Hide the activity spinner
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self.wasPlaying) {
                            [self play];
                            self.btnPlayPause.selected = YES;
                        }
                        else {
                            [self pause];
                        }
                    });
                    
                    
                    //                    [self.honeycombView startAnimatingImmediately:NO];
                    break;
                }
                case AVPlayerItemStatusUnknown:
                    break;
            }
        });
        return;
    }
    
    // PlayerItemBufferEmptyContext
    if (context == &PlayerItemBufferEmptyContext) {
        NSLog(@"PlayerItemBufferEmptyContext");
        if (self.playerItem.isPlaybackBufferEmpty) {
                        if (!_isBuffering) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activity performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:TRUE];
                [self pause];
            });
            self.oldDuration = [self availableDuration];
            self.isBuffering = YES;
                        }
        }
        else if (self.playerItem.isPlaybackBufferFull) {
            self.isBuffering = NO; //Playbuck buffer full
        }
        else {
            self.isBuffering = NO;
        }
        
        return;
    }
    
    // 	PlayerStatusContext
    if (context == &PlayerStatusContext) {
        switch (self.player.status) {
            case AVPlayerStatusFailed:
                NSLog(@"Player Status Failed");
                break;
            case AVPlayerStatusReadyToPlay:
                NSLog(@"Player Status ReadToPlay");
                break;
            case AVPlayerStatusUnknown:
                NSLog(@"Player Status Unknown");
                break;
            default:
                break;
        }
        return;
    }
    // 	PlayerRateContext
    if (context == &PlayerRateContext) {
        NSLog(@"PlayerRateContext: Rate Changed: %f", self.player.rate);
        if (!self.isPlaying) {
            self.btnPlayPause.selected = NO;
            [self.honeycombView stopAnimatingImmediately:NO];
            [self stopTimeTrackingTimer];
        }
        else {
            self.btnPlayPause.selected = YES;
            [self startTimeTrackingTimer];
            [self.honeycombView startAnimatingImmediately:NO];
        }
        if ([self.delegate respondsToSelector:@selector(playerViewController:didChangePlayStatus:)]) {
            [self.delegate playerViewController:self didChangePlayStatus:self.isPlaying];
        }
        return;
    }
    
    // PlayerErrorContext
    if (context == &PlayerErrorContext) {
        NSLog(@"PlayerErrorContext: Error Occured");
        if (self.player.error != nil) {
            NSLog(@"AVPlayer: %ld -- %@", (long)self.player.error.code, self.player.error.localizedDescription);
        }
        return;
    }
    // must be called.
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Social Media Sharing
-(void)sharingStatus {
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        self.btnTwitterButton.enabled = YES;
    } else {
        self.btnTwitterButton.enabled = NO;
    }
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([results objectForKey:@"postId"]) {
        [UIAlertView showWithMessage:@"Facebook Post Successfully Posted." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
        }];
        
        [[SWAPI sharedAPI] streamShareReport_WitStreamID:appState.currentPlayList.streamId shareFB:@"1" shareTW:@"0" shareGP:@"0"AndCompletion:^(BOOL success, NSError *error) {
            if (success)
            {
                NSLog(@"streamShareReport_WitStreamID FB success");
            }
            else
            {
                NSLog(@"streamShareReport_WitStreamID FB error");
            }
        }];
        
    }
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [SWLogger logEventWithObject:self selector:_cmd];
    [UIAlertView showWithMessage:@"Facebook Post UnSuccessfully Posted.\n Please Try Agin Later." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
        
    }];
}


-(void)facebookPostWithData {
    [SWLogger logEventWithObject:self selector:_cmd];
    /*
     FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
     
     content.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.stingwax.com/images/Stingwax_Share.png"]];
     content.contentURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://stingwax.com"]];
     content.contentTitle = [NSString stringWithFormat:@"Getting Stung in the mix with Stingwax Digital DJ Service"];
     content.contentDescription = [NSString stringWithFormat:@"\nTrack:%@ \nArtist:%@",appState.currentSong.songStream,appState.currentSong.songArtist];
     
     [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
     */
    
}

-(void)facebookPost:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    
//    NSString *strCurrentSong = [NSString stringWithFormat:@"Getting Stung in the mix with Stingwax Digital DJ Service.\nJamming to %@", appState.currentSong.songStream];
//    mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//    [mySLComposerSheet setInitialText:strCurrentSong];
//    [mySLComposerSheet addImage:[UIImage imageNamed:@"Stingwax_Share"]];
//    [mySLComposerSheet addURL:[NSURL URLWithString:@"http://stingwax.com"]];
//    
//    
//    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//        switch (result) {
//            case SLComposeViewControllerResultCancelled:
//                NSLog(@"Post Canceled");
//                break;
//            case SLComposeViewControllerResultDone: {
//                [UIAlertView showWithMessage:@"Facebook Post Successfully Posted." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
//                }];
//                break;
//            }
//            default:
//                break;
//        }
//    }];
    
    
//    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
//        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
////        NSString *strCurrentSong = [NSString stringWithFormat:@"Getting Stung in the mix with Stingwax Digital DJ Service.\nTrack:%@\nArtist:%@",appState.currentSong.songStream,appState.currentSong.songArtist];
//        NSString *strCurrentSong = @"Getting Stung in the mix with Stingwax Digital DJ Service";
//        
//        [mySLComposerSheet setInitialText:strCurrentSong];
////        [mySLComposerSheet addImage:[UIImage imageNamed:@"Stingwax_Share"]];
////                [mySLComposerSheet addURL:[NSURL URLWithString:@"http://stingwax.com"]];
//        
//        
//        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
//            switch (result) {
//                case SLComposeViewControllerResultCancelled:
//                    NSLog(@"Post Canceled");
//                    break;
//                case SLComposeViewControllerResultDone: {
//                    [UIAlertView showWithMessage:@"Facebook Post Successfully Posted." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
//                    }];
//                    break;
//                }
//                default:
//                    break;
//            }
//        }];
//        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
//    }
    
    
    if ([FBSDKAccessToken currentAccessToken])
    {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"https://stingwax.com"];
        content.contentTitle = @"Getting Stung in the mix with Stingwax Digital DJ Service";
        content.contentDescription = [NSString stringWithFormat:@"Jamming to %@", appState.currentSong.songStream];
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.delegate = self;
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeNative;
        if (![dialog canShow])
        {
            dialog.mode = FBSDKShareDialogModeFeedWeb;
        }
        [dialog show];
//        [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
    }
    else
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithReadPermissions:@[@"public_profile"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error)
            {
                [login logOut];
                [FBSDKAccessToken setCurrentAccessToken:nil];
                [FBSDKProfile setCurrentProfile:nil];
            }
            else if (result.isCancelled)
            {
                [login logOut];
                [FBSDKAccessToken setCurrentAccessToken:nil];
                [FBSDKProfile setCurrentProfile:nil];
            }
            else
            {
                FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
                content.contentURL = [NSURL URLWithString:@"https://stingwax.com"];
                content.contentTitle = @"Getting Stung in the mix with Stingwax Digital DJ Service";
                content.contentDescription = [NSString stringWithFormat:@"Jamming to %@", appState.currentSong.songStream];
                
                FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
                dialog.delegate = self;
                dialog.fromViewController = self;
                dialog.shareContent = content;
                dialog.mode = FBSDKShareDialogModeNative;
                if (![dialog canShow])
                {
                    dialog.mode = FBSDKShareDialogModeFeedWeb;
                }
                [dialog show];
//                [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
            }
        }];
    }
    

    
    /*
     if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
     [self facebookPostWithData];
     }
     else {
     FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
     [FBSDKAccessToken setCurrentAccessToken:nil];
     [FBSDKProfile setCurrentProfile:nil];
     [login setLoginBehavior:FBSDKLoginBehaviorBrowser];
     [login logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
     if (error) {
     // Process error
     [login logOut];
     [FBSDKAccessToken setCurrentAccessToken:nil];
     [FBSDKProfile setCurrentProfile:nil];
     } else if (result.isCancelled) {
     // Handle cancellations
     [login logOut];
     [FBSDKAccessToken setCurrentAccessToken:nil];
     [FBSDKProfile setCurrentProfile:nil];
     } else {
     // If you ask for multiple permissions at once, you
     // should check if specific permissions missing
     [self facebookPostWithData];
     }
     }];
     }
     */
}


-(void)twitterPost:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//    [composeController setInitialText:[NSString stringWithFormat:@"Getting Stung in the mix with Stingwax Digital DJ Service.\nTrack:%@\nArtist:%@",appState.currentSong.songStream,appState.currentSong.songArtist]];
    [composeController setInitialText:@"Getting Stung in the mix"];
    [composeController addImage:[UIImage imageNamed:@"Stingwax_Share"]];
    [composeController addURL:[NSURL URLWithString: @"http://stingwax.com"]];
    
    [self presentViewController:composeController animated:YES completion:nil];
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                NSLog(@"Post Canceled");
                break;
            case SLComposeViewControllerResultDone: {
                [UIAlertView showWithMessage:@"Twitter Post Successfully Posted." cancelButtonTitle:@"Okay" otherButtonTitles:nil handler:^(TPAlertViewHandlerParams *const params) {
                }];
                
                [[SWAPI sharedAPI] streamShareReport_WitStreamID:appState.currentPlayList.streamId shareFB:@"0" shareTW:@"1" shareGP:@"0"AndCompletion:^(BOOL success, NSError *error) {
                    if (success)
                    {
                        NSLog(@"streamShareReport_WitStreamID TW success");
                    }
                    else
                    {
                        NSLog(@"streamShareReport_WitStreamID TW error");
                    }
                    
                }];
                
                break;
            }
            default:
                break;
        }
    };
    composeController.completionHandler =myBlock;
}

-(void)googlePlusPost:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    [SVProgressHUD showWithStatus:@"Authenticating" maskType:SVProgressHUDMaskTypeGradient];
    [self shareBuilder];
}

#pragma mark - GPPSignInDelegate
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                  error:(NSError *)error {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (error) {
        [SVProgressHUD dismiss];
        return;
    }
    else {
        [self.btnGPPSignInButton setHidden:TRUE];
        [self.btnGooglePlus setHidden:FALSE];
        [self shareBuilder];
    }
}

- (id<GPPShareBuilder>)shareBuilder {
    [SWLogger logEventWithObject:self selector:_cmd];
    // End editing to make sure all changes are saved to _shareConfiguration.
    [self.view endEditing:YES];
    [SVProgressHUD dismiss];
    id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
    [[GPPShare sharedInstance] setDelegate:self];
    [shareBuilder setTitle:@"Getting Stung in the mix with Stingwax Digital DJ Service"
               description:[NSString stringWithFormat:@"Track:%@ | Artist:%@ | https://stingwax.com",appState.currentSong.songStream,appState.currentSong.songArtist]
              thumbnailURL:[NSURL URLWithString:@"https://www.stingwax.com/images/Stingwax_Share.png"]];
    [shareBuilder setContentDeepLinkID:@"https://stingwax.com"];
    [shareBuilder open];
    return shareBuilder;
}

#pragma mark - GPPShareDelegate
- (void)finishedSharingWithError:(NSError *)error {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSString *text;
    if (!error) {
        text = @"Success";
    } else if (error.code == kGPPErrorShareboxCanceled) {
        text = @"Canceled";
    } else {
        text = [NSString stringWithFormat:@"Error (%@)", [error localizedDescription]];
    }
    _shareStatus = [NSString stringWithFormat:@"Status: %@", text];
    [[SWAPI sharedAPI] streamShareReport_WitStreamID:appState.currentPlayList.streamId shareFB:@"0" shareTW:@"0" shareGP:@"1"AndCompletion:^(BOOL success, NSError *error) {
        if (success)
        {
            NSLog(@"streamShareReport_WitStreamID GP success");
        }
        else
        {
             NSLog(@"streamShareReport_WitStreamID GP error");
        }
        
    }];
}

#pragma mark - AVAudioSessionInterruptionNotification Handler

- (void)audioSessionInterruptionHandler:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *userInfo = notif.userInfo;
    if ([userInfo[AVAudioSessionInterruptionTypeKey] isEqualToNumber:@(AVAudioSessionInterruptionTypeBegan)]) {
        // Interruption Began
        NSLog(@"Begin");
        [self pause];
        self.isBeingInterrupted = YES;
    }
    else if ([userInfo[AVAudioSessionInterruptionTypeKey] isEqualToNumber:@(AVAudioSessionInterruptionTypeEnded)]) {
        // Interruption Ended
        NSLog(@"ENDED");
        self.isBeingInterrupted = NO;
// Never resume
//        if ([userInfo[AVAudioSessionInterruptionOptionKey] isEqualToNumber:@(AVAudioSessionInterruptionOptionShouldResume)]) {
//            // Should resume playing
//            if (self.wasPlaying) {
//                NSLog(@"Playing Music");
//                if (!self.isBeingInterruptedByCall) {
//                    [self play];
//                }
//            } else {
//                NSLog(@"Pause Music");
//                [self pause];
//            }
//        }
//        else {
//            // Should not resume playing
//        }
    }
}

#pragma mark - AVAudioSessionMediaServicesWereResetNotification

- (void)audioSessionMediaServicesReset {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - AVAudioSessionRouteChangeBotification

-(void)audioSessionRouteChanged:(NSNotification*)notification{
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    NSLog(@"Previous Route = %@",prevRoute);
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            if (prevRoute.outputs) {
                if (prevRoute.outputs.count > 0) {
                    AVAudioSessionPortDescription *port = [prevRoute.outputs objectAtIndex:0];
                    if (port.portType == AVAudioSessionPortBluetoothLE || port.portType == AVAudioSessionPortBluetoothHFP) {
                        [self pause];
                        break;
                    }else{
                        if (self.wasPlaying) {
                            [self play];
                        }
                        else {
                            [self pause];
                        }
                    }
                }
            }else{
                if (self.wasPlaying) {
                    [self play];
                }
                else {
                    [self pause];
                }
                
            }
            
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            seccReason = @"A preferred new audio output path is now available.";
            if (self.wasPlaying) {
                [self play];
            }
            else {
                [self pause];
            }
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
}

#pragma mark - Notifications
- (void)applicationDidEnterBackgroundNotif:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    
    [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
    
    NSLog(@"viewControllers%@",[self.navigationController viewControllers]);
    if (!self.isPlaying) {
        // If we're not playing anymore and we leave the app, then we should not receive any more remote control events.
        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
        //        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
    
}

- (void)applicationWillEnterForegroundNotif:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    // Re-register for receiving remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (self.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
}

- (void)applicationDidBecomeActiveNotif:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if ([[SWAPI sharedAPI] isValidSession]) {
        [SWLogger logEventWithObject:self selector:_cmd];
        if (self.showSubscriptionAlertWhenAppBecomesActive) {
            self.showSubscriptionAlertWhenAppBecomesActive = NO;
            self.showMaxSongSkipsReachedAlertWhenAppBecomesActive = NO;
            [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
                if (params.handlerType == TPAlertViewDidDismiss) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
                }
            }];
        }
        else if (self.showMaxSongSkipsReachedAlertWhenAppBecomesActive) {
            if (self.isPlaying == FALSE) {
                if ([[SWAPI sharedAPI] isValidSession]) {
                    [appState tryRestartingPreviousSessionForUserId:appState.currentUser.userId];
                }
            }
            
            self.showMaxSongSkipsReachedAlertWhenAppBecomesActive = NO;
            [UIAlertView showWithTitle:@"Sorry!" message:MAX_SONG_CHANGES_REACHED handler:nil];
        }
        else {
            if (self.wasPlaying == FALSE && self.wasResumeByCall == FALSE) {
                if ([[SWAPI sharedAPI] isValidSession]) {
                    if ([[appDelegate.Tab0NavBarcontroller topViewController] isKindOfClass:[SWPlayerViewController class]]) {
                        NSString *cancelButtonTitle = @"New Session";
                        NSString *resumePlayingTitle = @"Resume Playing";
                        [UIAlertView showWithTitle:@"Resume Previous Session"
                                           message:@"Would you like to resume playing from where you left off last time?"
                                 cancelButtonTitle:cancelButtonTitle
                                 otherButtonTitles:@[resumePlayingTitle]
                                           handler:^(TPAlertViewHandlerParams *const params) {
                                               if (params.handlerType == TPAlertViewTappedButton) {
                                                   if ([params.buttonTitle isEqualToString:cancelButtonTitle]) {
                                                       [appState clearPlaylistAndSongInfoForUserId:appState.currentUser.userId];
                                                       if ([self presentedViewController]) {
                                                           [[self presentedViewController] dismissViewControllerAnimated:TRUE completion:^{
                                                               [appDelegate.mainTabBarcontroller setSelectedIndex:0];
                                                               [appDelegate.Tab0NavBarcontroller popToRootViewControllerAnimated:TRUE];
                                                           }];
                                                       }
                                                       else {
                                                           [appDelegate.mainTabBarcontroller setSelectedIndex:0];
                                                           [appDelegate.Tab0NavBarcontroller popToRootViewControllerAnimated:TRUE];
                                                       }
                                                   }
                                                   else if ([params.buttonTitle isEqualToString:resumePlayingTitle]) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                           [self play];
                                                           if ([self presentedViewController]) {
                                                               [[self presentedViewController] dismissViewControllerAnimated:TRUE completion:^{
                                                               }];
                                                           }
                                                       });
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
                    else {
                        [appState tryRestartingPreviousSessionForUserId:appState.currentUser.userId];
                    }
                }
            }
            else {
                NSLog(@"SwPlayerViewControllr After DidBecome Active With TopViewContoller:%@",[self.navigationController topViewController]);
            }
        }
    }
}

- (void)handleSessionInvalidation:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    [self cleanUpPlayer];
    [super handleSessionInvalidation:notif];
}

- (void)stingWaxRemoteControlReceived:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    UIEvent *event = notif.object;
    if (event.type != UIEventTypeRemoteControl) {
        return; }
    switch(event.subtype) {
        case UIEventSubtypeRemoteControlPlay: {
            [self play];
            break; }
        case UIEventSubtypeRemoteControlPause: {
            [self pause];
            break; }
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            [self tapPlayPause:nil];
            break; }
        case UIEventSubtypeRemoteControlNextTrack: {
            [self playNextTrack];
            break; }
        case UIEventSubtypeRemoteControlPreviousTrack: {
            [self playPreviousTrack];
            break; }
        case UIEventSubtypeRemoteControlStop: {
            [self pause];
            break; }
        case UIEventSubtypeNone:
        case UIEventSubtypeMotionShake:
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlBeginSeekingForward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            break;
    }
}

-(void)notificationForPlayerStatus:(NSNotification *)notification {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (self.isPlaying) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SWMyPlayerRunningNotification object:@1];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SWMyPlayerRunningNotification object:@0];
    }
}

#pragma mark - Prepare For Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [SWLogger logEventWithObject:self selector:_cmd];
    if ([segue.identifier isEqualToString:@"SongListSegue"]) {
        UINavigationController *navC = segue.destinationViewController;
        [navC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        self.songListViewController = (id)navC.topViewController;
        self.songListViewController.delegate = self;
        self.songListViewController.currentTrackNumber = self.currentTrackNumber; // set the track number to display which track is playing.
        //        self.songListViewController.backgorundImage = [self captureView];
    }
    else if ([segue.identifier isEqualToString:@"Honeycomb"]) {
        self.honeycombViewController = segue.destinationViewController;
        [self.honeycombViewController view];    // force view to load
        self.honeycombView = self.honeycombViewController.honeycombView;
        [self.honeycombViewController.honeycombView.topHoneycomb removeFromSuperview];
        [self.honeycombViewController.honeycombView.leftHoneycomb removeFromSuperview];
        [self.honeycombViewController.honeycombView.rightHoneycomb removeFromSuperview];
    }
}

- (UIImage *)captureView
{
    [SWLogger logEventWithObject:self selector:_cmd];
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    [SWLogger logEventWithObject:self selector:_cmd];
    return UIStatusBarStyleLightContent;
}

-(void)viewDidDisappear:(BOOL)animated {
    [SWLogger logEventWithObject:self selector:_cmd];
    [[NSNotificationCenter defaultCenter] removeObserver:ACAccountStoreDidChangeNotification];
}
@end
