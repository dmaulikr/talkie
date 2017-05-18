//
//  ManageFriendsViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 06/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//
#import "FriendListTableViewCell.h"
@interface FBFindFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SWRevealViewControllerDelegate,CustomTableViewCellDelegate>
{
    NSString * resultUsername;
    NSString *resultEmail;
    PFFile *resultProfilePictureData;
    NSMutableArray * pendingRequests;
    NSMutableArray * reqSenderNames;
    NSMutableArray * reqSenderEmails;
    NSMutableArray * reqSenderProfilePictures;
    
    NSMutableArray * foundUserEmail;
    NSMutableArray * foundUserProfilePicture;
    NSMutableArray * foundUsername;
    NSMutableArray * foundUsers;
    NSMutableArray * hideBtnFlags;
    BOOL userFound;
    BOOL requestAccepted;
    
    
    NSArray * searchedUserIds;
}
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UISegmentedControl *friendsSections;
@property (weak, nonatomic) IBOutlet UITableView *tableViewFriendsList;
@property (weak, nonatomic) IBOutlet UITextField *friendsSearchBar;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;
@property (nonatomic) NSInteger selectedSegment;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorLine;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property NSString *themeNumber;
@end
