//
//  MainScreenTableViewCell.m
//  Talkie
//
//  Created by sajjad mahmood on 17/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "MainScreenTableViewCell.h"

@implementation MainScreenTableViewCell
@synthesize usernameLbl;
@synthesize profilePicture;
@synthesize delegate;
@synthesize indexer;
@synthesize imageFrames;
@synthesize profilePictureFrame;
@synthesize separatorLines;
@synthesize seperatorLine;
@synthesize roundIcons;
@synthesize roundIcon;
@synthesize shoutOutButtons;
@synthesize btnShoutOut;
- (void)awakeFromNib {
    // Initialization code
    NSString * themeId = [DataManager.sharedInstance.defaults objectForKey:@"themeId"];
    
    self.separatorLines = [[NSMutableArray alloc] init];
    self.roundIcons = [[NSMutableArray alloc] init];
    self.shoutOutButtons = [[NSMutableArray alloc] init];
    self.imageFrames = [[NSMutableArray alloc] init];
    NSString * name;
    for(int i = 0; i<7;i++)
    {
        name = [NSString stringWithFormat:@"theme%@_main_line_%i",themeId,i];
        [self.separatorLines addObject:name];
        name = [NSString stringWithFormat:@"theme%@_main_%i_small_circle", themeId,i];
        [self.roundIcons addObject:name];
        name = [NSString stringWithFormat:@"theme%@_main_send_%i", themeId, i];
        [self.shoutOutButtons addObject:name];
        name = [NSString stringWithFormat:@"theme%@_main_image_%i", themeId, i];
        [self.imageFrames addObject:name];
        
    }
    themeId = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([themeId isEqualToString:@"square"])
    {
        self.profilePicture.clipsToBounds = YES;
    }
    else if([themeId isEqualToString:@"round"])
    {
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = YES;
    }
    else if([themeId isEqualToString:@"rounded_square"])
    {
        self.profilePicture.layer.cornerRadius = 9.0f;
        self.profilePicture.clipsToBounds = YES;
        
    }
    
    else
    {
        self.profilePicture.layer.cornerRadius = 9.0f;
        self.profilePicture.clipsToBounds = YES;

    }
    
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    //[self setUpCells];
    
}

-(void) stopAnimation
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

-(void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}
-(void) setUpCells
{
    NSUInteger indexOfImage = arc4random()%[self.separatorLines count];
    UIImage * sepLine = [UIImage imageNamed:self.separatorLines[indexOfImage]];
    self.seperatorLine.image = sepLine;
    UIImage * sendBtn = [UIImage imageNamed:self.shoutOutButtons[indexOfImage]];
    [self.btnShoutOut setBackgroundImage:sendBtn forState:UIControlStateNormal];
    UIImage * roundIco = [UIImage imageNamed:self.roundIcons[indexOfImage]];
    self.roundIcon.image = roundIco;
    UIImage * profilePictureFrame1 = [UIImage imageNamed:self.imageFrames[indexOfImage]];
    self.profilePictureFrame.image = profilePictureFrame1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)populateData:(NSString* ) name withMessage: (NSString * ) message andPicture: (UIImage *) userPic andIndexPath: (int) indexPath
{
    self.usernameLbl.text = name;
    self.lastMessageLbl.text = message;
    
    PFQuery *query = [PFUser query];
    NSString *objectId = [[DataManager sharedInstance].retrievedFriends objectAtIndex:indexPath];
    [self.imageActivityIndicator startAnimating];
    [query whereKey:@"objectId" equalTo:objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error)
     {
         if(!error)
         {
             PFFile *imageFile;
             imageFile = [object objectForKey:@"profilePicture"];
             NSData *imageData = [imageFile getData];
             UIImage *imageFromData = [UIImage imageWithData:imageData];
             [[DataManager sharedInstance].friendsProfilePictures replaceObjectAtIndex:indexPath withObject:imageFromData];
             self.profilePicture.image = imageFromData;
             [self.imageActivityIndicator stopAnimating];
             
         }
     }];

}
@end
