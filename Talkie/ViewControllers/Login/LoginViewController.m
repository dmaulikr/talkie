//
//  LoginForkViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 19/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "LoginViewController.h"
#import "EmailLoginViewController.h"
#import "SignUpViewController.h"
#import "UsernameViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    self.activityIndicator.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fbFriendsArray = [[NSMutableArray alloc] init];
    self.emojiImageView.image = [UIImage imageNamed:@"talkie.png"];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self clearData];
    // Do any additional setup after loading the view, typically from a nib.

    
}
-(void) viewDidLayoutSubviews
{
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        _scrollView.bounces = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [_scrollView setContentSize:contentSize];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) transitControllers
{
    EmailLoginViewController * login = [[EmailLoginViewController alloc] init];
    
    [self.navigationController pushViewController:login animated:YES];
    
}


-(IBAction)btnLoginWithEmailTapped:(id)sender
{
    [self changeEmoji];
    DataManager.sharedInstance.isFbUser = NO;
    [self performSelector:@selector(transitControllers) withObject:self afterDelay:0.5];
}

-(void) changeEmoji
{
    int emojiRandomIndex = (arc4random() % 18);
    NSString * randomImage = [NSString stringWithFormat:@"emoticon%i.png",emojiRandomIndex];
    [self.emojiImageView setImage:[UIImage imageNamed:randomImage]];
}


