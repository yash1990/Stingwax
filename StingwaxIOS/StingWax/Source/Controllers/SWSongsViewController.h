//
//  SWSongsViewController.h
//  StingWax
//
//  Created by Mark Perkins on 6/27/13.
//
//

#import <UIKit/UIKit.h>

#import "SWBaseViewController.h"
#import "SWHoneycombView.h"
//Helpers

#import "SWSongTableViewCell.h"

@protocol SongListViewControllerDelegate;


@interface SWSongsViewController : SWBaseViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}
@property (weak, nonatomic) id <SongListViewControllerDelegate> delegate;
@property (nonatomic) IBOutlet SWHoneycombView *honeycombView;
@property (nonatomic) NSInteger currentTrackNumber;
@property (nonatomic, strong) UIImage *backgorundImage;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@end


@protocol SongListViewControllerDelegate <NSObject>

- (BOOL)songListViewControllerDelegate:(SWSongsViewController *)controller didTapTrack:(int)trackNumber withCompletion:(void(^)(BOOL finished))completion;
-(void)cleanPlayerRequestFromSongsViewController:(id)sender;

@end
