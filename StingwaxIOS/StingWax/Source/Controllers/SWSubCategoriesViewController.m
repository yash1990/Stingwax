//
//  SWSubCategoriesViewController.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWSubCategoriesViewController.h"
#import "SWSubCategoryTableViewCell.h"
#import "SWPlaylistTableViewCell.h"
#import "AsyncImageView.h"
#import "SWAppDelegate.h"
#import "SWPlaylist.h"
#import "SWPlaylistSelectionDelegate.h"
#import "SWCategoriesDescriptionViewController.h"
#import "AsyncImageView.h"

@interface SWSubCategoriesViewController ()<UITableViewDataSource,UITableViewDelegate,SWPlaylistSelectionDelegate,UITabBarControllerDelegate> {
    SWAppDelegate *appDelegate;
    UIColor *buttonSelectedColor;
    UIColor *buttonUnSelectedColor;
    NSMutableDictionary *dictSubCategoryData;
    NSMutableArray *arrUnArchiveddata;
    NSMutableArray *arrArchiveddata;
    BOOL isFavorite;
    BOOL isSubCategory;
    BOOL isArchivedShow;
}

@property(weak, nonatomic) IBOutlet UIView *viewForFavorites;
@property(weak, nonatomic) IBOutlet UIView *viewForTopTwoButton;
@property(weak, nonatomic) IBOutlet UIButton *btnFavorites;
@property(weak, nonatomic) IBOutlet UIButton *btnAllMixes;
@property(weak, nonatomic) IBOutlet UIButton *btnArchived;
@property(weak, nonatomic) IBOutlet UITableView *tblStream;
@property(weak, nonatomic) IBOutlet UITableView *tblViewFav;
@property (nonatomic) NSMutableArray *dataFavorites;

-(IBAction)btnFavoritesPressed:(id)sender;
-(IBAction)btnAllMixesPressed:(id)sender;

@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying; // holds the now playing button for display after selection of playlist.
@end

@implementation SWSubCategoriesViewController {
}

@synthesize playlistCategory,arrCorePlayCategory,arrPurePlayCategory,strCategoryType;

#pragma mark - Setters / Mutators
- (void)setPlayerViewController:(SWPlayerViewController *)playerViewController {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (playerViewController) {
        [appState.currentPlayerViewController cleanUpPlayer];
    }
    appState.currentPlayerViewController = playerViewController;
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

- (void)addObservers {
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(applicationWillTerminateNotif:) name:UIApplicationWillTerminateNotification object:nil];
    [notifCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotif:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter addObserver:self selector:@selector(handleUserLogOut:) name:SWUserLoggedOutNotification object:nil];
    [notifCenter addObserver:self selector:@selector(playerDidLoadPlaylist:) name:SWPlayerDidLoadPlaylist object:nil];
    //    [notifCenter addObserver:self selector:@selector(deselectTableViewCell:) name:SWDeselectTableViewCells object:nil];
}

- (void)removeObservers {
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [notifCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter removeObserver:self name:SWUserLoggedOutNotification object:nil];
    [notifCenter removeObserver:self name:SWPlayerDidLoadPlaylist object:nil];
    //    [notifCenter removeObserver:self name:SWDeselectTableViewCells object:nil];
    [notifCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [SWAppDelegate sharedDelegate];
    [self addObservers];
    buttonSelectedColor = [UIColor colorWithRed:195/255.0 green:186/255.0 blue:75/255.0 alpha:1];
    buttonUnSelectedColor = [UIColor clearColor];
    [self setupStyle];
    [self btnAllMixesPressed:nil];
    self.lblCategories.text = self.strCategoryType;
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    // Do any additional setup after loading the view.
    arrUnArchiveddata = [[NSMutableArray alloc] init];
    arrArchiveddata = [[NSMutableArray alloc] init];
    dictSubCategoryData = [[NSMutableDictionary alloc] init];
    
    if (self.playlistCategory) {
        if (self.playlistCategory.streams.count>0) {
            for (SWPlaylist *stream in self.playlistCategory.streams) {
                if ([stream.streamArchived isEqualToString:@"1"]) {
                    [arrArchiveddata addObject:stream];
                }
                else {
                    [arrUnArchiveddata addObject:stream];
                }
            }
            [dictSubCategoryData setObject:arrArchiveddata forKey:@"Archived"];
            [dictSubCategoryData setObject:arrUnArchiveddata forKey:@"UnArchived"];
        }
    }
    isArchivedShow = FALSE;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController.tabBar setHidden:FALSE];
    self.tabBarController.delegate = self;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self refreshNowPlayingButton];
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        self.wasAnimatingHoneycombView = NO;
        [self.honeycombView stopAnimatingImmediately:YES];
    }
    if (appState.currentPlayerViewController) {
        appState.currentPlayerViewController.delegate = self;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!isFavorite) {
        [self.tblStream setDelegate:self];
        [self.tblStream setDataSource:self];
        [self.tblStream reloadData];
    }
}


