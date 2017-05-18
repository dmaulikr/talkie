//
//  FriendManagementTableViewCell.m
//  Talkie
//
//  Created by sajjad mahmood on 13/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FriendManagementTableViewCell.h"
@implementation FriendManagementTableViewCell
@synthesize usernameLbl;
@synthesize thumbnailImageView;
@synthesize emailLbl;
@synthesize delegate;
- (void)awakeFromNib {
    // Initialization code
    self.imageFrames = [NSArray arrayWithObjects:@"theme1_friendsmgt_frame.png",@"theme1_main_frame_blue.png",@"theme1_main_frame_orange.png",@"theme1_main_frame_yellow.png",@"theme1_main_frame_green.png",@"theme1_main_frame_purple.png",@"theme1_main_frame_firozi.png",@"theme1_main_frame_pink.png",nil];
   // self.thumbnailImageView.layer.cornerRadius = 10.0f;
    //self.thumbnailImageView.clipsToBounds = YES;
    
    [self setUpCells];
}

-(void) setUpCells
{
    //NSUInteger indexOfImage = 0;//arc4random()%[self.imageFrames count];
    //UIImage * profilePictureFrame = [UIImage imageNamed:self.imageFrames[indexOfImage]];
    //self.thumbnailImageFrame.image = profilePictureFrame;
    
    NSString *themeId = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([themeId isEqualToString:@"square"])
    {
        self.thumbnailImageView.clipsToBounds = YES;
    }
    else if([themeId isEqualToString:@"round"])
    {
        self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.size.width / 2;
        self.thumbnailImageView.clipsToBounds = YES;
        
    }
    else if([themeId isEqualToString:@"rounded_square"])
    {
        self.thumbnailImageView.layer.cornerRadius = 9.0f;
        self.thumbnailImageView.clipsToBounds = YES;
        
    }
    NSString *titleString = [self generateTitleString:MANAGE_FRIENDS_BTN_BLOCK];
    [_btnBlock setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    titleString = [self generateTitleString:MANAGE_FRIENDS_BTN_UNFRIEND];
    [_btnUnfriend setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSString *) generateTitleString: (NSString*) key
{
    NSString *titleStringo;
    titleStringo = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return  titleStringo;
}
-(void)populateData:(NSString* ) name withEmail: (NSString * ) email andPicture: (UIImage *) userPic andIndexPath: (int) indexPath
{
    
    //MERGER START
    NSMutableArray *combinedList = [[NSMutableArray alloc] init];
    NSMutableArray *combinedListPictures = [[NSMutableArray alloc] init];
    combinedList = [[DataManager.sharedInstance.retrievedFriends arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedContacts] mutableCopy];
       combinedListPictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.friendsProfilePictures];
    combinedListPictures = [[combinedListPictures arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedPictures] mutableCopy];
    //MERGER END

    
    
    
    self.usernameLbl.text = name;
    self.emailLbl.text = email;
    
    PFQuery *query = [PFUser query];
    NSString *objectId = [combinedList objectAtIndex:indexPath];
    [self.userActivity startAnimating];
    [query whereKey:@"objectId" equalTo:objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error)
     {
         if(!error)
         {
             PFFile *imageFile;
             imageFile = [object objectForKey:@"profilePicture"];
             NSData *imageData = [imageFile getData];
             UIImage *imageFromData = [UIImage imageWithData:imageData];
             [combinedListPictures replaceObjectAtIndex:indexPath withObject:imageFromData];
             
             self.thumbnailImageView.image = imageFromData;
             [self.userActivity stopAnimating];
             
         }
     }];
    
}

@end
