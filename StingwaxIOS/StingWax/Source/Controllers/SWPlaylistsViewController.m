//
//  SWPlayListViewController.m
//  StingWax
//

#import "SWPlaylistsViewController.h"
#import "SWSubCategoriesViewController.h"
#import "SWMenuViewController.h"

// Private Interface
@interface SWPlaylistsViewController () <UITableViewDataSource, UITableViewDelegate, SWPlaylistSelectionDelegate, SWPlayerViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITabBarControllerDelegate,UITabBarDelegate> {
    SWAppDelegate *appDelegate;
    UIColor *buttonSelectedColor;
    UIColor *buttonUnSelectedColor;
    SWPlaylistCategory *selecetedcategory;
    NSString*strCategoryType;
}

@property(weak, nonatomic) IBOutlet UIView *viewForFavorites;

@property(weak, nonatomic) IBOutlet UIView *viewForTopTwoButton;
@property(weak, nonatomic) IBOutlet UIButton *btnFavorites;
@property(weak, nonatomic) IBOutlet UIButton *btnAllMixes;

@property(weak, nonatomic) IBOutlet UITableView *tblViewFav;

@property (nonatomic) NSMutableArray *dataFavorites;

-(IBAction)btnFavoritesPressed:(id)sender;
-(IBAction)btnAllMixesPressed:(id)sender;


// Controllers
@property (nonatomic) SWPlayerViewController *playerViewController;
// Views

@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying; // holds the now playing button for display after selection of playlist.

