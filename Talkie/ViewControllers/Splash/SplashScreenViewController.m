//
//  SplashScreenViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 19/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "SplashScreenViewController.h"
#import "UsernameViewController.h"
#import "DataManager.h"
@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    _activityIndicator.hidden = YES;
    _activityIndicator.hidesWhenStopped = YES;
  
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _activityIndicator.hidden = YES;
    _activityIndicator.hidesWhenStopped = YES;
    _activityIndicator.hidden = NO;
    
    [_activityIndicator startAnimating];
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error)
     {
         if(!error)
         {
             if([object objectForKey:@"profilePicture"]!=nil)
             {
                 [self loadData];
             }
             else
             {
                 DataManager.sharedInstance.objectID = object.objectId;
                 DataManager.sharedInstance.user = [PFUser currentUser];
                 UsernameViewController * usernameSelectionVC = [[UsernameViewController alloc] init];
                 if(object[@"fbId"]!=nil)
                 {
                     DataManager.sharedInstance.isFbUser = YES;
                 }
                 else
                 {
                     DataManager.sharedInstance.isFbUser = NO;
                 }
                 [self.navigationController pushViewController:usernameSelectionVC animated:YES];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
     }];

    
    
}

-(void) loadData
{
    _activityIndicator.hidden = NO;
    [_activityIndicator startAnimating];
    [self getFriendList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void) setUsername
{

}
- (void) getFriendList
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    PFUser * user = [PFUser currentUser];
    PFQuery *queryPic = [PFUser query];
    [queryPic whereKey:@"username" equalTo:user.username];
    NSArray *userobj = [queryPic findObjects];
    user = [userobj objectAtIndex:0];
    
    [DataManager sharedInstance].user = user;
    PFFile * imageFile = [DataManager.sharedInstance.user objectForKey:@"profilePicture"];
    NSData *imageData = [imageFile getData];
    DataManager.sharedInstance.profilePicture = [UIImage imageWithData:imageData];
    DataManager.sharedInstance.myName = [PFUser currentUser].username;
    
    NSString *fbId = user[@"fbId"];
    if([fbId length]>0)
    {
        DataManager.sharedInstance.isFbUser = YES;
    }
    else{
        DataManager.sharedInstance.isFbUser = NO;
    }
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * username, NSError * error)
     {
         DataManager.sharedInstance.retrievedFriends = username[@"nativeFriendsIds"];
         DataManager.sharedInstance.pendingFriendRequests = username[@"pendingRequests"];
         DataManager.sharedInstance.blockedContacts = username[@"blockedContacts"];
         if([DataManager.sharedInstance.retrievedFriends count]>0)
         {
             [self getFriendsUsernames];
         }
         else
         {
             NSString * themeId = user[@"themeId"];
             //TESTING
             [self getThemeData:themeId];
         }
         
        
         
     }];
}
-(void) getBlockedContactsProfile
{
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger friendsCount = [DataManager.sharedInstance.blockedContacts count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.blockedContacts[i]];
        [DataManager.sharedInstance.blockedNames addObject:username[@"username"]];
        [DataManager.sharedInstance.blockedEmails addObject:username[@"email"]];
        imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageNamed:@"dummyImage"];
        [DataManager.sharedInstance.blockedPictures addObject:imageFromData];
        
    }
    
}


