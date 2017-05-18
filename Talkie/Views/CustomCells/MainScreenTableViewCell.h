//
//  MainScreenTableViewCell.h
//  Talkie
//
//  Created by sajjad mahmood on 17/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//
#import "CustomTableViewCellDelegate.h"
@interface MainScreenTableViewCell : UITableViewCell
{
    
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnShoutOut;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorLine;
@property (weak, nonatomic) IBOutlet UIImageView *roundIcon;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureFrame;
@property NSMutableArray * separatorLines;
@property NSMutableArray * roundIcons;
@property NSMutableArray * shoutOutButtons;
@property NSMutableArray * imageFrames;
@property (assign) id<CustomTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property NSUInteger indexer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(void)populateData:(NSString* ) name  withMessage: (NSString * ) message andPicture: (UIImage *) userPic andIndexPath: (int) indexPath;
@end