-(IBAction)btnLoginWithFacebookTapped:(id)sender
{
    [self changeEmoji];
  
    [self startAnimation];
    DataManager.sharedInstance.isFbUser = YES;
    // Login PFUser using Facebook
    [self.view endEditing:YES];
    
    NSArray *permissionsArray = @[@"user_about_me", @"email", @"user_friends"];
    
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            if (!error) {
                [self stopAnimation];
                
                    } else {
                        [self stopAnimation];
                           }
            //[self hideActivity];
        }
        else{
        if (user.isNew)
        {
            DataManager.sharedInstance.user = [PFUser currentUser];
            PFInstallation * myInstallation = [PFInstallation currentInstallation];
            myInstallation[@"userId"] = [PFUser currentUser].objectId;
            [myInstallation saveInBackground];

            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error)
                {
                    user[@"fbId"]=result[@"id"];
                    PFObject * social = [PFObject objectWithClassName:@"Social"];
                    PFInstallation * installation = [PFInstallation currentInstallation];
                    [installation setObject:[PFUser currentUser].objectId forKey:@"userId"];
                    NSString * individualChannel = [NSString stringWithFormat:@"individual-%@", result[@"id"]];
                    NSString * groupChannel = [NSString stringWithFormat:@"group-%@", result[@"id"]];
                    NSArray * channel = [NSArray arrayWithObjects:individualChannel,groupChannel, nil];
                    [installation setObject:channel forKey:@"channels"];
                    NSLog(@"Array:%@", self.fbFriendsArray );
                    NSDictionary *userData = (NSDictionary *)result;
                    NSString *facebookID = userData[@"id"];
                    user[@"fbId"] = facebookID;
                    NSString* faceBookUsername =[NSString stringWithFormat:@"%@",[userData[@"name"] lowercaseString]];
                    faceBookUsername = [NSString stringWithFormat:@"%@%@", faceBookUsername, userData[@"id"]];
                    faceBookUsername = [faceBookUsername stringByReplacingOccurrencesOfString:@" " withString:@""];
                    user[@"username"] = faceBookUsername;
                   // user[@"gender"] = userData[@"gender"];
                    /*if(userData[@"birthday"]!=nil)
                    {
                        user[@"dateOfBirth"] = userData[@"birthday"];
                    }
                    else
                    {
                        user[@"dateOfBirth"] = @"NA";
                    }*/
                    user[@"themeId"] = @"1";
                    [[DataManager sharedInstance].defaults setObject:@"1" forKey:@"themeId"];
                    DataManager.sharedInstance.user = [PFUser currentUser];
                    user[@"email"] = userData[@"email"];
                    social[@"fbFriendsIds"] = self.fbFriendsArray;
                    social[@"user"] = [PFUser currentUser];
                    social[@"blockedContacts"] = @[];
                    social[@"pendingRequests"] = @[];
                    social[@"nativeFriendsIds"] = @[];
                    social[@"sentRequests"] = @[];
                    DataManager.sharedInstance.myName = [PFUser currentUser].username;
                    [social saveInBackground];
                    [installation saveInBackground];
                    /*UIImage * profilePicture = [self friendImage: result[@"id"]];
                    CGSize size = CGSizeMake(150, 150);
                    UIImage * thumbNail = [self imageWithImage:profilePicture convertToSize:size];
                    NSData * imageData = UIImageJPEGRepresentation(thumbNail, 0.05f);
                    PFFile *imageFile = [PFFile fileWithName:@"destImage.png" data:imageData];
                    user[@"profilePicture"] = imageFile;*/
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(!error)
                        {
                            [self stopAnimation];
                            UsernameViewController * userNameVC = [[UsernameViewController alloc] init];
                            [self stopAnimation];
                            [self.navigationController pushViewController:userNameVC animated:YES];
                        }
                        
                    }];
                }
                else{
                    
                    [self stopAnimation];
                }
            }];
            
            
        }
            //USER already exists
        else
        {
            DataManager.sharedInstance.user = user;
            PFInstallation * myInstallation = [PFInstallation currentInstallation];
            myInstallation[@"userId"] = user.objectId;
            [[DataManager sharedInstance].defaults setObject:user[@"themeId"] forKey:@"themeId"];
            [myInstallation saveInBackground];
            [self getFriendList];
        }
    }
}];

 
}
- (void) getFriendList
{

    PFFile * imageFile = [DataManager.sharedInstance.user objectForKey:@"profilePicture"];
    NSData *imageData = [imageFile getData];
    DataManager.sharedInstance.profilePicture = [UIImage imageWithData:imageData];
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * username, NSError * error)
     {
         if(!error)
         {
             DataManager.sharedInstance.retrievedFriends = username[@"nativeFriendsIds"];
             DataManager.sharedInstance.pendingFriendRequests = username[@"pendingRequests"];
             DataManager.sharedInstance.blockedContacts = username[@"blockedContacts"];
             DataManager.sharedInstance.sentRequests = username[@"sentRequests"];
             if([DataManager.sharedInstance.retrievedFriends count]>0)
             {
                 [self getFriendsUsernames];
             }
             [self getPendingRequests];
             if([DataManager.sharedInstance.pendingFriendRequests count]>0)
             {
                 [self getRequestSendersProfile];
             }
             if([DataManager.sharedInstance.blockedContacts count]>0)
             {
                 [self getBlockedContactsProfile];
             }
             [self getFacebookFriends];
             PFQuery * query = [PFUser query];
             [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
             [query getFirstObjectInBackgroundWithBlock:^(PFObject * user, NSError * error)
              {
                  if(!error)
                  {
                      
                      [self getThemeData:[NSString stringWithFormat:@"%@",user[@"themeId"]]];
                  }
              }];

         
         }
         else
         {
             [self stopAnimation];
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alert show];
         }
         
     }];
}
-(void) getBlockedContactsProfile
{
    PFQuery *query = [PFUser query];
    NSUInteger friendsCount = [DataManager.sharedInstance.blockedContacts count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.blockedContacts[i]];
        [DataManager.sharedInstance.blockedNames addObject:username[@"username"]];
        [DataManager.sharedInstance.blockedEmails addObject:username[@"email"]];
        //imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageNamed:@"dummyImage"];
        [DataManager.sharedInstance.blockedPictures addObject:imageFromData];
        
    }
    
}

-(UIImage*)friendImage:(NSString*)fbId
{
    NSString *path = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",fbId];
    NSURL *url = [NSURL URLWithString:path];

    return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}
- (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return destImage;
}

-(IBAction)btnSignUpTapped:(id)sender
{
    [self changeEmoji];
    DataManager.sharedInstance.isFbUser = NO;
    [self performSelector:@selector(signUpControllerTransition) withObject:self afterDelay:0.5];
    
}

-(void) signUpControllerTransition
{
    SignUpViewController * login = [[SignUpViewController alloc] init];
    
    [self.navigationController pushViewController:login animated:YES];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
                
                self.fbFriendsArray = allFBFriends;
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
    }];
    
    
    
}

