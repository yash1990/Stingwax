//
//  SWSongsViewController.m
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import "SWSongsViewController.h"
#import "StingWax-Constant.h"
#import "SWAppState.h"
#import "SWDateTimeHelper.h"

@interface SWSongsViewController ()

@property (nonatomic) UITableViewController *tableViewController;
@property (nonatomic) UILabel *lblPlayListName;
@property (weak, nonatomic) UITableView *tableView;
@property (nonatomic) NSIndexPath *loadingCellIndexPath;
@property (nonatomic) NSArray *dataSongList;
@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying;
-(IBAction)btnBackPressed:(id)sender;
@property(nonatomic) BOOL isMyPlayerRunning;
@end


@implementation SWSongsViewController

#pragma mark - Variables

- (void)setDataSongList:(NSArray *)dataSongList
{
    _dataSongList = dataSongList;
}

- (void)setCurrentTrackNumber:(NSInteger)currentTrackNumber
{
    _currentTrackNumber = currentTrackNumber;
    [self refreshData];
}


#pragma mark - View Hierarchy

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    self.title = appState.currentPlayList.streamTitle;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    }
    self.isMyPlayerRunning = FALSE;
    self.dataSongList = [appState.currentPlayListInfo.songInfo copy];
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = [UIColor whiteColor];
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationForPlayer:) name:SWMyPlayerRunningNotification object:FALSE];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SWPlayerStatus.Status" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

//    if (self.backgorundImage) {
//      self.backImageView.backgroundColor = [UIColor clearColor];
//      self.backImageView.image = self.backgorundImage;
//    }
//    else{
//        self.backImageView.backgroundColor = [UIColor blackColor];
//    }
    
    self.backImageView.backgroundColor = [UIColor blackColor];
    self.backImageView.image = nil;
    self.backImageView.alpha = 0.9;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self.navigationController.navigationBar.layer removeAllAnimations];
    }
     self.navigationItem.rightBarButtonItem = self.btnNowPlaying;
    
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - Notfication For Player
- (void)addObservers
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self selector:@selector(handleSessionInvalidation:) name:SWSessionInvalidatedNotification object:nil];
}

- (void)removeObservers {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self name:SWSessionInvalidatedNotification object:nil];
}


-(void)receivedNotificationForPlayer:(NSNotification *)notification
{
    NSInteger ii = [[notification object] integerValue];
    [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
    if (ii == 1) {
         [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

-(void)handleSessionInvalidation:(NSNotification *)notif{
    [SWLogger logEventWithObject:self selector:_cmd];
    [self dismissViewControllerAnimated:TRUE completion:^{
        [self.delegate cleanPlayerRequestFromSongsViewController:notif];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // after view appears, we can scroll to the currently playing song
    if (self.dataSongList.count > 0 && self.currentTrackNumber < self.dataSongList.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentTrackNumber inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle
                                      animated:YES];
    }
    self.view.backgroundColor = [UIColor clearColor];
}

-(void)btnBackPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SWMyPlayerRunningNotification object:nil];
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"TableEmbedSegue"]) {
        self.tableViewController = segue.destinationViewController;
        self.tableView = self.tableViewController.tableView;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Methods
// Method is called after the current track is set...
- (void)refreshData {
    self.tableView.userInteractionEnabled = YES;
    [self.tableView reloadData];
}

- (CGSize)songLabelSizeForString:(NSString *)songName {
    UIFont *songLabelFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    CGSize songLabelMaxSize = CGSizeMake(230, CGFLOAT_MAX);
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return CGRectIntegral([songName boundingRectWithSize:songLabelMaxSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName : songLabelFont}
                                                     context:nil]).size;
    }
    
    //    CGSize size = [songName sizeWithFont:songLabelFont constrainedToSize:songLabelMaxSize lineBreakMode:NSLineBreakByWordWrapping];
    CGSize size = [songName boundingRectWithSize: songLabelMaxSize
                                         options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                      attributes: [NSDictionary dictionaryWithObject:songLabelFont forKey:NSFontAttributeName]
                                         context: nil].size;
    
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (CGSize)artistLabelSizeForString:(NSString *)artistName {
    UIFont *artistLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    CGSize artistLabelMaxSize = CGSizeMake(230, CGFLOAT_MAX);
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        return CGRectIntegral([artistName boundingRectWithSize:artistLabelMaxSize
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName : artistLabelFont}
                                                       context:nil]).size;
    }
    
    //    CGSize size = [artistName sizeWithFont:artistLabelFont constrainedToSize:artistLabelMaxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    CGSize size = [artistName boundingRectWithSize: artistLabelMaxSize
                                           options: (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                        attributes: [NSDictionary dictionaryWithObject:artistLabelFont forKey:NSFontAttributeName]
                                           context: nil].size;
    
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}


#pragma mark - Actions

- (IBAction)finish {
    [self performSegueWithIdentifier:@"Finish" sender:nil];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSongList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSString *cellIdentifier = @"Cell";
    SWSongTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    SWSong *songInfo = self.dataSongList[row];
    cell.lblDesc.text = songInfo.songArtist; //Artist Name
    cell.lblSongName.text = songInfo.songTitle; //Song Name
    cell.lblDuration.text = [SWDateTimeHelper convertTimeMinSec:songInfo.songLength]; //song duration
    cell.lblSNo.text = [NSString stringWithFormat:@"%ld", (long)(row + 1)];
    
    if ([self.loadingCellIndexPath isEqual:indexPath]) {
        [cell setIsPlaying:NO];
        [cell setIsLoading:YES];
    }
    else {
        [cell setIsLoading:NO];
        if (self.currentTrackNumber == row) {
            [cell setIsPlaying:YES];
        }
        else {
            [cell setIsPlaying:NO];
        }
    }
    
//    cell.backgroundColor = [UIColor clearColor];
//    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}


#pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWSong *songInfo = self.dataSongList[indexPath.row];
    CGSize songLabelSize = [self songLabelSizeForString:songInfo.songTitle];
    CGSize artistLabelSize = [self artistLabelSizeForString:songInfo.songArtist];
    CGFloat height = songLabelSize.height + artistLabelSize.height + 8 + 3 + 8;
    return MAX(55, height);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger trackTapped = indexPath.row;
    // Disbling user interaction with the playlist, while the player changes the track..
    // once the track is changed, the player view sends a updated track number to the controller,
    // then the userInteraction is Enabled again.
    self.tableView.userInteractionEnabled = NO;
    self.loadingCellIndexPath = indexPath;
    [tableView reloadData];
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.tableView.userInteractionEnabled = YES;
        self.loadingCellIndexPath = nil;
        [self.tableView reloadData];
    };
    if (![self.delegate songListViewControllerDelegate:self didTapTrack:(int)trackTapped withCompletion:completion]) {
        completion(YES);
    }
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notif {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [SWLogger logEventWithObject:self selector:_cmd];
    // Re-register for receiving remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if (appState.currentPlayerViewController.isPlaying) {
        [self dismissViewControllerAnimated:TRUE completion:^{
        }];
    }
}
-(void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    if (appState.currentPlayerViewController.isPlaying) {
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

@end
