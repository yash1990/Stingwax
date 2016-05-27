//
//  PlayerViewController.h
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import <UIKit/UIKit.h>
#import "SWBaseViewController.h"
#import "SWSongsViewController.h"
#import "SWHoneycombViewController.h"
#import "SWHoneycombView.h"
#import "SWPolygonView.h"
#import "SWAPI.h"
#import "SWAppState.h"
#import "SWLogger.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "SWDateTimeHelper.h"
#import "StingWax-Constant.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <GooglePlus/GPPSignInButton.h>

@class SWPlaylist;
@protocol SWPlayerViewControllerDelegate;

@interface SWPlayerViewController : SWBaseViewController
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, weak) id<SWPlayerViewControllerDelegate> delegate;
- (void)loadPlaylist:(SWPlaylist *)playlist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime;
- (void)cleanUpPlayer;
- (void)cleanUpPlayer_AndCompletionHandler:(void (^)(bool success))completionHandler;

// State
@property (nonatomic) NSInteger currentTrackNumber;
@property (nonatomic) NSInteger totalTrackCount;
@property (nonatomic) NSTimeInterval currentTrackTime;
@property (nonatomic) NSTimeInterval currentPlayListTime; // value stored of where the user is within the total duration of the playlist.
@property (nonatomic) NSTimeInterval oldDuration;
@property (nonatomic) NSTimeInterval lastTimeTrackerTimerFireTime;
@property (nonatomic) NSTimer *progressTimer; // Main threaded timer handling the player at .1 second intervals
@property (nonatomic) NSTimer *timeTrackingTimer;
@property (nonatomic) BOOL isBeingInterrupted;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) BOOL wasPlaying;
@property (nonatomic) BOOL wasResumeByCall;
@property (nonatomic) BOOL isBeingInterruptedByCall;
@property (nonatomic) BOOL isBuffering;
@property (nonatomic) BOOL showSubscriptionAlertWhenAppBecomesActive;
@property (nonatomic) BOOL showMaxSongSkipsReachedAlertWhenAppBecomesActive;

// Outlets
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, weak) IBOutlet UILabel *lblCategoryName;  // Label For Category Name
@property (nonatomic, weak) IBOutlet UILabel *lblSong;                  // Label For Sogn Name
@property (nonatomic, weak) IBOutlet UILabel *lblMix;                     //
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentSong;      // scrolling label
@property (nonatomic, weak) IBOutlet UILabel *lblCurrentSong2;    // scrolling label shown next to the other one when the text is too long
@property (nonatomic, weak) IBOutlet UIButton *btnPlayPause;
@property (nonatomic, weak) IBOutlet UIButton *btnNext;
@property (nonatomic, weak) IBOutlet UIButton *btnPrev;
@property (nonatomic, weak) IBOutlet UILabel  *lblProgress;    // Time Left In Signle Music
@property (nonatomic, weak) IBOutlet UILabel  *lblDuration;    // Time Left In PlayList
@property (nonatomic, weak) IBOutlet UILabel *timeRemainingLabel; // Time Left In Account
@property (nonatomic, weak) IBOutlet UIView  *timeRemainingView; //
@property (nonatomic, weak) IBOutlet UIView *progressBar;
@property (nonatomic) IBOutlet NSLayoutConstraint *progressBarWidth; // Width For Finish Song Time
@property (nonatomic) IBOutlet NSLayoutConstraint *currentSongDistanceFromLeft;
@property (nonatomic) IBOutlet NSLayoutConstraint *heightForVoteView;

// Vote Action
@property(weak, nonatomic) IBOutlet UIView *viewForVote;
@property(weak, nonatomic) IBOutlet UIButton *btn_VoteUp;
@property(weak, nonatomic) IBOutlet UIButton *btn_VoteDown;
-(IBAction)btnThreeDotTapped:(id)sender;
-(IBAction)btnVoteUpTapped:(id)sender;
-(IBAction)btnVoteDownTapped:(id)sender;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *layoutContraint_ViewForVote_Y;

// Other Views
@property (nonatomic) IBOutlet UIButton *btnFav; // Add to favories
@property (nonatomic) IBOutlet UIButton *btnViewSongList; // Go to song list
@property (nonatomic) SWHoneycombView *honeycombView;
-(IBAction)btnFavTapped:(id)sender;
-(IBAction)btnViewSongListTapped:(id)sender;
// Objects

// Social Sharing
@property(weak, nonatomic) IBOutlet UIButton *btnFacebookButton;
@property(weak, nonatomic) IBOutlet UIButton *btnTwitterButton;
@property(weak, nonatomic) IBOutlet UIButton *btnGooglePlus;
@property(weak, nonatomic) IBOutlet GPPSignInButton *btnGPPSignInButton;
- (IBAction)facebookPost:(id)sender;
- (IBAction)twitterPost:(id)sender;
- (IBAction)googlePlusPost:(id)sender;
- (void)sharingStatus;

// View Controllers
@property (nonatomic) SWSongsViewController *songListViewController;
@property (nonatomic) SWHoneycombViewController *honeycombViewController;

// Player objects
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
-(IBAction)btnBackPressed:(id)sender;

@end


@protocol SWPlayerViewControllerDelegate <NSObject>

- (void)playerViewControllerDidFinish:(SWPlayerViewController *)controller;
- (void)playerViewController:(SWPlayerViewController *)controller didChangePlayStatus:(BOOL)isPlaying;

@end