-(void)callbackWithResult:(NSData *)result error:(NSError *)error
{
    if (!error) {
        UIImage * profilePictureData = [UIImage imageWithData:result];
        [DataManager.sharedInstance.friendsProfilePictures addObject:profilePictureData];
    }
}
-(void) getFriendsUsernames
{
    PFQuery *query = [PFUser query];
    NSUInteger friendsCount = [DataManager.sharedInstance.retrievedFriends count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.retrievedFriends[i]];
        if(username!=nil)
        {
            NSLog(@"%i",i);
            [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
            [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
            //imageFile = [username objectForKey:@"profilePicture"];
            // NSData *imageData = [imageFile getData];
            // UIImage *imageFromData = [UIImage imageWithData:imageData];
            UIImage *imageNamed = [UIImage imageNamed:@"dummyImage"];
            [DataManager.sharedInstance.friendsProfilePictures addObject:imageNamed];
        }
        else
        {
            NSLog(@"%@", [[DataManager sharedInstance].retrievedFriends objectAtIndex:i]);
            [[DataManager sharedInstance].retrievedFriends removeObjectAtIndex:i];
            
            [[DataManager sharedInstance].friendsUsernames removeAllObjects];
            [[DataManager sharedInstance].friendsEmailAdresses removeAllObjects];
            [[DataManager sharedInstance].friendsProfilePictures removeAllObjects];
            PFQuery * query = [PFQuery queryWithClassName:@"Social"];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            PFObject *objectToUpdate = [query getFirstObject];
            objectToUpdate[NATIVE_FRIENDS] = [DataManager sharedInstance].retrievedFriends;
            [objectToUpdate save];
            friendsCount--;
            i=0;
            i--;
            NSLog(@"%i",i);

            
            
        }
        
        
    }
    [self getPendingRequests];
    
}

-(void) getPendingRequests
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    PFObject * object = [query getFirstObject];
    DataManager.sharedInstance.pendingFriendRequests= object[@"pendingRequests"];
    if([DataManager.sharedInstance.pendingFriendRequests count]>0)
    {
        [self getRequestSendersProfile];
    }
    
    if([DataManager.sharedInstance.blockedContacts count]>0)
    {
        [self getBlockedContactsProfile];
    }
    NSString * themeId = user[@"themeId"];
    //TESTING
    [self getThemeData:themeId];

    
}

-(void) getRequestSendersProfile
{
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger requestsCount = [DataManager.sharedInstance.pendingFriendRequests count];
    for(int i = 0; i<requestsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.pendingFriendRequests[i]];
        
        [DataManager.sharedInstance.reqSenderNames addObject:username[@"username"]];
        [DataManager.sharedInstance.reqSenderEmails addObject:username[@"email"]];
        
        imageFile = [username objectForKey:@"profilePicture"];
        
        if(imageFile!=nil)
        {
            //NSData *imageData = [imageFile getData];
            UIImage *imageFromData = [UIImage imageNamed:@"dummyImage"];
            [DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
        }
        
        else
        {
            [DataManager.sharedInstance.reqSenderProfilePictures addObject:[UIImage imageNamed:@"dummyImage.png"]];
        }
    }
}


-(void) getMessages
{
    PFQuery * query1 = [PFQuery queryWithClassName:@"Messages"];
    
    [query1 whereKey:@"receiver" containedIn:DataManager.sharedInstance.retrievedFriends];
    
    PFQuery * mainQuery = [PFQuery orQueryWithSubqueries:@[query1]];
    [mainQuery whereKey:@"sender" equalTo:[PFUser currentUser].objectId];
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray * messages, NSError * error)
     {
         if(!error)
         {
             PFObject * messageFilter;
             if([messages count]>0)
             {
                 for(int i=0;i<[DataManager.sharedInstance.retrievedFriends count];i++)
                 {
                     userFound = NO;
                     for(int j = 0;j<[messages count];j++)
                     {
                         messageFilter = [messages objectAtIndex:j];
                         if([messageFilter[@"receiver"] isEqualToString:[DataManager.sharedInstance.retrievedFriends objectAtIndex:i]])
                         {
                             NSString * audioId;
                             audioId = [messageFilter objectForKey:@"message"];
                             //CHAIPI
                             if(audioId!=nil)
                             {
                                 [[DataManager sharedInstance].messages addObject:audioId];
                             }
                             else
                             {
                                 [[DataManager sharedInstance].messages addObject:@" "];
                             }
                             //CHAIPI END
                             userFound = YES;
                         }
                         if(userFound==NO && j==([messages count]-1))
                         {
                             [DataManager.sharedInstance.messages addObject:@" "];
                         }
                     }
                 }
             }
             else
             {
                 for(int i = 0;i<[DataManager.sharedInstance.retrievedFriends count];i++)
                 {
                     [DataManager.sharedInstance.messages addObject:@" "];
                 }
             }
             if([DataManager sharedInstance].isFbUser)
             {
                 [self getFacebookFriends];
                 

             }
             else
             {
                 MainScreenViewController * frontViewController = [[MainScreenViewController alloc] init];
                 RearViewController *rearViewController = [[RearViewController alloc] init];
                 
                 SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
                 //revealController.delegate = self;
                 revealController.rearViewRevealWidth = 101;
                 [_activityIndicator stopAnimating];
                 _activityIndicator.hidden = YES;
                 
                 [self.navigationController pushViewController:revealController animated:YES];
             }
             
         }
     }];
    
    
}

