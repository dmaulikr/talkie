//
//  SingleShoutOutViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 09/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "MenuView.h"
@interface SingleShoutOutViewController : UIViewController <UIGestureRecognizerDelegate,MenuViewDelegate>
{
    
    NSUInteger lastSelectedAudioTag;
    NSMutableArray * audioFileNames;
    UIButton * btnDragDownMenu;
    NSString *themeNumber;
    MenuView *menuView;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *lowerBtnView;
@property (weak, nonatomic) IBOutlet UIImageView *friendImage;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnSendPush;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio1;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio2;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio3;
@property (weak, nonatomic) IBOutlet UIButton *btnAudio4;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay1;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay2;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay3;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay4;
@property (weak, nonatomic) IBOutlet UIImageView *friendProfilePicture;
@property (weak, nonatomic) IBOutlet UIButton *btnSideMenu;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *btnDragDownHandle;
@property NSString * selectedAudio;
@property AVAudioPlayer * audioPlayer;
@property NSUInteger indexOfUser;
@property (weak, nonatomic) IBOutlet UILabel *badgeNotification;
@property (weak, nonatomic) IBOutlet UIButton *btnNotifications;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorLine;
@property (weak, nonatomic) IBOutlet UIImageView *frame;
@property (weak, nonatomic) IBOutlet UIImageView *halfCircle;
@end
