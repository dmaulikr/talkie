//
//  GroupShoutOutViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 30/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "CustomView.h"
#import <AVFoundation/AVFoundation.h>

@protocol GroupShoutOutDelegate
@required
-(void) sendGroupShoutOut;
@end

@interface GroupShoutOutViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomViewDelegate>
{
    
    NSString * myname;
    BOOL * shoutOutsSent;
    CustomView *myView;
    BOOL messageIsSelected;
    NSUInteger lastSelectedAudioTag;
    id<GroupShoutOutDelegate> _delegate;
    NSMutableArray * audioFileNames;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *friendsCountLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnShoutOut;
@property (weak, nonatomic) IBOutlet UIView *lowerBtnRowView;
@property NSArray * frames;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnSideMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay1;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay2;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay3;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay4;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio1;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio2;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio3;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio4;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) id delegate;
@property (weak, nonatomic) IBOutlet UIImageView *previousView;
@property NSUInteger indexer;
@property AVAudioPlayer * audioPlayer;
@property NSUInteger indexOfUser;
@property NSString * selectedAudio;
@property (weak, nonatomic) IBOutlet UILabel *badgeNotification;
@property (weak, nonatomic) IBOutlet UIButton *btnNotifications;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@end
