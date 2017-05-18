//
//  FriendListTableViewCell.m
//  Talkie
//
//  Created by sajjad mahmood on 08/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FriendListTableViewCell.h"

//
@implementation FriendListTableViewCell
@synthesize nameLabel;
@synthesize thumbnailImageView;
@synthesize thumbnailImageFrame;
@synthesize btnAddOrInivte;
@synthesize actionDeterminationFlag;
@synthesize imageFrames;
@synthesize indexer;
@synthesize cellTag;
- (void)awakeFromNib {
    // Initialization code
    
    self.imageFrames = [NSArray arrayWithObjects:@"theme1_friendsmgt_frame.png",@"theme1_main_frame_blue.png",@"theme1_main_frame_orange.png",@"theme1_main_frame_yellow.png",@"theme1_main_frame_green.png",@"theme1_main_frame_purple.png",@"theme1_main_frame_firozi.png",@"theme1_main_frame_pink.png",nil];
    NSString * imageShape = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([imageShape isEqualToString:@"square"])
    {
        self.thumbnailImageView.clipsToBounds = YES;
    }
    else if([imageShape isEqualToString:@"round"])
    {
        self.thumbnailImageView.layer.cornerRadius = self.thumbnailImageView.frame.size.width / 2;
        self.thumbnailImageView.clipsToBounds = YES;
        
    }
    else if([imageShape isEqualToString:@"rounded_square"])
    {
        self.thumbnailImageView.layer.cornerRadius = 9.0f;
        self.thumbnailImageView.clipsToBounds = YES;
        
    }
    //self.thumbnailImageView.layer.cornerRadius = 9.0f;
    //self.thumbnailImageView.clipsToBounds = YES;
    cellTag = self.tag;
    self.btnAddOrInivte.enabled = YES;
    [self setUpCells];
    
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Swipe received.");
}
-(void) setUpCells
{
    //arc4random()%[self.imageFrames count];
    NSString *frameName = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_BORDER_SINGLE];
    UIImage * profilePictureFrame = [UIImage imageNamed:frameName];
    self.thumbnailImageFrame.image = profilePictureFrame;
    //self.badgeCount = [PFInstallation ];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)btnTapped:(id)sender
{
    NSString * lowerString = [self.nameLabel.text lowercaseString];
    NSString * selectedContact= lowerString;
    NSMutableArray * totalRequests = [[NSMutableArray alloc] initWithArray:DataManager.sharedInstance.pendingFriendRequests];
    NSLog(@"Requests original:%@", totalRequests);
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:selectedContact];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error){
        NSString * objectIDD;
        PFUser * contact;
        if([foundUsers count]  == 1)
        {
            for (PFUser *foundUser in foundUsers)
            {
                objectIDD = foundUser.objectId;
                contact = foundUser;
            }
        }
        
        /*if(actionDeterminationFlag == 1)
        {
            NSLog(@"Inviting someone?");
            
        }*/
       if(actionDeterminationFlag == 2 || actionDeterminationFlag == 1)
        {
            self.btnAddOrInivte.enabled = YES;
            //self.btnAddOrInivte.hidden = YES;
            //BOOL friendListCheck = NO;
            //BOOL pendingRequestCheck = NO;
            //BOOL sentRequestCheck = NO;
            PFQuery * query2 = [PFQuery queryWithClassName:@"Social"];
            [query2 whereKey:@"user" equalTo:contact];
            NSString * sendersObjectId = [PFUser currentUser].objectId;
            //PFObject * username = [PFObject objectWithClassName:@"Social"];
            [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *username, NSError * error)
             {
                 if(!error)
                 {
                     NSArray * targetsRequests = username[@"pendingRequests"];
                     NSString * targetsId = [[username objectForKey:@"user"]objectId];
                     BOOL pendingRequestCheck= [DataManager.sharedInstance.pendingFriendRequests containsObject:targetsId];
                     BOOL friendListCheck= [DataManager.sharedInstance.retrievedFriends containsObject:targetsId];
                     BOOL sentRequestCheck = [targetsRequests containsObject:[PFUser currentUser].objectId];
                     if([targetsId isEqualToString:[PFUser currentUser].objectId]|| pendingRequestCheck ==YES ||friendListCheck == YES || sentRequestCheck == YES)
                     {
                         self.btnAddOrInivte.enabled = NO;
                         NSString * errorString;
                         if([targetsId isEqualToString:[PFUser currentUser].objectId])
                         {
                             errorString = @"Can't add your own ID";
                         }
                         else if(pendingRequestCheck ==YES)
                         {
                             errorString = @"Pending request exists. Please see your pending requests";
                         }
                         else if(friendListCheck == YES)
                         {
                             errorString = @"User's already exists in Friend List";
                         }
                         else if(sentRequestCheck)
                         {
                             errorString = @"You have already sent a request to this user";
                         }
                         UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [errorAlertView show];
                         
                     }
                     
                     else if(![targetsId isEqualToString:[PFUser currentUser].objectId]&&pendingRequestCheck ==NO && friendListCheck == NO &&sentRequestCheck ==NO)
                     {
                         NSArray * targetsBlockedContacts = [[NSArray alloc] initWithArray:username[@"blockedContacts"]];
                         BOOL currentUserBlocked = [targetsBlockedContacts containsObject: [PFUser currentUser].objectId];
                         NSArray * myBlockedContacts = [[NSArray alloc] initWithArray:DataManager.sharedInstance.blockedContacts];
                         BOOL targetsStatus = [myBlockedContacts containsObject:targetsId];
                         if(currentUserBlocked ==YES)
                         {
                             NSString * errorString = @"User has blocked you";
                             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                             
                             [errorAlertView show];
                         }
                         else if(targetsStatus ==YES)
                         {
                             NSString * errorString = @"You have blocked this contact";
                             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                             [errorAlertView show];
                         }
                         else if(currentUserBlocked == NO &&targetsStatus == NO)
                         {
                             NSMutableArray *pendingRequestsOfTargetUser = [[NSMutableArray alloc] initWithArray:username[@"pendingRequests"]];
                             [pendingRequestsOfTargetUser addObject:sendersObjectId];
                             NSArray * updatedRequests = pendingRequestsOfTargetUser;
                             username[@"pendingRequests"] = updatedRequests;
                             [username saveInBackground];
                             NSString *errorString = @"Friend Request Sent";
                             
                             self.btnAddOrInivte.enabled = NO;
                             NSString * senderName =  [PFUser currentUser].username;
                             NSLog(@"%@", senderName);
                             [DataManager sendAddRequestNotification:senderName totalRequests:[pendingRequestsOfTargetUser count] andReceiverID:targetsId];
                             if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(reloadMyTable)])
                             {
                                 [self getFriendsUsernames];
                             }
                             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                             [errorAlertView show];
                         }
                         
                         
                     }
                 }
                 
             }];
            
            
        }
        else if(actionDeterminationFlag == 3)
        {
            //self.btnAddOrInivte.hidden = YES;
            PFQuery * query2 = [PFQuery queryWithClassName:@"Social"];
            [query2 whereKey:@"user" equalTo:[PFUser currentUser]];
            NSString * sendersObjectId = objectIDD;
            [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *username, NSError * error)
             {
                 if(!error)
                 {
                     if(username)
                     {
                         NSMutableArray *pendingRequestsOfCurrentUser = [[NSMutableArray alloc] initWithArray:username[@"pendingRequests"]];
                         NSMutableArray * currentFriendsofCurrentUser = [[NSMutableArray alloc] initWithArray:username[@"nativeFriendsIds"]];
                         [pendingRequestsOfCurrentUser removeObject:sendersObjectId];
                         NSArray * updatedRequests = pendingRequestsOfCurrentUser;
                         username[@"pendingRequests"] = updatedRequests;
                         [currentFriendsofCurrentUser addObject:objectIDD];
                         NSArray *updatedFriends = currentFriendsofCurrentUser;
                         DataManager.sharedInstance.retrievedFriends = nil;
                         DataManager.sharedInstance.retrievedFriends = currentFriendsofCurrentUser;
                         DataManager.sharedInstance.pendingFriendRequests = [[NSMutableArray alloc] initWithArray: updatedRequests];
                         
                         DataManager.sharedInstance.reqSenderEmails = [[NSMutableArray alloc] init];
                         DataManager.sharedInstance.reqSenderProfilePictures = [[NSMutableArray alloc] init];
                         DataManager.sharedInstance.reqSenderNames = [[NSMutableArray alloc] init];
                         self.badgeCount = [DataManager.sharedInstance.pendingFriendRequests count];
                         username[@"nativeFriendsIds"] = updatedFriends;
                         
                         [username saveInBackground];
                         NSLog(@"DONE");
                         
                         NSString *errorString = @"Friend request accepted";
                         
                         [DataManager sendRequestAcceptedNotification:[PFUser currentUser].username andReceiverID:objectIDD];
                         if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(reloadMyTable)])
                         {
                             [self getFriendsUsernames];
                             NSLog(@"Delegate: %@", self.delegate);
                             [self.delegate reloadMyTable];
                         }
                         UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [errorAlertView show];
                         
                     }
                     PFQuery *query3 = [PFQuery queryWithClassName:@"Social"];
                     [query3 whereKey:@"user" equalTo:contact];
                     [query3 getFirstObjectInBackgroundWithBlock:^(PFObject *username, NSError *error) {
                         
                         if(!error)
                         {
                             
                             NSMutableArray * currentFriendsofCurrentUser = [[NSMutableArray alloc] initWithArray:username[@"nativeFriendsIds"]];
                             [currentFriendsofCurrentUser addObject:[PFUser currentUser].objectId];
                             NSArray *updatedFriends = currentFriendsofCurrentUser;
                             username[@"nativeFriendsIds"] = updatedFriends;
                             [username saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
                                 if(!error)
                                 {
                                     NSLog(@"DONE");
                                     
                                 }
                                 else
                                 {
                                     NSLog(@"Failed: %@", error);
                                 }
                             }];
                             [username refresh];
                         }
                         else{
                             NSLog (@"Failed :%@", error);
                         }
                     }];
                 }
             }];
        }
        
    }];
}

