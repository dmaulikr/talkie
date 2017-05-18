//
//  MainScreenViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 17/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//
#import "MainScreenTableViewCell.h"
#import "GroupShoutOutViewController.h"
#import "SWRevealViewController.h"
#import "MenuView.h"
#import "Constants.h"
#import "DataManager.h"
#import "FindFriendsViewController.h"
#import "FBFindFriendsViewController.h"
#import "RearViewController.h"
@interface MainScreenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GroupShoutOutDelegate,CustomTableViewCellDelegate,SWRevealViewControllerDelegate,MenuViewDelegate>
{
    BOOL userFound;
    CGRect frameDefault;
    NSString *themeNumber;
    MenuView *menuView;
    
    BOOL searchBarOpened;
    
    //FOR DISPLAYING LOCAL SEARCH RESULTS
    NSMutableArray *searchedName;
    NSMutableArray *searchedEmail;
    NSMutableArray *searchedProfilePicture;
    NSMutableArray *searchedMessage;
    NSMutableArray *searchedTags;
    UIActivityIndicatorView *activity1;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnDragDownMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnAddMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnSideMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnShoutOut;
@property (weak, nonatomic) IBOutlet UIButton *btnNotifications;
@property (weak, nonatomic) IBOutlet UIImageView *mainScreenBackgroundImgView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMainFriendList;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonView;
@property NSUInteger indexer;
@property (weak, nonatomic) IBOutlet UILabel *badgeNotification;
@property (weak, nonatomic) IBOutlet UIImageView *badgeBackgroundView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *pushActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;


@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
