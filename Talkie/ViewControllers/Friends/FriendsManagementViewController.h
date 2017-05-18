//
//  FriendsManagementViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 13/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FriendManagementTableViewCell.h"

@interface FriendsManagementViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,CustomTableViewCellDelegate>
{
    NSMutableArray * combinedListNames;
    NSMutableArray * combinedListEmails;
    NSMutableArray * combinedListPictures;
    NSMutableArray * combinedList;
    NSUInteger pointOfMerger;
    NSUInteger indexer;
    NSString *titleString;
}
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *navigationBar;


@end