-(void) getFriendsUsernames
{
    NSMutableArray * objectIDs = [[NSMutableArray alloc] initWithArray: DataManager.sharedInstance.retrievedFriends];
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    //UIImage *profilePictureData;
    
    [DataManager.sharedInstance.friendsUsernames removeAllObjects];
    [DataManager.sharedInstance.friendsEmailAdresses removeAllObjects];
    [DataManager.sharedInstance.friendsProfilePictures removeAllObjects];
    [DataManager.sharedInstance.pendingFriendRequests removeAllObjects];
    [DataManager.sharedInstance.reqSenderEmails removeAllObjects];
    [DataManager.sharedInstance.reqSenderNames removeAllObjects];
    [DataManager.sharedInstance.reqSenderProfilePictures removeAllObjects];
    NSUInteger friendsCount = [objectIDs count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:objectIDs[i]];
        [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
        [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
        
        //NSLog(@"%@",username[@"ProfilePicture"]);
        imageFile = [username objectForKey:@"profilePicture"];
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        
        [DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
        NSLog(@"%@", DataManager.sharedInstance.friendsUsernames );
    }
    [self getPendingRequests];
    [self getRequestSendersProfile];
    
}


-(void) getPendingRequests
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    PFObject * object = [query getFirstObject];
    DataManager.sharedInstance.pendingFriendRequests = [[NSMutableArray alloc] initWithArray:object[@"pendingRequests"]];
    NSLog (@"Pending reqs: %@", DataManager.sharedInstance.pendingFriendRequests);
}

-(void) getRequestSendersProfile
{
    NSMutableArray * objectIDs = [[NSMutableArray alloc] initWithArray: DataManager.sharedInstance.pendingFriendRequests];
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    //UIImage *profilePictureData;
    NSUInteger requestsCount = [objectIDs count];
    if([objectIDs count]!=0)
    {
        for(int i = 0; i<requestsCount;i++)
        {
            PFObject * username =  [query getObjectWithId:objectIDs[i]];
            [DataManager.sharedInstance.reqSenderNames addObject:username[@"username"]];
            [DataManager.sharedInstance.reqSenderEmails addObject:username[@"email"]];
            
            //NSLog(@"%@",username[@"ProfilePicture"]);
            imageFile = [username objectForKey:@"profilePicture"];
            NSData *imageData = [imageFile getData];
            UIImage *imageFromData = [UIImage imageWithData:imageData];
            [DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
            NSLog(@"Request Sender:%@", DataManager.sharedInstance.reqSenderNames );
        }
        
    }
}


- (BOOL) requestFriendListValidation:(NSString *)targetId{
    
    for (int i = 0 ; i < [DataManager.sharedInstance.retrievedFriends count ] ; i++)
    {
        if ([[DataManager.sharedInstance.retrievedFriends objectAtIndex:i] isEqualToString:targetId])
        {
            break;
            return YES;
        }
        
    }
    return NO;
}


-(void) contactSelected
{
    NSString *titleString = [self generateTitleString:FBF_BTN_ADD];

    if(self.btnAddOrInivte.tag == 1000)
    {
        NSString * lower = [self.nameLabel.text lowercaseString];
        [DataManager.sharedInstance.selectedContacts addObject:lower];
        if(actionDeterminationFlag==2 || actionDeterminationFlag ==1)
        {
            [self.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        }
        else if(actionDeterminationFlag ==3)
        {
            titleString = [self generateTitleString:FBF_BTN_ADDED];
            [self.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        }
        self.btnAddOrInivte.tag = 1001;

    }
    else if(self.btnAddOrInivte.tag==1001)
    {
        NSString * lower = [self.nameLabel.text lowercaseString];
        [DataManager.sharedInstance.selectedContacts removeObject:lower];
        if(actionDeterminationFlag==2 || actionDeterminationFlag ==1)
        {
            titleString = [self generateTitleString:FBF_BTN_ADD];
        [self.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        }
        else if(actionDeterminationFlag ==3)
        {
            titleString = [self generateTitleString:FBF_BTN_ADDED];
            [self.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        }
        self.btnAddOrInivte.tag = 1000;
    }
    
    
}
-(NSString *) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return  titleString;
}

-(void)populateDataSuggestions:(NSString* ) name withEmail: (NSString * ) email andIndexPath: (NSUInteger) indexPath andArray:(NSArray *) array andTargetArray: (NSMutableArray *) targetArray
{
    self.nameLabel.text = name;
    self.emailLbl.text = email;
    
    PFQuery *query = [PFUser query];
    NSString *objectId = [array objectAtIndex:indexPath];
    [self.activityIndicator startAnimating];
    [query whereKey:@"objectId" equalTo:objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error)
     {
         if(!error)
         {
             if([object objectForKey:@"profilePicture"]!=nil)
             {
                 PFFile *imageFile;
                 imageFile = [object objectForKey:@"profilePicture"];
                 NSData *imageData = [imageFile getData];
                 UIImage *imageFromData = [UIImage imageWithData:imageData];
                 [targetArray replaceObjectAtIndex:indexPath withObject:imageFromData];
                 
                 self.thumbnailImageView.image = imageFromData;
                 [self.activityIndicator stopAnimating];
             }
             else
             {
                 UIImage *resultProfilePic = [UIImage imageNamed:@"dummyImage.png"];
                 [targetArray replaceObjectAtIndex:indexPath withObject:resultProfilePic];
                 self.thumbnailImageView.image = resultProfilePic;
                 [self.activityIndicator stopAnimating];
             }
             
             
         }
     }];
    
}

@end
