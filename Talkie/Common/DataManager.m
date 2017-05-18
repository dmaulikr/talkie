//
//  sharedClass.m
//  Mazeltov
//
//  Created by sajjad mahmood on 23/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "DataManager.h"
@implementation DataManager
+ (DataManager *)sharedInstance
{

    static DataManager *_sharedInstance = nil;
    

    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataManager alloc] init];
    });
    return _sharedInstance;
}

-(id) init
{
    if (self = [super init])
    {
        _user = [PFUser user];
        _friendsUsernames = [[NSMutableArray alloc] init];
        _retrievedFriends = [[NSMutableArray alloc] init];
        _friendsProfilePictures = [[NSMutableArray alloc] init];
        _friendsEmailAdresses = [[NSMutableArray alloc] init];
        _pendingFriendRequests = [[NSMutableArray alloc] init];
        _reqSenderNames = [[NSMutableArray alloc] init];
        _reqSenderEmails = [[NSMutableArray alloc] init];
        _reqSenderProfilePictures = [[NSMutableArray alloc] init];
        _blockedContacts = [[NSMutableArray alloc]init];
        _foundUsers = [[NSMutableArray alloc] init];
        _requestBadge = 0;
        _userDidReadTheNotification = NO;
        _addRequestReceived = NO;
        _sentRequests = [[NSMutableArray alloc] init];
        _isFbUser = NO;
        _suggestedFbFriends = [[NSArray alloc] init];
        _fbFriends = [[NSMutableArray alloc] init];
        _suggestedFriendsEmails = [[NSMutableArray alloc] init];
        _suggestedFriendsProfilePics = [[NSMutableArray alloc] init];
        _suggestedFriendsUsernames = [[NSMutableArray alloc] init];
        _selectedContacts = [[NSMutableArray alloc] init];
        _blockedNames = [[NSMutableArray alloc] init];
        _blockedPictures = [[NSMutableArray alloc] init];
        _blockedEmails = [[NSMutableArray alloc] init];
        _selectedTheme = @"1";
        _themeAudios = [[NSMutableArray alloc] init];
        _themeSpecs = [[NSMutableArray alloc]init];
        _messages = [[NSMutableArray alloc]init];
        _groupShoutOutAuthorized = NO;
        _isFirstFbLogin = NO;
        _suggestedHideBtnFlags= [[NSMutableArray alloc] init];
        _myName = nil;
        _pushMessage = nil;
        NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
        
        _themeInfo = [allThemesInfo objectForKey:@"theme1"];
        
        _defaults = [NSUserDefaults standardUserDefaults];
        
    }
    return self;
}

