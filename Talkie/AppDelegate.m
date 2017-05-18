//
//  AppDelegate.m
//  Talkie
//
//  Created by sajjad mahmood on 29/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashScreenViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize navController;
@synthesize window = _window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse setApplicationId:PARSE_APPLICATION_ID
                  clientKey:PARSE_CUSTOMER_KEY];
    [PFFacebookUtils initializeFacebook];
    didSendNotificationAlready = NO;
    [self.window makeKeyAndVisible];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    if([PFUser currentUser]!=nil)
    {
       
        SplashScreenViewController *splash = [[SplashScreenViewController alloc] initWithNibName:@"SplashScreenViewController" bundle:nil];
        UINavigationController *newnav = [[UINavigationController alloc] initWithRootViewController:splash];
        [_window setRootViewController:newnav];
        
        // set the navController property:
        [self setNavController:newnav];
        //[self handleBackgroundPush:launchOptions];
        return YES;

    }
    LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    // create the Navigation Controller instance:
    UINavigationController *newnav = [[UINavigationController alloc] initWithRootViewController:controller];
    [_window setRootViewController:newnav];
    // set the navController property:
    [self setNavController:newnav];
    
    
    [self handleBackgroundPush:launchOptions];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    [self refreshLists];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}


-(void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    PFACL *objectACL = [[PFACL alloc] init];
    [objectACL setPublicReadAccess:YES];
    [objectACL setPublicWriteAccess:YES];
    
    [currentInstallation saveInBackground];
}

-(void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
    NSString *errorString = error.localizedDescription;
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [errorAlertView show];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //Instabilities expected due to change in parameters of single push function
    
    //
    [PFPush handlePush:userInfo];
    //27
    NSString * isAddNotification = [userInfo objectForKey:@"isAddNotification"];
    
    if([isAddNotification isEqualToString:@"YES"])
    {
        
        [DataManager sharedInstance].requestBadge++;
        [DataManager sharedInstance].addRequestReceived = YES;
        application.applicationIconBadgeNumber = 0;
        [self editPendingRequests];
        if(!didSendNotificationAlready)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FRIEND_REQUEST_NOTIFICATION object:nil];
        }
        
    }
    else if([isAddNotification isEqualToString:@"accepted"])
    {
        NSDictionary * aps = [[NSDictionary alloc] init];
        aps = [userInfo objectForKey:@"aps"];
        NSString * name = [aps objectForKey:@"alert"];
        NSArray *array = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
        name = [array objectAtIndex:[array count]-1];
        [DataManager sharedInstance].pushMessage = name;
        if([DataManager sharedInstance].isFbUser)
        {
            
            //name = [name substringFromIndex:27];
            
            if([[DataManager sharedInstance].suggestedFriendsUsernames containsObject:name])
            {
                for(int i = 0;i<[[DataManager sharedInstance].suggestedFriendsUsernames count];i++)
                {
                    if([[DataManager sharedInstance].suggestedFriendsUsernames[i] isEqualToString:name])
                    {
                        [[DataManager sharedInstance].suggestedHideBtnFlags replaceObjectAtIndex:i withObject:@"1"];
                        break;
                    }
                }
            }
        }
        
        [self getFriendList];
        [[NSNotificationCenter defaultCenter] postNotificationName:SET_READY_FOR_RELOAD object:nil];
    }
    
    
}
-(void)callbackWithResult:(NSData *)result error:(NSError *)error
{
    if (!error)
    {
        UIImage * profilePictureData = [UIImage imageWithData:result];
        [[DataManager sharedInstance].friendsProfilePictures addObject:profilePictureData];
    }
}
-(void) editPendingRequests
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [[DataManager sharedInstance].pendingFriendRequests removeAllObjects];
    PFObject * newReqs = [query getFirstObject];
    [DataManager sharedInstance].pendingFriendRequests = [NSMutableArray arrayWithArray:newReqs[@"pendingRequests"]];
    
}