-(void) getThemeData: (NSString *) themeId
{
    PFQuery * query  = [PFQuery queryWithClassName:@"Theme"];
    
    [query whereKey:@"themeId" equalTo:themeId];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
     {
         if(!error)
         {
             [[DataManager sharedInstance].themeSpecs removeAllObjects];
             [DataManager.sharedInstance.themeSpecs addObject:object[@"mainBackground"]];
             [DataManager.sharedInstance.themeSpecs addObject:object[@"shoutOutBackground"]];
             
             [self getMessages];
         }
     }];
}

-(void)getFacebookFriends{
    
    FBRequest *friendsRequest = [FBRequest requestForGraphPath:@"/me/friends"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {
        if(error)
        {
            NSLog(@"%@", error);
        }
        
        else
        {
            NSLog(@"%@", result);
            NSArray *friendObjects = result[DATA];
            NSMutableArray * fbFriends = [NSMutableArray array];
            if (friendObjects.count>0)
            {
                NSMutableArray *allFBFriends = [NSMutableArray array];
                for (NSDictionary *friendObject in friendObjects)
                {
                    
                    NSString *facebookId = friendObject[UNIQUE_ID];
                    NSString *name   = friendObject[@"name"];
                    [fbFriends addObject:facebookId];
                    NSMutableDictionary *fbFriendDict = [@{FACEBOOK_ID:facebookId,@"name":name} mutableCopy];
                    [allFBFriends addObject:fbFriendDict];
                }
                
                NSLog(@"%@", allFBFriends);
                DataManager.sharedInstance.fbFriends = fbFriends;
                PFQuery * suggestionQuery = [PFUser query];
                [suggestionQuery whereKey:@"fbId" containedIn:DataManager.sharedInstance.fbFriends];
                NSArray *foundUserObjects = [[NSArray alloc] init];
                foundUserObjects = [suggestionQuery findObjects];
                NSMutableArray *foundUserObjectIds = [[NSMutableArray alloc] init];
                if([foundUserObjects count]>0)
                {
                    for(int i = 0;i<[foundUserObjects count];i++)
                    {
                        PFUser *user = [foundUserObjects objectAtIndex:i];
                        [foundUserObjectIds addObject:user.objectId];
                    }
                    
                    DataManager.sharedInstance.suggestedFbFriends = [[NSArray alloc] initWithArray:foundUserObjectIds];

                }
                
                if([DataManager.sharedInstance.suggestedFbFriends count]>0)
                {
                    for(PFUser * foundUser in foundUserObjects)
                    {
                        if([DataManager.sharedInstance.retrievedFriends containsObject:foundUser.objectId])
                        {
                            [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"1"];
                        }
                        else if([DataManager.sharedInstance.pendingFriendRequests containsObject:foundUser.objectId])
                        {
                            [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"4"];
                        }
                        else if(![DataManager.sharedInstance.retrievedFriends containsObject:foundUser.objectId] && ![DataManager.sharedInstance.pendingFriendRequests containsObject:foundUser.objectId])
                        {
                            [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"0"];
                        }
                        
                        NSLog (@"Suuggestions now: %@", DataManager.sharedInstance.suggestedHideBtnFlags);
                        
                        [DataManager.sharedInstance.suggestedFriendsEmails addObject:foundUser[@"email"]];
                        [DataManager.sharedInstance.suggestedFriendsUsernames addObject:foundUser[@"username"]];
                        [DataManager.sharedInstance.suggestedFriendsProfilePics addObject:[UIImage imageNamed:@"dummyImage.png"]];
                        
                    }
                }
            }
        }
        DataManager.sharedInstance.isFirstFbLogin = YES;
        FBFindFriendsViewController * fbVC = [[FBFindFriendsViewController alloc] init];
        fbVC.selectedSegment = 0;
        PFUser * user = [PFUser currentUser];
        NSString * themeId = user[@"themeId"];
        fbVC.themeNumber = themeId;
        [[DataManager sharedInstance].defaults setValue:themeId forKey:@"themeId"];
        [self.navigationController pushViewController:fbVC animated:YES];
    }];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