+(void)sendPushNotification:(NSString*)receiverID withMessage:(NSString*)message andAudio:(NSString*)selectedAudio{

    NSString* addNotification = @"NO";
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo:receiverID];
    if([selectedAudio length]<1)
    {
        selectedAudio = @"push.aac";
    }
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
   // BOOL messageSaved = NO;
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          @"Increment", @"badge", addNotification, @"isAddNotification",selectedAudio, @"sound",
                          nil];
    
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(!error)
         {
             PFQuery * query1 = [PFQuery queryWithClassName:@"Messages"];
             [query1 whereKey:@"sender" equalTo:[PFUser currentUser].objectId];
             PFQuery * query2 = [PFQuery queryWithClassName:@"Messages"];
             [query2 whereKey:@"receiver" containedIn:DataManager.sharedInstance.retrievedFriends];
             PFQuery * mainQuery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
             [mainQuery whereKey:@"receiver" equalTo:receiverID];
             [mainQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error)
             {
                 if(!error)
                 {
                     
                     if([objects count]>0)
                     {
                         PFObject * object = [objects objectAtIndex:0];
                        // PFObject *messageObject = [DataManager.sharedInstance.themeAudios objectAtIndex:DataManager.sharedInstance.selectedAudioIndex];
                         //messageObject[@""]
                         NSArray *audioMessages = [[NSArray alloc] initWithArray: [[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
                         for(int i = 0 ; i < [audioMessages count];i++)
                         {
                            NSString *title = [audioMessages objectAtIndex:i];
                             NSString *title2 = [audioMessages objectAtIndex:[DataManager sharedInstance].selectedAudioIndex] ;
                             NSLog(@"%@ = %@", title,title2);
                            if([title2 isEqualToString:title])
                            {
                                object[@"message"] = title2;
                                break;
                            }
                             
                         }
                         
                         [object saveInBackground];
                     }
                     else
                     {
                         PFObject * object = [PFObject objectWithClassName:@"Messages"];
                         object[@"sender"] = [PFUser currentUser].objectId;
                         object[@"receiver"] = receiverID;
                          NSArray *audioMessages = [[NSArray alloc] initWithArray: [[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
                         for(int i = 0 ; i < [audioMessages count];i++)
                         {
                            NSString *title = [audioMessages objectAtIndex:i];
                             NSString *title2 = [audioMessages objectAtIndex:[DataManager sharedInstance].selectedAudioIndex] ;
                             NSLog(@"%@ = %@", title,title2);
                             if([title2 isEqualToString:title])
                             {
                                 object[@"message"] = title2;
                                 break;
                             }
                             
                         }

                         [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error)
                          {
                              if(succeeded)
                              {
                                  
                              }
                              else
                              {
                                  NSLog(@"Error: %@", error);
                              }
                          }];
                     }
                     
                     
                 }
             }];
             
             NSString * alertString = @"Shout out Sent";
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             [errorAlertView show];
         }
    }];
        
    
    
}

+(void)sendAddRequestNotification: (NSString*)senderID totalRequests:(NSUInteger)totalRequests andReceiverID:(NSString *) receiverID
{
    NSString * addNotification = @"YES";
    NSString * msg = [NSString stringWithFormat:@"New add request from %@", senderID];
    NSString * refreshedCount = [NSString stringWithFormat:@"%i",(int)totalRequests];
    
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          msg, @"alert",
                          @"Increment", @"badge", refreshedCount,@"refreshedCount",addNotification,@"isAddNotification",@"push.aac",@"sound",nil];
    PFPush *push = [[PFPush alloc] init];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo:receiverID];
    [push setQuery:pushQuery];
    //[push setChannels:[NSArray arrayWithObjects:@"Mets", nil]];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(!error)
         {
             
         }
     }];
    
    


}


+(void) sendRequestAcceptedNotification:(NSString*)senderID andReceiverID:(NSString*)receiverID
{
    NSString * addNotification = @"accepted";
    NSString * msg = [NSString stringWithFormat:@"Friend request accepted by %@", senderID];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          msg, @"alert",
                          @"Increment", @"badge",addNotification,@"isAddNotification",@"push.aac", @"sound", nil];
    PFPush *push = [[PFPush alloc] init];
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userId" equalTo:receiverID];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(!error)
         {
             
         }
     }];
    
    
    
    
}