#pragma mark - SWPlayerViewControllerDelegate Methods
- (void)playerViewControllerDidFinish:(SWPlayerViewController *)controller {
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


#pragma mark - Button Favorites Pressed
-(void)btnFavoritesPressed:(id)sender {
    isFavorite  = TRUE;
    isSubCategory  = FALSE;
    self.tblStream.hidden = TRUE;
    self.viewForFavorites.hidden = FALSE;
    [self.viewForFavorites setUserInteractionEnabled:TRUE];
    self.btnFavorites.backgroundColor = buttonSelectedColor;
    self.btnAllMixes.backgroundColor = buttonUnSelectedColor;
    self.btnArchived.backgroundColor = buttonUnSelectedColor;
    
    [SVProgressHUD showWithStatus:@"Loading Favorite" maskType:SVProgressHUDMaskTypeGradient];
    [[SWAPI sharedAPI] getFavoritesForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error) {
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
    isSubCategory = TRUE;
    isFavorite = FALSE;
    self.tblStream.hidden = FALSE;
    self.viewForFavorites.hidden = TRUE;
    [self.viewForFavorites setUserInteractionEnabled:FALSE];
    self.btnFavorites.backgroundColor = buttonUnSelectedColor;
    self.btnAllMixes.backgroundColor = buttonSelectedColor;
    self.btnArchived.backgroundColor = buttonUnSelectedColor;
    isArchivedShow = FALSE;
    
    [self.tblStream setDelegate:self];
    [self.tblStream setDataSource:self];
    [self.tblStream reloadData];
    [self.tblStream setContentOffset:CGPointMake(0, 0) animated:TRUE];
}

#pragma mark - UITablebarController Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 0) {
        UINavigationController *nav = (UINavigationController*)viewController;
        if ([[nav visibleViewController] isKindOfClass:[SWSubCategoriesViewController class]]) {
            [self performSegueWithIdentifier:@"CategoryDescription" sender:self];
            return FALSE;
        }
        else if ([[nav visibleViewController] isKindOfClass:[SWCategoriesDescriptionViewController class]]) {
            return FALSE;
        }
        return TRUE;
    }
    if (tabBarController.selectedIndex == 1) {
       
        return FALSE;
    }
    return TRUE;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 1) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kMyAccountURL]];
//        tabBarController.selectedIndex = 0;
    }
}

#pragma mark - preferredStatusBarStyle
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
//            [self presentViewController:navigaton_Player animated:TRUE completion:^{
//            }];
            appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
            [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
        });
    }
}