// Data
@property (weak,nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (nonatomic) NSMutableArray *playlistCategories; // listing of playlists available for specific user
@property (nonatomic) NSMutableArray *playlistPurePlay; // listing of playlists available for specific user
@end

@implementation SWPlaylistsViewController

#pragma mark - Setters / Mutators
- (void)setPlayerViewController:(SWPlayerViewController *)playerViewController {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (playerViewController) {
        [_playerViewController cleanUpPlayer];
    }
    _playerViewController = playerViewController;
    [self refreshNowPlayingButton];
}

#pragma mark - Setup Style
- (void)setupStyle {
    if (appState.currentPlayList) {
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = [UIColor whiteColor];
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    
    self.viewForTopTwoButton.layer.cornerRadius = 5;
    [self.viewForTopTwoButton setClipsToBounds:TRUE];
    [self.viewForTopTwoButton.layer setBackgroundColor:[UIColor colorWithRed:194/255.0 green:193/255.0 blue:192/255.0 alpha:1].CGColor];
    self.btnFavorites.backgroundColor = buttonUnSelectedColor;
    self.btnAllMixes.backgroundColor = buttonSelectedColor;
    [self.btnAllMixes.layer setCornerRadius:5.0];
    [self.btnFavorites.layer setCornerRadius:5.0];
}

#pragma mark - Object Lifecycle
- (id)init {
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (void)dealloc {
    [self removeObservers];
    //    [appState.currentPlayerViewController cleanUpPlayer];
    //    appState.currentPlayerViewController = nil;
}

-(void)viewDidDisappear:(BOOL)animated {
    [self removeObservers];
}

- (void)addObservers {
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(applicationWillTerminateNotif:) name:UIApplicationWillTerminateNotification object:nil];
    [notifCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotif:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter addObserver:self selector:@selector(handleUserLogOut:) name:SWUserLoggedOutNotification object:nil];
    [notifCenter addObserver:self selector:@selector(handleReloadPreviousSession:) name:SWReloadPlayerNotification object:nil];
    [notifCenter addObserver:self selector:@selector(playerDidLoadPlaylist:) name:SWPlayerDidLoadPlaylist object:nil];
//    [notifCenter addObserver:self selector:@selector(deselectTableViewCell:) name:SWDeselectTableViewCells object:nil];
}

- (void)removeObservers {
//    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
//    [notifCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
//    [notifCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
//    [notifCenter removeObserver:self name:SWUserLoggedOutNotification object:nil];
//    [notifCenter removeObserver:self name:SWReloadPlayerNotification object:nil];
//    [notifCenter removeObserver:self name:SWPlayerDidLoadPlaylist object:nil];
//    [notifCenter removeObserver:self name:SWDeselectTableViewCells object:nil];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [SWAppDelegate sharedDelegate];
    self.playlistCategories = [[NSMutableArray alloc] init];
    self.playlistPurePlay = [[NSMutableArray alloc] init];
    buttonSelectedColor = [UIColor colorWithRed:195/255.0 green:186/255.0 blue:75/255.0 alpha:1];
    buttonUnSelectedColor = [UIColor clearColor];
    [self setupStyle];
    [appDelegate registerForPushNotification];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
    if ([[SWAPI sharedAPI] isValidSession]) {
//        [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"IsAlertShowing"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        [appState tryRestartingPreviousSessionForUserId:appState.currentUser.userId];
    }
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(callEvery5Second) userInfo:nil repeats:TRUE];
}

-(void)callEvery5Second {
    
    NSString *strURL = [NSString stringWithFormat:@"https://stingwax.com/api/cronscript_test_push_create_message_for_user.php?pid=28&clientid=906"];
    NSURL *url = [NSURL URLWithString:strURL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSLog(@"PUSH NOTIFACTION CALLED:%@",response);
     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:FALSE];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    self.tabBarController.delegate = self;
    [self refreshNowPlayingButton];
    if (appState.currentPlayerViewController.isPlaying) {
        self.honeycombView.tintColor = appState.currentPlayList.colorStream;
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        self.wasAnimatingHoneycombView = NO;
        [self.honeycombView stopAnimatingImmediately:NO];
    }
    if (appState.currentPlayerViewController) {
        appState.currentPlayerViewController.delegate = self;
    }
    
    if (self.playlistCategories.count == 0 || self.playlistPurePlay.count == 0) {
        [self loadCoreCategoriesFromweb];
        [self btnAllMixesPressed:nil];
    }
    
    [self loadNewMixesCount];
    
    
    // Must call this after setting wasAnimatingHoneycombView to NO
//    NSString *strL = [NSString stringWithFormat:@"Value : %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"IsAlertShowing"] ];
//    [[[UIAlertView alloc] initWithTitle:@"Alert For Resume" message:strL delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.myCollectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
}

-(void)btnBackPressed:(id)sender {
//  [self dismissViewControllerAnimated:TRUE completion:nil];
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - UITablebarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0) {
        UINavigationController *nav = (UINavigationController*)viewController;
        if ([[nav visibleViewController] isKindOfClass:[SWPlaylistsViewController class]]) {
            [self performSegueWithIdentifier:@"CategoryDescription" sender:self];
            return FALSE;
        }
        else if ([[nav visibleViewController] isKindOfClass:[SWCategoriesDescriptionViewController class]]) {
            return FALSE;
        }
        return TRUE;
    }
    if (tabBarController.selectedIndex == 1) {
//        return FALSE;
        return TRUE;
    }
    return TRUE;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyAccountURL]];
//        tabBarController.selectedIndex = 0;
    }
}

#pragma mark - Button Favorites Pressed
-(void)btnFavoritesPressed:(id)sender {
    self.viewForFavorites.hidden = FALSE;
    [self.viewForFavorites setUserInteractionEnabled:TRUE];
    [self.myCollectionView setHidden:TRUE];
    [self.myCollectionView setUserInteractionEnabled:FALSE];
    self.btnFavorites.backgroundColor = buttonSelectedColor;
    self.btnAllMixes.backgroundColor = buttonUnSelectedColor;
    
    [SVProgressHUD showWithStatus:@"Loading Favorite" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getFavoritesForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error)
     {
         if (!error) {
             if (data) {
                 self.dataFavorites = data;
                 [self.tblViewFav setDelegate:self];
                 [self.tblViewFav setDataSource:self];
                 [self.tblViewFav reloadData];
                 [SWLogger logEvent:@"Loaded Favorites"];
             }
         }
         else {
             [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading Favorites: %@", error]];
             NSString *errorDescription = error.localizedDescription;
             if ([errorDescription hasPrefix:@"No streams available for user type:"]) {
                 errorDescription = @"You currently do not have any favorite mixes. When you're jamming to a mix you like, tap the star and the mix will be added to your list of favorites.";
                 
                 [UIAlertView showWithTitle:@"No Favorites!" message:errorDescription handler:nil];
             }
             else if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                 if (error.code == kSWErrorInvalidLogin) {
                     NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                      [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                 }
             }
         }
          [SVProgressHUD dismiss];
     }];    
}

