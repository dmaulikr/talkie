//
//  ManageFriendsForEmailLoginViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 24/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//
#import "FriendListTableViewCell.h"

@interface FindFriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIActionSheetDelegate, UITextFieldDelegate,CustomTableViewCellDelegate>
{
    PFFile *resultProfilePictureData;
    NSMutableArray * nativeFriends;
    NSMutableArray * profilePictures;
    NSMutableArray * emailLists;
    NSMutableArray * pendingRequests;
    NSMutableArray * reqSenderNames;
    NSMutableArray * reqSenderEmails;
    NSMutableArray * reqSenderProfilePictures;
    NSMutableArray * searchResultFriends;
    NSMutableArray * searchResultProfilePictures;
    NSMutableArray * searchResultEmails;
    CGRect frameDefault;
    NSMutableArray * hideBtnFlags;
    NSMutableArray * addedFriends;
    
    NSArray * searchedUserIds;
}
@property (weak, nonatomic) IBOutlet UIImageView *inputLine;

@property (nonatomic) NSInteger selectedSegment;
@property (weak, nonatomic) IBOutlet UITableView *tableViewFriendsList;
@property (weak, nonatomic) IBOutlet UITextField *friendsSearchBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *friendsSections;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UILabel *requestCount;
@property (weak, nonatomic) IBOutlet UIImageView *badgeBackground;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;

@end
