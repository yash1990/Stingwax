//
//  FavoritesListViewController.m
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import "SWFavoritesViewController.h"
#import "SWPlayerViewController.h"
#import "SWPlaylistsViewController.h"
#import "StingWax-Constant.h"
#import "SWHoneycombView.h"
#import "SWPlaylistTableViewCell.h"
#import "SWPlaylist.h"
#import "SWAPI.h"
#import "SWAppState.h"
#import "SWHelper.h"
#import "StingWax-Keys.h"
#import "UIAlertView+TPBlocks.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SWFavoritesViewController () <UITableViewDataSource,
                                           UITableViewDelegate,
                                           UIAlertViewDelegate>

@property (nonatomic) UITableViewController *tableViewController;

@property (weak, nonatomic) UITableView *tableView; // weak because it's just referencing tableViewController's tableView property; we don't own it

@property (nonatomic) NSMutableArray *dataFavorites;

@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying;

@end


@implementation SWFavoritesViewController

#pragma mark - Getters

- (SWPlayerViewController *)playerViewController
{
    if ([self.delegate respondsToSelector:@selector(playerViewControllerForViewController:)]) {
        return [self.delegate playerViewControllerForViewController:self];
    }
    return nil;
}


#pragma mark - Object Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self addObservers];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addObservers];
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeObservers];
}

- (void)addObservers
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotif:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter addObserver:self selector:@selector(playerDidLoadPlaylist:) name:SWPlayerDidLoadPlaylist object:nil];
    [notifCenter addObserver:self selector:@selector(deselectTableViewCell:) name:SWDeselectTableViewCells object:nil];
}

- (void)removeObservers
{
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [notifCenter removeObserver:self name:SWPlayerDidLoadPlaylist object:nil];
    [notifCenter removeObserver:self name:SWDeselectTableViewCells object:nil];
}

#pragma mark - View Hierarchy

- (void)viewDidLoad
{
    [super viewDidLoad];
    [SWLogger logEvent:@"Loading Favorites"];
    [SVProgressHUD showWithStatus:@"Loading Favorites" maskType:SVProgressHUDMaskTypeGradient];    
    [[SWAPI sharedAPI] getFavoritesForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error)
    {
        [SVProgressHUD dismiss];
        if (!error) {
            if (data) {
                self.dataFavorites = data;
                [self.tableView reloadData];
                [SWLogger logEvent:@"Loaded Favorites"];
            }
        }
        else {
            
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading Favorites: %@", error]];
            
            NSString *errorDescription = error.localizedDescription;
            if ([errorDescription hasPrefix:@"No streams available for user type:"]) {
                errorDescription = @"You currently do not have any favorite mixes. When you're jamming to a mix you like, tap the star and the mix will be added to your list of favorites.";
                
                [UIAlertView showWithTitle:@"No Favorites!"
                                   message:errorDescription
                                   handler:nil];
            }
            else if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                    [UIAlertView showWithMessage:error.localizedDescription
                                         handler:^(TPAlertViewHandlerParams *const params) {
                                             if (params.handlerType == TPAlertViewTappedButton) {
                                                 NSLog(@"%s",__PRETTY_FUNCTION__);
                                                 [self navigateBackToLogin];
                                             }
                                         }];
                }
            }
        }
    }];
    
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = appState.currentPlayList.colorStream;
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [self refreshNowPlayingButton];
    
    if (self.playerViewController) {
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (self.playerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        self.wasAnimatingHoneycombView = NO;
        [self.honeycombView stopAnimatingImmediately:YES];
    }
    
    // Must call this after setting wasAnimatingHoneycombView to NO
    [super viewWillAppear:animated];
}

-(void)btnBackPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:true];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Table Embed"]) {
        self.tableViewController = segue.destinationViewController;
        self.tableView = self.tableViewController.tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Actions

- (IBAction)nowPlaying
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    // navigates the user back to the PlayerView assuming it has existed (user has started one already)
    if (self.playerViewController) {
        [self.navigationController pushViewController:self.playerViewController animated:YES];
    }
}


#pragma mark - Private Methods

- (void)refreshNowPlayingButton
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (self.playerViewController) {
        self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataFavorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWPlaylist *playlist = self.dataFavorites[indexPath.row];

    SWPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Playlist Cell"
                                                                    forIndexPath:indexPath];
    cell.lblName.text = playlist.streamTitle.uppercaseString;
    cell.lbldesc.text = playlist.streamDesc.uppercaseString;
    cell.color = playlist.colorStream;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check internet Connection First
	if (![SWHelper doWeHaveInternetConnection]) {
        [UIAlertView showWithMessage:INTERNET_UNAVAIL handler:nil];
        return;
    }
    
    SWPlaylist *playlist = self.dataFavorites[indexPath.row];
    CFShow((__bridge CFTypeRef)(playlist));
    NSLog(@"Playlist: %@", playlist);
    
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[[SWAPI sharedAPI] removePlaylistID:playlist.streamId fromFavoritesForUserID:appState.currentUser.userId completion:^(BOOL success, NSError *error)
         {
             if (!error) {
                 if (success) {
                     [self.dataFavorites removeObject:playlist];
                     [self.tableView reloadData];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
	SWPlaylist *playList = self.dataFavorites[indexPath.row];
    
    [self.delegate viewController:self didSelectPlayList:playList];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}


#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (alertView.tag == 666) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Notifications

- (void)playerDidLoadPlaylist:(NSNotification *)notif
{
    [SWLogger logEventWithObject:self selector:_cmd];    
    SWPlaylist *playlist = notif.object;
    self.honeycombView.tintColor = playlist.colorStream;
}

- (void)deselectTableViewCell:(NSNotification *)notif
{
    if (self.tableView) {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (void)handleSessionInvalidation:(NSNotification *)notif
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (self.playerViewController) {
        [self.playerViewController cleanUpPlayer];
    }
    
    [super handleSessionInvalidation:notif];
}

- (void)applicationWillEnterForegroundNotif:(NSNotification *)notif
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
    if (self.playerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
}

@end