#pragma mark - Button ALL Mixes Pressed
-(void)btnAllMixesPressed:(id)sender {
    self.viewForFavorites.hidden = TRUE;
    [self.viewForFavorites setUserInteractionEnabled:FALSE];
    [self.myCollectionView setHidden:FALSE];
    [self.myCollectionView setUserInteractionEnabled:TRUE];
    
    self.btnFavorites.backgroundColor = buttonUnSelectedColor;
    self.btnAllMixes.backgroundColor = buttonSelectedColor;
}

#pragma mark  - Load new mix count

-(void)loadNewMixesCount {
    [SWLogger logEvent:@"Loading new mix count"];
    [[SWAPI sharedAPI] getNewMixCountForUserID:appState.currentUser.userId completion:^(NSInteger data, NSError *error) {
        if (!error)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(data) forKey:kTabBarBadgeNumber];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForBadge object:nil];
        }
        else
        {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading new mix count: %@", error]];
        }
    }];
}

#pragma mark  - Load Core Categories List From Web Server
-(void)loadCoreCategoriesFromweb {
    [SWLogger logEvent:@"Loading Channels"];
    [SVProgressHUD showWithStatus:@"Loading Channels" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getPlaylistsForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error)     {
        if (!error) {
            if (data) {
                self.playlistCategories = data;
                [SWLogger logEvent:@"Loaded channels with returned data"];
            }
            else {
                [SWLogger logEvent:@"Loaded channels with NO returned data"];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading Channels: %@", error]];
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                     [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
        [self loadPurePlayListFromWeb]; // load Pure Play
    }];
}

#pragma mark - Load Pure Play List From Web Server
-(void)loadPurePlayListFromWeb
{
    [SWLogger logEvent:@"Loading Pure Play"];
    [SVProgressHUD showWithStatus:@"Loading Pure Play" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getPurePlayListingsForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error)
    {
        if (!error) {
            if (data) {
                [SWLogger logEvent:@"Loaded Pure Play with returned data"];
                self.playlistPurePlay = data;
                //Reload CollectionView
            }
            else {
                [SWLogger logEvent:@"Loaded Pure Play with NO returned data"];
            }
        }
        else {
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading Pure Play: %@", error]];
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                      [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
        [self reloadCollectionView];
    }];
}

-(void)reloadCollectionView
{
    self.myCollectionView.delegate= self;
    self.myCollectionView.dataSource= self;
    [self.myCollectionView reloadData];
    [SVProgressHUD dismiss];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Actions
- (IBAction)nowPlaying {
    [SWLogger logEventWithObject:self selector:_cmd];
    // navigates the user back to the PlayerView assuming it has existed (user has started one already)
    if (appState.currentPlayerViewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Your main thread code goes in here
            NSLog(@"Im on the main thread");
            appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
            [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
        });
    }
}

-(IBAction)btnMenuPressed:(id)sender {
    [self performSegueWithIdentifier:@"ShowMenuScreen" sender:self];
}

- (IBAction)logout {
    NSString *strOkay = @"Okay";
    [UIAlertView showWithMessage:@"Are you sure you want to logout" cancelButtonTitle:@"Cancel" otherButtonTitles:@[strOkay] handler:^(TPAlertViewHandlerParams *const params) {
        if (params.handlerType == TPAlertViewTappedButton) {
            if ([params.buttonTitle isEqualToString:strOkay]) {
                [SWLogger logEventWithObject:self selector:_cmd];
                [appState saveCurrentPlaylistAndSongInfoForUserId:appState.currentUser.userId];
                // Stop receiving remote control events
                [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                // Terminate player VC.  (stops playing.. yadda yadda )
                dispatch_async(dispatch_get_main_queue(), ^{
                     [SVProgressHUD showWithStatus:@"Logging Out" maskType:SVProgressHUDMaskTypeGradient];
                });
               
                if (appState.currentPlayerViewController) {
                    [appState.currentPlayerViewController cleanUpPlayer_AndCompletionHandler:^(bool success) {
                        [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                            appState.currentPlayerViewController = nil;
                            if (success) {
                                [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SVProgressHUD dismiss];
                                    [self removeObservers];
                                    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                    appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                    appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                    [appDelegate.window makeKeyAndVisible];
                                });
                            }
                            
                        }];
                    }];
                }
                else {
                    [[SWAPI sharedAPI] logOutWithCompletion:^(BOOL success, NSError *error) {
                        appState.currentPlayerViewController=nil;
                        if (success) {
                            [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:kIsCurrentUserLoggedIn];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SVProgressHUD dismiss];
                                [self removeObservers];
                                [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
                                appDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                                appDelegate.window.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainRootViewController"];
                                [appDelegate.window makeKeyAndVisible];
                            });
                        }
                    }];
                }
               
            }
            else {
//                [[NSNotificationCenter defaultCenter] postNotificationName:SWDeselectTableViewCells object:nil];
            }
        }
    }];
}

