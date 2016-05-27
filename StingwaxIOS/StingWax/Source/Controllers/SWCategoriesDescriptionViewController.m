//
//  SWCategoriesDescriptionViewController.m
//  StingWax
//
//  Created by __DeveloperName__ on 5/4/15.
//  Copyright (c) 2015 __CompanyName__. All rights reserved.
//

#import "SWCategoriesDescriptionViewController.h"
#import "SWCategoryDescriptionTableViewCell.h"
#import "AsyncImageView.h"
#import "SWAppDelegate.h"
#import "SWPlaylistCategory.h"
#import "SWAppState.h"
#import "GBDeviceInfo.h"

@interface SWCategoriesDescriptionViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *tblCategoryDescription;
    SWAppDelegate *appDelegate;
}
@property (nonatomic) IBOutlet UIBarButtonItem *btnNowPlaying; // holds the now playing button for display after selection of playlist.
@end

@implementation SWCategoriesDescriptionViewController
@synthesize arrCoreCategory,arrPurePlayCategory;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appDelegate = [SWAppDelegate sharedDelegate];
    self.honeycombView = [[SWHoneycombView alloc] initWithFrame:CGRectInset(self.btnNowPlaying.customView.bounds, 5, 5)];
    self.honeycombView.honeycombSpacing = 2;
    self.honeycombView.tintColor = [UIColor whiteColor];
    self.honeycombView.userInteractionEnabled = NO;
    [self.btnNowPlaying.customView addSubview:self.honeycombView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationForPlayer:) name:SWMyPlayerRunningNotification object:FALSE];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(btnBackPressed:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:rightSwipe];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:FALSE];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [tblCategoryDescription setDelegate:self];
    [tblCategoryDescription setDataSource:self];
    
    if (appState.currentPlayerViewController.isPlaying) {
        self.honeycombView.tintColor = appState.currentPlayList.colorStream;
        [self.honeycombView startAnimatingImmediately:YES];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:YES];
    }
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CategoryDescription" ofType:@"plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]) {
        self.arrPlistCategory = [NSArray arrayWithContentsOfFile:plistPath];
    }
    else {
        NSLog(@"The file does not exist");
    }
    [self refreshNowPlayingButton];
//    [[NSNotificationCenter defaultCenter] postNotificationName:SWShowSubscriptionScreen object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    [tblCategoryDescription reloadData];
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

#pragma mark - otification For Player ON And OFF
-(void)receivedNotificationForPlayer:(NSNotification *)notification {
    NSInteger ii = [[notification object] integerValue];
    [self.honeycombView setTintColor:[appState.currentPlayList colorStream]];
    if (ii == 1) {
        [self.honeycombView startAnimatingImmediately:NO];
    }
    else {
        [self.honeycombView stopAnimatingImmediately:NO];
    }
}

#pragma mark - PlayerView Actions
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