- (void) getFriendList
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:[DataManager sharedInstance].pushMessage];
    NSLog(@"%@",[DataManager sharedInstance].pushMessage);
    PFObject *userObject = [query getFirstObject];
    NSLog(@"%@",userObject);
    [[DataManager sharedInstance].retrievedFriends addObject:userObject.objectId];
    [[DataManager sharedInstance].friendsEmailAdresses addObject:userObject[@"email"]];
    [[DataManager sharedInstance].friendsUsernames addObject:userObject[@"username"]];
    [[DataManager sharedInstance].friendsProfilePictures addObject:[UIImage imageNamed:@"dummyImage"]];
    [self getMessages];
    
}
-(void) getBlockedContactsProfile
{
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger friendsCount = [[DataManager sharedInstance].blockedContacts count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.blockedContacts[i]];
        [[DataManager sharedInstance].blockedNames addObject:username[@"username"]];
        [[DataManager sharedInstance].blockedEmails addObject:username[@"email"]];
        imageFile = [username objectForKey:@"profilePicture"];
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        [[DataManager sharedInstance].blockedPictures addObject:imageFromData];
        
    }
    
}

-(void) getFriendsUsernames
{
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger friendsCount = [[DataManager sharedInstance].retrievedFriends count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.retrievedFriends[i]];
        [[DataManager sharedInstance].friendsUsernames addObject:username[@"username"]];
        [[DataManager sharedInstance].friendsEmailAdresses addObject:username[@"email"]];
        imageFile = [username objectForKey:@"profilePicture"];
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        [[DataManager sharedInstance].friendsProfilePictures addObject:imageFromData];
        
    }
    
    
}

-(void) getPendingRequests
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    PFObject * object = [query getFirstObject];
    [DataManager sharedInstance].pendingFriendRequests= object[@"pendingRequests"];
    
}

-(void) getRequestSendersProfile
{ PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger requestsCount = [[DataManager sharedInstance].pendingFriendRequests count];
    for(int i = 0; i<requestsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.pendingFriendRequests[i]];
        [[DataManager sharedInstance].reqSenderNames addObject:username[@"username"]];
        [[DataManager sharedInstance].reqSenderEmails addObject:username[@"email"]];
        
        imageFile = [username objectForKey:@"profilePicture"];
        if(imageFile!=nil)
        {
            NSData *imageData = [imageFile getData];
            UIImage *imageFromData = [UIImage imageWithData:imageData];
            [[DataManager sharedInstance].reqSenderProfilePictures addObject:imageFromData];
        }
        else {[[DataManager sharedInstance].reqSenderProfilePictures addObject:[UIImage imageNamed:@"dummyImage.png"]];}
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
                             [[DataManager sharedInstance].messages addObject:audioId];
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
                /* DataManager.sharedInstance.isFirstFbLogin = YES;
                 FBFindFriendsViewController * fbVC = [[FBFindFriendsViewController alloc] init];
                 fbVC.selectedSegment = 0;
                 PFUser * user = [PFUser currentUser];
                 NSString * themeId = user[@"themeId"];
                 fbVC.themeNumber = themeId;
                 [[DataManager sharedInstance].defaults setValue:themeId forKey:@"themeId"];
                 [self.navigationController pushViewController:fbVC animated:YES];*/
                
                 
             }
             else
             {
                /* MainScreenViewController * frontViewController = [[MainScreenViewController alloc] init];
                 RearViewController *rearViewController = [[RearViewController alloc] init];
                 
                 SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
                 //revealController.delegate = self;
                 revealController.rearViewRevealWidth = 101;
              
                 
                 [self.navigationController pushViewController:revealController animated:YES];*/
             }
             
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_REQUEST_ACCEPTED_NOTIFICATION object:nil];
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
             [[DataManager sharedInstance].themeSpecs addObject:object[@"mainBackground"]];
             [[DataManager sharedInstance].themeSpecs addObject:object[@"shoutOutBackground"]];
             
             PFQuery * query = [PFQuery queryWithClassName:@"Audio"];
             [query whereKey:@"theme" equalTo:object];
             [DataManager sharedInstance].themeAudios = [NSMutableArray arrayWithArray:[query findObjects]];
             
         }
     }];
}