-(void)changeRootViewController {
    [appDelegate.window setRootViewController:[self.storyboard instantiateInitialViewController]];
}

#pragma mark - Private Methods
- (void)tapFavorites {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performSegueWithIdentifier:@"Favorites" sender:nil];
}

- (void)tapPurePlay {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self performSegueWithIdentifier:@"Pure Play" sender:nil];
}

- (void)changePlaylistToPlaylist:(SWPlaylist *)selectedPlaylist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime
{
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([appState isTimeExpiredForCurrentUser]) {
        appState.currentPlayerViewController = nil;
        [UIAlertView showWithMessage:SUBSCRIPTION_FINISH handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return;
    }
    else if ([appState isAccountExpiredForCurrentUser])
    {
        appState.currentPlayerViewController = nil;
        [UIAlertView showWithMessage:SUBSCRIPTION_EXPIRED handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewDidDismiss) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
            }
        }];
        return;
    }

    void (^getNewPlayer)(void) = ^{
        appState.currentPlayerViewController = nil;
        appState.currentPlayerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlayer"];
    };
    
    void (^changePlaylists)(void) = ^{
        if (appState.currentPlayerViewController) {
            [appState.currentPlayerViewController cleanUpPlayer];
        }
        if (!appState.currentPlayerViewController) {
            getNewPlayer();
        }
        
        appState.currentPlayList = selectedPlaylist;
        self.honeycombView.tintColor = selectedPlaylist.colorStream;
        appState.currentPlayerViewController.delegate = self;
        
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Your main thread code goes in here
                    NSLog(@"Im on the main thread");
                    [appState.currentPlayerViewController loadPlaylist:selectedPlaylist withTrackNumber:trackNumber trackTime:trackTime];
                    appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
                    if (![[self.navigationController topViewController] isKindOfClass:[SWPlayerViewController class]]) {
                        [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
                    }
        });
    };
    if (appState.currentPlayerViewController) {
//                [UIAlertView showWithMessage:@"Are you sure you wish to listen to a different mix?" cancelButtonTitle:@"Keep Listening"
//                   otherButtonTitles:@[changePlaylistsString] handler:^(TPAlertViewHandlerParams *const params) {
//                       if (params.handlerType == TPAlertViewTappedButton) {
//                           if ([params.buttonTitle isEqualToString:changePlaylistsString]) {
//                               changePlaylists();
//                           }
//                           else {
////                               [[NSNotificationCenter defaultCenter] postNotificationName:SWDeselectTableViewCells object:nil];
//                           }
//                       }
//                   }];
        changePlaylists();
    }
    else {
        changePlaylists();
    }
}

