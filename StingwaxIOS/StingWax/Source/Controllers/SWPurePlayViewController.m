//
//  PurePlayViewController.m
//  StingWax
//
//  Created by Steve Malsam on 11/13/13.
//
//

#import "SWPurePlayViewController.h"
#import "SWPlayerViewController.h"
#import "SWPlaylistsViewController.h"
#import "SWHoneycombView.h"
#import "SWPlaylistTableViewCell.h"
#import "SWPlaylistCategory.h"
#import "SWAPI.h"
#import "SWAppState.h"
#import "UIAlertView+TPBlocks.h"
#import "StingWax-Constant.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface SWPurePlayViewController () <UITableViewDataSource,
                                      UITableViewDelegate>

@property (nonatomic) UITableViewController *tableViewController;

@property (weak, nonatomic) UITableView *tableView; // weak because it's just referencing tableViewController's tableView property; we don't own it

@property (nonatomic) NSArray *purePlayListings;

@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying;

@end


@implementation SWPurePlayViewController

#pragma mark - Getters

- (NSArray *)purePlayListings
{
    if (!_purePlayListings) {
        _purePlayListings = @[];
    }
    return _purePlayListings;
}

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

- (void)dealloc
{
    [self removeObservers];
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


#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SWLogger logEvent:@"Loading Pure Play"];
	[SVProgressHUD showWithStatus:@"Loading Pure Play" maskType:SVProgressHUDMaskTypeGradient];
	[[SWAPI sharedAPI] getPurePlayListingsForUserID:appState.currentUser.userId completion:^(NSMutableArray *data, NSError *error)
    {
        [SVProgressHUD dismiss];
        if (!error) {
            if (data) {
                [SWLogger logEvent:@"Loaded Pure Play with returned data"];
                self.purePlayListings = [NSArray arrayWithArray:data];
                [self.tableView reloadData];
            }
            else {
                [SWLogger logEvent:@"Loaded Pure Play with NO returned data"];
            }
        }
        else {
            
            [SWLogger logEvent:[NSString stringWithFormat:@"Error on Loading Pure Play: %@", error]];
            
            if ([error.domain isEqualToString:SWAPIErrorDomain]) {
                if (error.code == kSWErrorInvalidLogin) {
                      [[NSNotificationCenter defaultCenter] postNotificationName:SWSessionInvalidatedNotification object:error];
                }
            }
        }
    }];
    
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = appState.currentPlayList.colorStream;
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
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
	return self.purePlayListings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWPlaylistCategory *category = self.purePlayListings[indexPath.row];
    
	SWPlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Playlist Cell"
                                                                    forIndexPath:indexPath];
	cell.lblName.text = category.categoryName.uppercaseString;
	cell.lbldesc.text = category.categoryDesc.uppercaseString;
	cell.color = [UIColor whiteColor];

	return cell;
}


#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SWLogger logEventWithObject:self selector:_cmd];
    
	SWPlaylistCategory *category = self.purePlayListings[indexPath.row];
	NSUInteger randomPlaylist = arc4random() % category.streams.count;

	SWPlaylist *selectedPlaylist = category.streams[randomPlaylist];

    [self.delegate viewController:self didSelectPlayList:selectedPlaylist];
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
    
    [self.playerViewController cleanUpPlayer];
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