-(void) handleBackgroundPush: (NSDictionary *) launchOptions
{
     NSDictionary *remoteNotificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(remoteNotificationPayload)
    {
        if([PFUser currentUser])
        {
            NSString * isAddNotification = [remoteNotificationPayload objectForKey:@"isAddNotification"];
            if([isAddNotification isEqualToString:@"YES"])
            {
                
                [DataManager sharedInstance].requestBadge++;
                [DataManager sharedInstance].addRequestReceived = YES;
                
                [self editPendingRequests];
                [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FRIEND_REQUEST_NOTIFICATION object:nil];
            }
           /* else if([isAddNotification isEqualToString:@"accepted"])
            {
                NSDictionary * aps = [[NSDictionary alloc] init];
                aps = [remoteNotificationPayload objectForKey:@"aps"];
                NSString * name = [aps objectForKey:@"alert"];
                NSArray *array = [name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
                name = [array objectAtIndex:0];
                [DataManager sharedInstance].pushMessage = name;
                if([DataManager sharedInstance].isFbUser)
                {
                    
                    //name = [name substringFromIndex:27];
                    
                    if([[DataManager sharedInstance].suggestedFriendsUsernames containsObject:name])
                    {
                        for(int i = 0;i<[[DataManager sharedInstance].suggestedFriendsUsernames count];i++)
                        {
                            if([[DataManager sharedInstance].suggestedFriendsUsernames[i] isEqualToString:name])
                            {
                                [[DataManager sharedInstance].suggestedHideBtnFlags replaceObjectAtIndex:i withObject:@"1"];
                                break;
                            }
                        }
                    }
                }
                
                [self getFriendList];
                [[NSNotificationCenter defaultCenter] postNotificationName:SET_READY_FOR_RELOAD object:nil];
            }*/

        }
    }
}


-(void) refreshLists
{
    if([PFUser currentUser])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SET_READY_FOR_RELOAD object:nil];
        PFQuery *query = [PFQuery queryWithClassName:@"Social"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        PFObject *socialObj = [query getFirstObject];
        NSArray *retrievedFriends = [[NSArray alloc] initWithArray:[socialObj objectForKey:@"nativeFriendsIds"]];
        if([retrievedFriends count] > [[DataManager sharedInstance].retrievedFriends count])
        {
            for(int i = 0 ; i < [retrievedFriends count];i++)
            {
                if(![[DataManager sharedInstance].retrievedFriends containsObject:[retrievedFriends objectAtIndex:i]])
                {
                    query  = [PFUser query];
                    [query whereKey:@"objectId" equalTo:[retrievedFriends objectAtIndex:i]];
                    PFObject *usrObj = [query getFirstObject];
                    [[DataManager sharedInstance].friendsUsernames addObject:[usrObj objectForKey:@"username"]];
                    [[DataManager sharedInstance].friendsEmailAdresses addObject:[usrObj objectForKey:@"email"]];
                    [[DataManager sharedInstance].friendsProfilePictures addObject:[UIImage imageNamed:@"dummyImage"]];
                    [[DataManager sharedInstance].messages addObject:@" "];
                }
                if(i == [retrievedFriends count]-1)
                {
                    [DataManager sharedInstance].retrievedFriends = [[NSMutableArray alloc] initWithArray:retrievedFriends];
                    [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_REQUEST_ACCEPTED_NOTIFICATION object:nil];
                    
                }
            }
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_REQUEST_ACCEPTED_NOTIFICATION object:nil];
        }
        
        NSArray * reqsArray = [[NSArray alloc] initWithArray:socialObj[@"pendingRequests"]];
        if([reqsArray count]> [[DataManager sharedInstance].pendingFriendRequests count])
        {
            [DataManager sharedInstance].requestBadge = (int)[reqsArray count]-(int)[[DataManager sharedInstance].pendingFriendRequests count];
            NSLog(@"%li",(long) [DataManager sharedInstance].requestBadge);
            [DataManager sharedInstance].addRequestReceived = YES;
            
            [DataManager sharedInstance].pendingFriendRequests = [[NSMutableArray alloc] initWithArray:reqsArray];
            didSendNotificationAlready = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NEW_FRIEND_REQUEST_NOTIFICATION object:nil];
            didSendNotificationAlready = NO;
        }

    }
    
}

-(void) checkForPush
{
   
}
@end