-(void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
}
-(void) stopAnimation
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
}

-(void) getFriendsUsernames
{
    PFQuery *query = [PFUser query];
    PFObject * username ;
    NSUInteger friendsCount = [DataManager.sharedInstance.retrievedFriends count];
    for(int i = 0; i<friendsCount;i++)
    {
         username = [query getObjectWithId:DataManager.sharedInstance.retrievedFriends[i]];
        if(username!=nil)
        {
            [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
            [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
            //imageFile = [username objectForKey:@"profilePicture"];
            //NSData *imageData = [imageFile getData];
            //UIImage *imageFromData = [UIImage imageWithData:imageData];
            UIImage *imageNamed = [UIImage imageNamed:@"dummyImage"];
            [DataManager.sharedInstance.friendsProfilePictures addObject:imageNamed];
            //[DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
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
    
}

-(void) getPendingRequests
{
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
     {
         if(!error)
         {
             DataManager.sharedInstance.pendingFriendRequests= object[@"pendingRequests"];
        }
     }];
    
   
}

-(void) getRequestSendersProfile
{
    PFQuery *query = [PFUser query];
    PFObject * username;
    NSUInteger requestsCount = [DataManager.sharedInstance.pendingFriendRequests count];
    for(int i = 0; i<requestsCount;i++)
    {
        username = [query getObjectWithId:DataManager.sharedInstance.pendingFriendRequests[i]];
        
        [DataManager.sharedInstance.reqSenderNames addObject:username[@"username"]];
        [DataManager.sharedInstance.reqSenderEmails addObject:username[@"email"]];
        //imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageNamed:@"dummyImage"];
        [DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
    }
}
-(void) getThemeData: (NSString *) themeId
{
    PFQuery * query  = [PFQuery queryWithClassName:@"Theme"];
    
    [query whereKey:@"themeId" equalTo:themeId];
    themeNumber = themeId;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
     {
         if(!error)
         {
             [DataManager.sharedInstance.themeSpecs addObject:object[@"mainBackground"]];
             [DataManager.sharedInstance.themeSpecs addObject:object[@"shoutOutBackground"]];
             
             PFQuery * query = [PFQuery queryWithClassName:@"Audio"];
             [query whereKey:@"theme" equalTo:object];
             DataManager.sharedInstance.themeAudios = [NSMutableArray arrayWithArray:[query findObjects]];
             [self getMessages];
             
         }
     }];
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
             
             DataManager.sharedInstance.isFirstFbLogin = YES;
             FBFindFriendsViewController * fbVC = [[FBFindFriendsViewController alloc] init];
             fbVC.selectedSegment = 0;
             fbVC.themeNumber = themeNumber;
             [[DataManager sharedInstance].defaults setValue:themeNumber forKey:@"themeId"];
             [self.navigationController pushViewController:fbVC animated:YES];
             [self stopAnimation];
             
         }
     }];
    
    
}

-(void) clearData
{
    
    DataManager.sharedInstance.user = nil;
    DataManager.sharedInstance.retrievedFriends = [[NSMutableArray alloc] init];
    
    
    DataManager.sharedInstance.friendsUsernames = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.friendsProfilePictures = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.friendsEmailAdresses = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.pendingFriendRequests = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.reqSenderNames = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.reqSenderEmails = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.reqSenderProfilePictures = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.blockedContacts = [[NSMutableArray alloc]init];
    DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
    DataManager.sharedInstance.requestBadge = 0;
    DataManager.sharedInstance.userDidReadTheNotification = NO;
    DataManager.sharedInstance.addRequestReceived = NO;
    DataManager.sharedInstance.sentRequests = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.isFbUser = NO;
    DataManager.sharedInstance.suggestedFbFriends = [[NSArray alloc] init];
    DataManager.sharedInstance.fbFriends = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.suggestedFriendsEmails = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.suggestedFriendsProfilePics = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.suggestedFriendsUsernames = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.selectedContacts = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.themeAudios = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.themeSpecs = [[NSMutableArray alloc]init];
    DataManager.sharedInstance.messages = [[NSMutableArray alloc]init];
    DataManager.sharedInstance.groupShoutOutAuthorized = NO;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
