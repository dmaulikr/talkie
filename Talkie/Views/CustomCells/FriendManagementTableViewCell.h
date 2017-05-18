//
//  FriendManagementTableViewCell.h
//  Talkie
//
//  Created by sajjad mahmood on 13/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "CustomTableViewCellDelegate.h"
@interface FriendManagementTableViewCell : UITableViewCell
{
    //id<CustomTableCellDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *usernameLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnUnfriend;
@property (weak, nonatomic) IBOutlet UILabel *emailLbl;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *btnBlock;
@property (assign) id<CustomTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageFrame;
@property NSArray * imageFrames;
@property UIButton * btnUnblock;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *userActivity;
-(void)populateData:(NSString* ) name withEmail: (NSString * ) email andPicture: (UIImage *) userPic andIndexPath: (int) indexPath;
@end
