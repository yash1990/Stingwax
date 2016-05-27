//
//  API.h
//  StingWax
//
//  Created by Mark Perkins on 6/20/13.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "SWUser.h"
#import "SWSong.h"
#import "SWPlaylist.h"
#import "SWPlaylistInfo.h"

#define kSWErrorInvalidLogin 403

typedef void (^FailureResponseBlock)(NSError *error);
typedef void (^DataUserResponseBlock)(SWUser* user, NSError *error);
typedef void (^DataPlayListInfoReponseBlock)(SWPlaylistInfo* playListInfo, NSError *error);

typedef void (^JSONResponseBlock)(NSDictionary* data, NSError *error);
typedef void (^ArrayResponseBlock)(NSMutableArray* data, NSError *error);
typedef void (^BOOLResponseBlock)(BOOL success, NSError *error);
typedef void (^IntegerResponseBlock)(NSInteger data, NSError *error);


@interface SWAPI : AFHTTPRequestOperationManager

+ (SWAPI*)sharedAPI;
@property (nonatomic, getter = isValidSession) BOOL validSession;

- (void)logInWithNewUserData:(NSDictionary *)userData completion:(DataUserResponseBlock)completionBlock;

// user (login/logout/session)
- (void)logInWithUserID:(NSString *)userId password:(NSString *)password completion:(DataUserResponseBlock)completionBlock;
- (void)logInWithFBWithUserID:(NSString *)userId completion:(DataUserResponseBlock)completionBlock;
- (void)logInWithTWWithUserID:(NSString *)userId completion:(DataUserResponseBlock)completionBlock;
- (void)logOutWithCompletion:(BOOLResponseBlock)completionBlock;
- (void)requestPasswordRecovery:(NSString *)recoveryEmail completion:(BOOLResponseBlock)completionBlock;
- (void)sendCarrierInfo_Withcompletion:(BOOLResponseBlock)completionBlock;

//Subscription Plan
- (void)getSubcriptionWithUserId:(NSString *)userId subscriptionID:(NSString *)sub_id completion:(BOOLResponseBlock)completionBlock;

// method below will set a users session invalid
- (void)setTimeTracked:(NSString *)userId withTime:(NSNumber *)timeUsed completion:(JSONResponseBlock)completionBlock;

// Data Gathering
- (void)getPlaylistsForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock;
- (void)getFavoritesForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock;
- (void)getPurePlayListingsForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock;
- (void)getPlayListInfoForPlayListID:(NSString *)streamID withUserID:(NSString *)userId completion:(DataPlayListInfoReponseBlock)completionBlock;
- (void)getNewMixForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock;
- (void)getNewMixCountForUserID:(NSString *)userId completion:(IntegerResponseBlock)completionBlock;
- (void)getUserCategoryNotifyListForUserID:(NSString *)userId completion:(ArrayResponseBlock)completionBlock;

// Data Setting
- (void)setPlayListPlayedForUserID:(NSString *)userId playlist:(SWPlaylist *)playlist completion:(BOOLResponseBlock)completionBlock;
- (void)setSongPlayedForUserID:(NSString *)userId playlist:(SWPlaylist *)playlist playlistInfo:(SWSong *)song completion:(BOOLResponseBlock)completionBlock;

// Set Notification
- (void)setUserCategoryNotifyForUserID:(NSString *)userId CategoryID:(NSString *)catId notificationvalue:(NSString *)notiValue completion:(BOOLResponseBlock)completionBlock;


// Favorites Adding/Removing
- (void)addPlaylistID:(NSString *)playlistID toFavoritesForUserID:(NSString *)userID completion:(BOOLResponseBlock)completion;
- (void)removePlaylistID:(NSString *)playlistID fromFavoritesForUserID:(NSString *)userID completion:(BOOLResponseBlock)completion;

// Vote Up And VoteDown
-(void)voteUpAndVoteDownToCurrentStreamCatID:(NSString *)categoryID AndStreamID:(NSString *)streamID AndVote:(NSString *)vote completion:(JSONResponseBlock)completion;
-(BOOL)voteUpAndVoteDownToCurrentSongCatName:(NSString *)catName AndStreamName:(NSString *)streamName  AndTrackName:(NSString *)trackName AndVote:(NSString *)vote completion:(BOOLResponseBlock)completion;
-(void)streamShareReport_WitStreamID:(NSString *)streamID shareFB:(NSString*)shareFB shareTW:(NSString*)shareTW shareGP:(NSString*)shareGP AndCompletion:(BOOLResponseBlock)completion;

@end