#pragma mark - Back Button Action
-(IBAction)btnBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - UITAbleview Delegate And DataSources
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
//    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPlistCategory.count;
    /*
    if (section == 0) {
        return self.arrCoreCategory.count;
    }
    if (section == 1) {
        return self.arrPurePlayCategory.count;
    }
    return 1;
     */
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
    SWPlaylistCategory *category;
    if (indexPath.section == 0) {
        category = [self.arrCoreCategory objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        category = [self.arrCoreCategory objectAtIndex:indexPath.row];
    }
    */
    
    CGSize textviewSize = CGSizeMake(tableView.frame.size.width/2, MAXFLOAT);
    
    NSString * strDesc =  [NSString stringWithFormat:@"%@",[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"CategoryDescrption"]];
    CGSize constrainedSize = CGSizeMake(textviewSize.width  , 9999);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:12.0], NSFontAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strDesc attributes:attributesDictionary];
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat heightText = requiredHeight.size.height;
    
    if (heightText <= 90) {
        return 90;
    }else{
        return (heightText + 60);
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SWCategoryDescriptionTableViewCell *cell = [tblCategoryDescription dequeueReusableCellWithIdentifier:@"CategoryDescriptionCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSArray *words = [[[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"CategoryName"] uppercaseString] componentsSeparatedByString:@" "];
    
    cell.layout_Constraint_Width_Imageview.constant  = ((tableView.frame.size.width*48)/100);
    
    UIFont *ArialFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: ArialFont forKey:NSFontAttributeName];
    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: arialdict];
    
    UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc]initWithString:words[1] attributes:veradnadict];
    NSMutableAttributedString *SpaceString = [[NSMutableAttributedString alloc] initWithString:@" "];

    [AattrString appendAttributedString:SpaceString];
    [AattrString appendAttributedString:VattrString];
    
    [cell.lblCategoryName setAttributedText:AattrString];
    [cell.txtViewCategoryDescription setText:[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"CategoryDescrption"]];
    [cell.image1 setImage:[UIImage imageNamed:[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"image1"]]];
    [cell.image2 setImage:[UIImage imageNamed:[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"image2"]]];
    [cell.image3 setImage:[UIImage imageNamed:[[self.arrPlistCategory objectAtIndex:indexPath.row] objectForKey:@"image3"]]];
    NSLog(@"Category Decription:%@",cell.txtViewCategoryDescription.text);
    NSString * strDesc =  cell.txtViewCategoryDescription.text;
    CGSize constrainedSize = CGSizeMake(cell.txtViewCategoryDescription.frame.size.width  , 9999);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue" size:12.0], NSFontAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strDesc attributes:attributesDictionary];
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    [cell.layout_Constraint_Height_textview setConstant:requiredHeight.size.height + 10];
    
    /*
     [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
     [cell.lblCategoryName setText:@""];
     [cell.txtViewCategoryDescription setText:@""];
     [cell.image1 setImageURL:nil];
     [cell.image2 setImageURL:nil];
     [cell.image3 setImageURL:nil];
    [cell.image1 setShowActivityIndicator:TRUE];
    [cell.image2 setShowActivityIndicator:TRUE];
    [cell.image3 setShowActivityIndicator:TRUE];
    NSString *strURL1  = @"";
    NSString *strURL2  = @"";
    NSString *strURL3  = @"";
    SWPlaylistCategory *category;
    if (indexPath.section == 0) {
        category = [self.arrCoreCategory objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        category = [self.arrCoreCategory objectAtIndex:indexPath.row];
    }
     NSArray *words = [category.categoryName.uppercaseString componentsSeparatedByString:@" "];
    
    UIFont *ArialFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    NSDictionary *arialdict = [NSDictionary dictionaryWithObject: ArialFont forKey:NSFontAttributeName];
    NSMutableAttributedString *AattrString = [[NSMutableAttributedString alloc] initWithString:words[0] attributes: arialdict];
    
    UIFont *VerdanaFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    NSDictionary *veradnadict = [NSDictionary dictionaryWithObject:VerdanaFont forKey:NSFontAttributeName];
    NSMutableAttributedString *VattrString = [[NSMutableAttributedString alloc]initWithString:words[1] attributes:veradnadict];
    NSMutableAttributedString *SpaceString = [[NSMutableAttributedString alloc] initWithString:@" "];
//    [VattrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:(NSMakeRange(0, VattrString.length))];
    [AattrString appendAttributedString:SpaceString];
    [AattrString appendAttributedString:VattrString];
    
    cell.lblCategoryName.attributedText = AattrString;
    cell.txtViewCategoryDescription.text = [category categoryDescLong];
    
    [cell.image1 setImageURL:[NSURL URLWithString:strURL1]];
    [cell.image2 setImageURL:[NSURL URLWithString:strURL2]];
    [cell.image3 setImageURL:[NSURL URLWithString:strURL3]];
    
    CGFloat heightText = [SWAppDelegate heightOfTextForString:cell.txtViewCategoryDescription.text andFont:cell.txtViewCategoryDescription.font maxSize:CGSizeMake(cell.txtViewCategoryDescription.bounds.size.width, MAXFLOAT)];
    
    [cell.layout_Constraint_Height_textview setConstant:heightText];
     */
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
