//
//  FriendListTableViewCell.h
//  Talkie
//
//  Created by sajjad mahmood on 08/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//
#import "CustomTableViewCellDelegate.h"

@interface FriendListTableViewCell : UITableViewCell
{
    UILabel * nameLabel;
    UIImageView * thumbnailImageView;
    
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong) IBOutlet UILabel *nameLabel;
@property (strong) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageFrame;
@property (weak, nonatomic) IBOutlet UIButton *btnAddOrInivte;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property int actionDeterminationFlag;
@property (assign) id<CustomTableViewCellDelegate> delegate;
@property NSArray * imageFrames;
@property NSUInteger indexer;
@property NSUInteger badgeCount;
@property NSUInteger cellTag;
-(void)populateDataSuggestions:(NSString* ) name withEmail: (NSString * ) email andIndexPath: (NSUInteger) indexPath andArray: (NSArray *) array andTargetArray: (NSMutableArray *) targetArray;

@end