- (void)refreshNowPlayingButton
{
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController) {
        self.honeycombView.tintColor = appState.currentPlayList.colorStream;
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - changePlaylistToPlaylist:withTrackNumber:trackTime:
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
    
    NSString *changePlaylistsString = @"Change Mix";
    void (^changePlaylists)(void) = ^{
        NSString *strTitle1 = @"The Beginning";
        NSString *strTitle2 = @"2nd Hour";
        NSString *strTitle3 = @"3rd Hour";
        NSString *strTitle4 = @"4th Hour";
        NSString *strTitle5 = @"5th Hour";
        NSString *strTitle6 = @"Cancel";
        
        [UIAlertView showWithMessage:@"Start Mix From" cancelButtonTitle:nil otherButtonTitles:@[strTitle1,strTitle2,strTitle3,strTitle4,strTitle5,strTitle6] handler:^(TPAlertViewHandlerParams *const params) {
            if (params.handlerType == TPAlertViewTappedButton) {
                if ([params.buttonTitle isEqualToString:strTitle1]) {
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@0];
                }
                else if ([params.buttonTitle isEqualToString:strTitle2]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@3600];
                }
                else if ([params.buttonTitle isEqualToString:strTitle3]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@7200];
                }
                else if ([params.buttonTitle isEqualToString:strTitle4]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@10800];
                }
                else if ([params.buttonTitle isEqualToString:strTitle5]){
                    [self afterChoosePlaylist:selectedPlaylist withTrackNumber:@0 trackTime:@14400];
                }
                else {
                }
            }
        }];
    };
    
    if (appState.currentPlayerViewController) {
        [UIAlertView showWithMessage:@"Are you sure you wish to listen to a different mix?" cancelButtonTitle:@"Keep Listening"
                   otherButtonTitles:@[changePlaylistsString] handler:^(TPAlertViewHandlerParams *const params) {
                       if (params.handlerType == TPAlertViewTappedButton) {
                           if ([params.buttonTitle isEqualToString:changePlaylistsString]) {
                               changePlaylists();
                           }
                           else {
                               //                               [[NSNotificationCenter defaultCenter] postNotificationName:SWDeselectTableViewCells object:nil];
                           }
                       }
                   }];
    }
    else {
        changePlaylists();
    }
}

#pragma mark - After Choose Playlist
-(void)afterChoosePlaylist:(SWPlaylist *)selectedPlaylist withTrackNumber:(NSNumber *)trackNumber trackTime:(NSNumber *)trackTime{
    void (^getNewPlayer)(void) = ^{
        appState.currentPlayerViewController = nil;
        appState.currentPlayerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyPlayer"];
    };
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
        [appState.currentPlayerViewController loadPlaylist:selectedPlaylist withTrackNumber:trackNumber trackTime:trackTime];
         appState.currentPlayerViewController.hidesBottomBarWhenPushed = TRUE;
        [appDelegate.Tab0NavBarcontroller pushViewController:appState.currentPlayerViewController animated:TRUE];
    });
}

#pragma mark - Back Button Action
-(IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - UITAbleview Delegate And DataSources
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isFavorite) {
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isFavorite) {
        return self.dataFavorites.count;
    }
    else {
        if (section == 0) {
            return [[dictSubCategoryData objectForKey:@"UnArchived"] count];
        }
        else {
            if (isArchivedShow) {
                return [[dictSubCategoryData objectForKey:@"Archived"] count];
            }
            else {
                return 0;
            }
 
        }
    }
}
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (!isFavorite) {
//        if (section == 1) {
//            return @"Archived";
//        }
//    }
//    return @"";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
    if (!isFavorite) {
        if (section == 1) {
            return 44;
        }
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!isFavorite) {
        if (section == 1) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
            UIButton *btnArchived = [[UIButton alloc] initWithFrame:view.frame];
            [btnArchived setTitle:@"Archived" forState:UIControlStateNormal];
            btnArchived.backgroundColor = [UIColor clearColor];
            [btnArchived setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnArchived addTarget:self action:@selector(btnArchivedPressed:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:btnArchived];
            [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]];
            return view;
        }
    }
    return nil;
}