+(void)sendGroupPushNotification:(NSString*)message withAudio:(NSString*)selectedAudio
{
    NSString* addNotification = @"NO";
    NSArray *themeAudios = [[NSArray alloc]initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
    PFQuery *pushQuery = [PFInstallation query];
    NSLog(@"Selected Audio:%@", selectedAudio);
    NSUInteger count = [DataManager.sharedInstance.retrievedFriends count];
    NSString *audioTitle = [themeAudios objectAtIndex:[DataManager sharedInstance].selectedAudioIndex];
    for(int i = 0;i<count;i++)
    {
        [DataManager.sharedInstance.messages replaceObjectAtIndex:i withObject:[audioTitle uppercaseString]];
    }
    NSString * targetId;
    for(NSUInteger i = 0;i<count;i++)
    {
        targetId = [DataManager.sharedInstance.retrievedFriends objectAtIndex:i];
        [pushQuery whereKey:@"userId" equalTo:targetId];
        if([selectedAudio length]<1)
        {
            selectedAudio = @"push.aac";
        }
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, @"alert",
                              @"Increment", @"badge", addNotification, @"isAddNotification",selectedAudio, @"sound",
                              nil];
        
        //[push expireAfterTimeInterval:86400];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if(!error)
             {
                 PFQuery * query1 = [PFQuery queryWithClassName:@"Messages"];
                 [query1 whereKey:@"sender" equalTo:[PFUser currentUser].objectId];
                 PFQuery * query2 = [PFQuery queryWithClassName:@"Messages"];
                 [query2 whereKey:@"receiver" containedIn:DataManager.sharedInstance.retrievedFriends];
                 PFQuery * mainQuery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
                 [mainQuery whereKey:@"receiver" equalTo:targetId];
                 [mainQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error)
                  {
                      if(!error)
                      {
                          
                          if([objects count]>0)
                          {
                              PFObject * object = [objects objectAtIndex:0];
                               NSArray *audioMessages = [[NSArray alloc] initWithArray: [[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
                              for(int i = 0 ; i < [audioMessages count];i++)
                              {
                                  NSString *title = [audioMessages objectAtIndex:i];
                                  NSString *title2 = [audioMessages objectAtIndex:[DataManager sharedInstance].selectedAudioIndex] ;
                                  NSLog(@"%@ = %@", title,title2);
                                  if([title2 isEqualToString:title])
                                  {
                                      object[@"message"] = title2;
                                      break;
                                  }
                                  
                              }
                              [object saveInBackground];
                          }
                          else
                          {
                              PFObject * object = [PFObject objectWithClassName:@"Messages"];
                              object[@"sender"] = [PFUser currentUser].objectId;
                              object[@"receiver"] = targetId;
                               NSArray *audioMessages = [[NSArray alloc] initWithArray: [[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
                              for(int i = 0 ; i < [[DataManager sharedInstance].themeAudios count];i++)
                              {
                                  NSString *title = [audioMessages objectAtIndex:i];
                                  NSString *title2 = [audioMessages objectAtIndex:[DataManager sharedInstance].selectedAudioIndex] ;
                                  NSLog(@"%@ = %@", title,title2);
                                  if([title2 isEqualToString:title])
                                  {
                                      object[@"message"] = title2;
                                      break;
                                  }
                                  
                              }

                              [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error)
                               {
                                   if(succeeded)
                                   {
                                       
                                   }
                                   else
                                   {
                                       NSLog(@"Error: %@", error);
                                   }
                               }];
                          }
                          
                          
                      }
                  }];
                 
                 if(i==(count-1))
                 {
                     
                     NSString * alertString = @"Shout outs Sent";
                     [[DataManager sharedInstance].messages removeAllObjects];
                     for(int k = 0 ; k <[[DataManager sharedInstance].friendsEmailAdresses count];k++)
                     {
                         
                         NSString *title2 = [themeAudios objectAtIndex:[DataManager sharedInstance].selectedAudioIndex] ;
                         [[DataManager sharedInstance].messages addObject:title2];
                     }
                     UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                     [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_SHOUT_OUT_DONE object:nil];
                     [errorAlertView show];
                 }
                 
             }
         }];
        
    }
    
}


+(void) refreshLists
{
    PFUser * user = [PFUser currentUser];
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * social, NSError * error)
    {
        if(!error)
        {
            DataManager.sharedInstance.pendingFriendRequests = social[@"pendingRequests"];
            DataManager.sharedInstance.retrievedFriends = social[@"nativeFriendsIds"];
            DataManager.sharedInstance.blockedContacts = social[@"blockedContacts"];
            [self getRequestSendersProfile];
        }
    }];
}

+(void) getRequestSendersProfile
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
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        [DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
    }
}


@end