- (void)refreshNowPlayingButton
{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController) {
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - SWPlayerViewControllerDelegate Methods
- (void)playerViewControllerDidFinish:(SWPlayerViewController *)controller
{
    [SWLogger logEventWithObject:self selector:_cmd];
    NSLog(@"%s",__PRETTY_FUNCTION__);
    [self.navigationController popToViewController:self animated:YES];
}

- (void)playerViewController:(SWPlayerViewController *)controller didChangePlayStatus:(BOOL)isPlaying{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (isPlaying) {
        self.wasAnimatingHoneycombView = YES;
        [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        self.wasAnimatingHoneycombView = NO;
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}


#pragma mark - UIcollectionView Delegate And DataSources
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.playlistCategories.count;
    }
    else if(section == 1) {
        return self.playlistPurePlay.count;
    }
    else {
        return 1;
    }
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 7;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    double width = [UIScreen mainScreen].bounds.size.width;
    width = (width-34 )/2;
    return CGSizeMake(width, 82);// iPhone 4, 5, 5s
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(10, 10, 0, 10); // Top Left Bottom Right
    }
    return UIEdgeInsetsMake(0, 10, 50, 10); // Top Left Bottom Right
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SWCollectionHeaderReusableView  *headerView = (SWCollectionHeaderReusableView *) [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderViewCollection" forIndexPath:indexPath];
    if (kind == UICollectionElementKindSectionHeader ) {
        
        if (indexPath.section == 1) {
            headerView.hidden = FALSE;
        }
        else {
            headerView.hidden = TRUE;
            //            headerView.frame = CGRectZero;
        }
    }
    return headerView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeZero;
    }else {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds), 50);
    }
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SWCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCollectionViewCell" forIndexPath:indexPath];
    
    
    UIFont *ArialFont = [UIFont fontWithName:@"HelveticaNeue" size:19.0];
    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: ArialFont forKey:NSFontAttributeName];
    NSMutableAttributedString *AattrString;
    NSMutableAttributedString *VattrString;
    UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0];
    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
    
    if (indexPath.section == 0) {
        cell.imageCellItem.image = [[UIImage imageNamed:@"btn_CoreCategories"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        SWPlaylistCategory *category = self.playlistCategories[indexPath.item];
            NSArray *words = [category.categoryName.uppercaseString componentsSeparatedByString:@" "];

            if (words.count>0) {
                AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: arialdict];
                if (words.count>1) {
                    VattrString = [[NSMutableAttributedString alloc]initWithString:words[1] attributes:veradnadict];
                    NSMutableAttributedString *SpaceString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
                    [AattrString appendAttributedString:SpaceString];
                     [AattrString appendAttributedString:VattrString];
                }
                else{
                    AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: veradnadict];
                }
                [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:(NSMakeRange(0, AattrString.length))];
                cell.lblTitleRegular.attributedText = AattrString;
            }
            else {
                cell.lblTitleRegular.text = @"";
            }
    }
    else if (indexPath.section == 1) {
        cell.imageCellItem.image = [[UIImage imageNamed:@"btn_PurePlay"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        SWPlaylistCategory *category = self.playlistPurePlay[indexPath.item];
        NSArray *words = [category.categoryName.uppercaseString componentsSeparatedByString:@" "];
        
        if (words.count>0) {
            AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: arialdict];
            if (words.count>1) {
                VattrString = [[NSMutableAttributedString alloc]initWithString:words[1] attributes:veradnadict];
                NSMutableAttributedString *SpaceString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
                [AattrString appendAttributedString:SpaceString];
                [AattrString appendAttributedString:VattrString];
            }
            else{
                AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: veradnadict];
            }
            [AattrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:(241/255.0) green:(229/255.0) blue:(45/255.0) alpha:1] range:(NSMakeRange(0, AattrString.length))];
            cell.lblTitleRegular.attributedText = AattrString;
        }
        else {
            cell.lblTitleRegular.text = @"";
        }
    }
    else {
        
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        selecetedcategory = self.playlistCategories[indexPath.item];
        strCategoryType = @"0";
    }
    else if(indexPath.section == 1) {
        selecetedcategory = self.playlistPurePlay[indexPath.item];
        strCategoryType = @"1";
    }
    [self performSegueWithIdentifier:@"SubCategorySegue" sender:self];
    /*
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_UNAVAIL handler:nil];
        return;
    }
    
    if (indexPath.section == 0) {
        SWPlaylistCategory *category = self.playlistCategories[indexPath.item];
        NSUInteger randomPlaylist = arc4random() % category.streams.count;
        SWPlaylist *selectedPlaylist = category.streams[randomPlaylist];
        [self changePlaylistToPlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@0];
    }
    else if(indexPath.section == 1) {
        SWPlaylistCategory *category = self.playlistPurePlay[indexPath.item];
        NSUInteger randomPlaylist = arc4random() % category.streams.count;
        SWPlaylist *selectedPlaylist = category.streams[randomPlaylist];
        [self changePlaylistToPlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@0];
    }
    
    NSString *strTheBeginning=@"The Beginning",*strHours2=@"Hours 2",*strHours3=@"Hours 3",*strHours4=@"Hours 4",*strHours5=@"Hours 5";
    
    //    [UIAlertView showWithTitle:@"Choose Mix Option" message:nil cancelButtonTitle:nil cancelButtonIndex:6 otherButtonTitles:@[strTheBeginning,strHours2,strHours3,strHours4,strHours5] style:UIAlertViewStyleDefault handler:^(TPAlertViewHandlerParams *const params) {
    //    }];
     */
}