-(IBAction)btnArchivedPressed:(id)sender {
    UIButton *btnSender = (UIButton *)sender;
    
    if (btnSender.tag == 101) {
        if (isArchivedShow) {
            return;
        }
    }
    
    isArchivedShow = !isArchivedShow;
    isSubCategory = TRUE;
    isFavorite = FALSE;
    self.tblStream.hidden = FALSE;
    self.viewForFavorites.hidden = TRUE;
    [self.viewForFavorites setUserInteractionEnabled:FALSE];
    self.btnFavorites.backgroundColor = buttonUnSelectedColor;
    if (isArchivedShow) {
        self.btnAllMixes.backgroundColor = buttonUnSelectedColor;
        self.btnArchived.backgroundColor = buttonSelectedColor;
        
        [self.tblStream setDataSource:self];
        [self.tblStream setDelegate:self];
        [self.tblStream reloadData];
        CGRect sectionRect = [self.tblStream rectForSection:1];
        [self.tblStream setContentOffset:CGPointMake(0, sectionRect.origin.y) animated:TRUE];
    }
    else {
        self.btnAllMixes.backgroundColor = buttonSelectedColor;
        self.btnArchived.backgroundColor = buttonUnSelectedColor;
        [self.tblStream setDataSource:self];
        [self.tblStream setDelegate:self];
        [self.tblStream reloadData];
        [self.tblStream setContentOffset:CGPointMake(0, 0) animated:TRUE];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isFavorite) {
        return 44;
    }
    else{
        SWPlaylist *stream = (SWPlaylist*)[self.playlistCategory.streams objectAtIndex:indexPath.row];
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:11.0];
        CGFloat heightText = [SWAppDelegate heightOfTextForString:stream.streamDesc andFont:font maxSize:CGSizeMake((tableView.bounds.size.width - 108), MAXFLOAT)];
        if (120 > heightText) {
            return 120;
        }else{
            return (heightText + 20);
        }
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        if (isFavorite) {
            SWPlaylist *playlist = self.dataFavorites[indexPath.row];
            SWPlaylistTableViewCell *cell = [self.tblViewFav dequeueReusableCellWithIdentifier:@"PlaylistFavoriteCell" forIndexPath:indexPath];
            cell.lblName.text = playlist.streamTitle.uppercaseString;
            cell.lbldesc.text = playlist.streamDesc.uppercaseString;
            cell.color = playlist.colorStream;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell = [tableView dequeueReusableCellWithIdentifier:@"PlaylistFavoriteCell" forIndexPath:indexPath];
            cell.lblName.text = playlist.streamTitle.uppercaseString;
            cell.lbldesc.text = playlist.streamDesc.uppercaseString;
            cell.color = playlist.colorStream;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            return cell;
        }
        else {
            if (indexPath.section == 0) {
                SWSubCategoryTableViewCell *cell = [self.tblStream dequeueReusableCellWithIdentifier:@"SubCategoryCell" forIndexPath:indexPath];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell.layoutConstraint_Widht_Image setConstant:ceilf(100)];
                [cell.lblCategoryName setText:@""];
                [cell.txtViewCategoryDescription setText:@""];
                [cell.image1 setImage:nil];
                [cell.image1 setImageURL:nil];
                [cell.image1 setContentMode:UIViewContentModeScaleAspectFit];
//                SWPlaylist *stream = (SWPlaylist*)[self.playlistCategory.streams objectAtIndex:indexPath.row];
                SWPlaylist *stream = (SWPlaylist*)[[dictSubCategoryData objectForKey:@"UnArchived"] objectAtIndex:indexPath.row];
                UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
                NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
                NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc]initWithString:[stream.streamTitle capitalizedString] attributes:veradnadict];
                cell.lblCategoryName.attributedText = VattrString;
                cell.txtViewCategoryDescription.text = stream.streamDesc;
                NSString *strURL1  = [[stream streamIcon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [cell.image1 setImageURL:[NSURL URLWithString:strURL1]];
                [(AsyncImageView*)cell.image1 setShowActivityIndicator:TRUE];
                NSLog(@"Row:%ld And Image URl:%@",(long)indexPath.row,strURL1);
                CGRect imageframe = cell.image1.frame;
                NSLog(@"Row:%ld And Image Frame:(%f,%f,%f,%f)",(long)indexPath.row,imageframe.origin.x,imageframe.origin.y,imageframe.size.width,imageframe.size.height);
                CGFloat heightText = [SWAppDelegate heightOfTextForString:cell.txtViewCategoryDescription.text andFont:cell.txtViewCategoryDescription.font maxSize:CGSizeMake(cell.txtViewCategoryDescription.bounds.size.width, MAXFLOAT)];
                [cell.layout_Constraint_Height_textview setConstant:heightText+30];
                return cell;
            }
            else {
                if (isArchivedShow) {
                    SWSubCategoryTableViewCell *cell = [self.tblStream dequeueReusableCellWithIdentifier:@"SubCategoryCell" forIndexPath:indexPath];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell.layoutConstraint_Widht_Image setConstant:ceilf(100)];
                    [cell.lblCategoryName setText:@""];
                    [cell.txtViewCategoryDescription setText:@""];
                    [cell.image1 setImage:nil];
                    [cell.image1 setImageURL:nil];
                    [cell.image1 setContentMode:UIViewContentModeScaleAspectFit];
                    SWPlaylist *stream = (SWPlaylist*)[[dictSubCategoryData objectForKey:@"Archived"] objectAtIndex:indexPath.row];
                    UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
                    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
                    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc]initWithString:[stream.streamTitle capitalizedString] attributes:veradnadict];
                    cell.lblCategoryName.attributedText = VattrString;
                    cell.txtViewCategoryDescription.text = stream.streamDesc;
                    NSString *strURL1  = [[stream streamIcon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [cell.image1 setImageURL:[NSURL URLWithString:strURL1]];
                    [(AsyncImageView*)cell.image1 setShowActivityIndicator:TRUE];
                    
                    CGFloat heightText = [SWAppDelegate heightOfTextForString:cell.txtViewCategoryDescription.text andFont:cell.txtViewCategoryDescription.font maxSize:CGSizeMake(cell.txtViewCategoryDescription.bounds.size.width, MAXFLOAT)];
                    [cell.layout_Constraint_Height_textview setConstant:heightText+30];
                    
                    return cell;
                }
                else{
                    UITableViewCell *cell = [[UITableViewCell alloc] init];
                    return cell;
                }
            }
        }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_UNAVAIL handler:nil];
        return;
    }
    
    if (isFavorite) {
        SWPlaylist *playList = self.dataFavorites[indexPath.row];
        [self viewController:self didSelectPlayList:playList];
    }
    else {
        if (indexPath.section == 0) {
            SWPlaylist *stream = (SWPlaylist*)[[dictSubCategoryData objectForKey:@"UnArchived"] objectAtIndex:indexPath.row];
            [self changePlaylistToPlaylist:stream withTrackNumber:@0 trackTime:@0];
        }
        else {
            SWPlaylist *stream = (SWPlaylist*)[[dictSubCategoryData objectForKey:@"Archived"] objectAtIndex:indexPath.row];
            [self changePlaylistToPlaylist:stream withTrackNumber:@0 trackTime:@0];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorite) {
        return YES;
    }
    return FALSE;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorite) {
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
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isFavorite) {
         return @"Remove";
    }
    return @"";
}

#pragma mark - SWPlaylistSelectionDelegate Methods
- (void)viewController:(UIViewController *)controller didSelectPlayList:(SWPlaylist *)playList {
    [SWLogger logEventWithObject:self selector:_cmd];
    [self changePlaylistToPlaylist:playList withTrackNumber:0 trackTime:0];
}

- (SWPlayerViewController *)playerViewControllerForViewController:(UIViewController *)controller {
    return appState.currentPlayerViewController;
}

#pragma mark - prepareForSegue:sender:
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CategoryDescription"]) {
        [[segue destinationViewController] setArrCoreCategory:self.arrCorePlayCategory];
        [[segue destinationViewController] setArrPurePlayCategory:self.arrPurePlayCategory];
    }
}

#pragma mark - UITableViewDataSource Methods

#pragma mark - Notifications
- (void)handleUserLogOut:(NSNotification *)notif {
    [SWLogger logEventWithObject:self selector:_cmd];
    if (appState.currentPlayerViewController) {
        [appState.currentPlayerViewController cleanUpPlayer];
        appState.currentPlayerViewController = nil;
    }
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
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
- (void)dealloc {
    [self removeObservers];
}

-(void)viewDidDisappear:(BOOL)animated {
//    [self removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