#pragma mark - prepareForSegue:sender:
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CategoryDescription"]) {
        [[segue destinationViewController] setArrCoreCategory:self.playlistCategories];
        [[segue destinationViewController] setArrPurePlayCategory:self.playlistPurePlay];
    }
    else if ([segue.identifier isEqualToString:@"SubCategorySegue"]) {
        [[segue destinationViewController] setArrCorePlayCategory:self.playlistCategories];
        [[segue destinationViewController] setArrPurePlayCategory:self.playlistPurePlay];
        [[segue destinationViewController] setPlaylistCategory:selecetedcategory];
        if ([strCategoryType isEqualToString:@"0"]) {
            [(SWSubCategoriesViewController*)[segue destinationViewController] setStrCategoryType:@"Core Categories"];
        }
        else {
            [(SWSubCategoriesViewController*)[segue destinationViewController] setStrCategoryType:@"Pure Play"];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowMenuScreen"]) {
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.45f];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
        [[self.navigationController.view layer] addAnimation:animation forKey:@""];
//        SWMenuViewController *menuView = (SWMenuViewController*)[segue destinationViewController];
        
     }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataFavorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
    SWPlaylist *playlist = self.dataFavorites[indexPath.row];
    SWPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistFavoriteCell" forIndexPath:indexPath];
    cell.lblName.text = playlist.streamTitle.uppercaseString;
    cell.lbldesc.text = playlist.streamDesc.uppercaseString;
    cell.color = playlist.colorStream;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SWLogger logEventWithObject:self selector:_cmd];
    SWPlaylist *playList = self.dataFavorites[indexPath.row];
    [self viewController:self didSelectPlayList:playList];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Check internet Connection First
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_UNAVAIL handler:nil];
        return;
    }
    
    SWPlaylist *playlist = self.dataFavorites[indexPath.row];
    CFShow((__bridge CFTypeRef)(playlist));
    NSLog(@"Playlist: %@", playlist);
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[SWAPI sharedAPI] removePlaylistID:playlist.streamId fromFavoritesForUserID:appState.currentUser.userId completion:^(BOOL success, NSError *error) {
             if (!error) {
                 if (success) {
                     [self.dataFavorites removeObject:playlist];
                     [self.tblViewFav reloadData];
                 }
             }
             else {
                 if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                     if (error.code == kSWErrorInvalidLogin) {
                         NSLog(@"Error in %s", __PRETTY_FUNCTION__);
                           [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                     }
                 }
             }
         }];
    }
}

#pragma mark - UITableViewDelegate Methods
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}


#pragma mark - SWPlaylistSelectionDelegate Methods
- (void)viewController:(UIViewController *)controller didSelectPlayList:(SWPlaylist *)playList {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self changePlaylistToPlaylist:playList withTrackNumber:0 trackTime:0];
}

- (SWPlayerViewController *)playerViewControllerForViewController:(UIViewController *)controller {
    return appState.currentPlayerViewController;
}

#pragma mark - Notifications
- (void)handleUserLogOut:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController) {        
        [appState.currentPlayerViewController cleanUpPlayer];
        appState.currentPlayerViewController = nil;
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)handleReloadPreviousSession:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    NSDictionary *userInfo = notif.userInfo;
    NSString *userID = userInfo[@"userID"];
    NSString *lastPlayedPlaylistID = userInfo[@"lastPlayedPlaylistID"];
    NSNumber *lastPlayedTrackNumber = userInfo[@"lastPlayedTrackNumber"];
    NSNumber *lastPlayedTrackTime = userInfo[@"lastPlayedTrackTime"];
    
    void (^PlayPlaylist)(NSMutableArray *, NSError *) = ^(NSMutableArray *data, NSError *error) {
        if (!error && data) {
            self.playlistCategories = data;
            for (SWPlaylistCategory *playlistCategory in data) {
                for (SWPlaylist *playlist in playlistCategory.streams) {
                    if ([lastPlayedPlaylistID isEqualToString:playlist.streamId]) {
                        [self changePlaylistToPlaylist:playlist withTrackNumber:lastPlayedTrackNumber trackTime:lastPlayedTrackTime];
                        return;
                    }
                }
            }
        }
        
        // If we get here, then that means we didn't find the playlist in self.playlistCategories, which
        // means it could have been a Pure Play playlist. So, try loading the Pure Play playlists here, then try
        // finding the one that matches the last played playlist ID.
        [SVProgressHUD showWithStatus:@"Loading Pure Play" maskType:SVProgressHUDMaskTypeGradient];
        [[SWAPI sharedAPI] getPurePlayListingsForUserID:userID completion:^(NSMutableArray *data, NSError *error) {
            [SVProgressHUD dismiss];
            if (!error && data) {
                for (SWPlaylistCategory *playlistCategory in data) {
                    for (SWPlaylist *playlist in playlistCategory.streams) {
                        if ([lastPlayedPlaylistID isEqualToString:playlist.streamId]) {
                            [self changePlaylistToPlaylist:playlist withTrackNumber:lastPlayedTrackNumber trackTime:lastPlayedTrackTime];
                            return;
                        }
                    }
                }
            }
        }];
    };
    
    if (self.playlistCategories.count == 0) {
        [SVProgressHUD showWithStatus:@"Loading Playlists" maskType:SVProgressHUDMaskTypeGradient];
        [[SWAPI sharedAPI] getPlaylistsForUserID:userID completion:^(NSMutableArray *data, NSError *error) {
            [SVProgressHUD dismiss];
            PlayPlaylist(data, error);
        }];
    }
    else {
        PlayPlaylist(self.playlistCategories, nil);
    }
}

- (void)applicationWillTerminateNotif:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
//    [self logout];
}

- (void)applicationWillEnterForegroundNotif:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
}

- (void)playerDidLoadPlaylist:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    SWPlaylist *playlist = notif.object;
    self.honeycombView.tintColor = playlist.colorStream;
}

- (void)handleSessionInvalidation:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController) {
        [appState.currentPlayerViewController cleanUpPlayer_AndCompletionHandler:^(bool success) {
            [super handleSessionInvalidation:notif];
        }];
    }else{
        [super handleSessionInvalidation:notif];
    }
    
}

@end
