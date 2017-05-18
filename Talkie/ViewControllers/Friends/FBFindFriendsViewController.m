//
//  ManageFriendsViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 06/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FBFindFriendsViewController.h"


@interface FBFindFriendsViewController ()

@end

@implementation FBFindFriendsViewController
@synthesize selectedSegment;
@synthesize tableViewFriendsList;
@synthesize friendsSearchBar;
@synthesize themeNumber;
- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    NSIndexPath *selectedRowIndexPath = [self.tableViewFriendsList indexPathForSelectedRow];
    [super viewWillAppear:animated]; // clears selection
    if (selectedRowIndexPath)
    {
        [self.tableViewFriendsList reloadRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];
    
}
- (void)newFriendRequest:(NSNotification*)_ntf
{
    if(selectedSegment == 2)
    {
        DataManager.sharedInstance.requestBadge = 0;
        [reqSenderEmails removeAllObjects];
        [reqSenderNames removeAllObjects];
        [reqSenderProfilePictures removeAllObjects];
        [self getPendingRequests];
        
        
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        [DataManager.sharedInstance.selectedContacts removeAllObjects];
        [self.tableViewFriendsList reloadData];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_FRIEND_REQUEST_NOTIFICATION
                                                  object:nil];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableViewFriendsList.dataSource = self;
    self.tableViewFriendsList.delegate = self;
    self.tableViewFriendsList.backgroundView = nil;
    self.friendsSearchBar.delegate = self;
    CGRect frame= self.friendsSections.frame;
    [self.friendsSections setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,  44 )];
    [self.tableViewFriendsList setBackgroundColor:[UIColor clearColor]];
    reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
    reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
    reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
    pendingRequests = [NSMutableArray arrayWithArray:DataManager.sharedInstance.pendingFriendRequests];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.friendsSearchBar.placeholder = @"SEARCH USERNAME/EMAIL";

    foundUserEmail = [[NSMutableArray alloc] init];
    foundUserProfilePicture = [[NSMutableArray alloc] init];
    foundUsername = [[NSMutableArray alloc] init];
    foundUsers = [[NSMutableArray alloc] init];
    hideBtnFlags = [[NSMutableArray alloc] init];
   
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self setUpTheme];

}

-(void) dismissKeyboard
{
    [self.friendsSearchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rows = 0;
    if(selectedSegment==0)
    {
        rows = [DataManager.sharedInstance.suggestedFbFriends count];
    }
    else if(selectedSegment == 1)
    {
        rows = [foundUsername count];
    }
    else if(selectedSegment ==2)
    {
       
        rows =  [DataManager.sharedInstance.reqSenderEmails count];
    }
    return rows;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
   
    FriendListTableViewCell *cell = [self.tableViewFriendsList dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSString *titleString = [self generateTitleString:FBF_BTN_ADDED];
    if (cell == nil) {
        
        NSArray *cellView = [[NSBundle mainBundle] loadNibNamed:@"FriendListTableViewCell" owner:nil options:nil];
        cell = (FriendListTableViewCell *)[cellView objectAtIndex:0];
        cell.backgroundView = nil;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        [cell.btnAddOrInivte addTarget:self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnAddOrInivte.tag = indexPath.row;
        
        if([hideBtnFlags count]>0)
        {
            if(selectedSegment == 0|| selectedSegment == 1)
            {
                if([hideBtnFlags count]>indexPath.row)
                {
                    if([[hideBtnFlags objectAtIndex:indexPath.row] isEqualToString:@"1"])
                    {
                        cell.btnAddOrInivte.enabled = NO;
                        [cell.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                    }
                    else if ([[hideBtnFlags objectAtIndex:indexPath.row] isEqualToString:@"2"])
                    {
                        cell.btnAddOrInivte.enabled = NO;
                        titleString = [self generateTitleString:FBF_BTN_PENDING];
                        [cell.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                    }
                    
                    else if ([[hideBtnFlags objectAtIndex:indexPath.row] isEqualToString:@"4"])
                    {
                        cell.btnAddOrInivte.enabled = NO;
                        titleString = [self generateTitleString:FBF_BTN_PENDING];
                        [cell.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                    }
                    
                    else
                    {
                        cell.btnAddOrInivte.enabled = YES;
                        titleString = [self generateTitleString:FBF_BTN_ADD];
                        [cell.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                    }
                }

            }
        }
    }
    if (selectedSegment == 0)
        {
            cell.actionDeterminationFlag = 2;
            if([DataManager.sharedInstance.suggestedFbFriends count]>0)
            {
                NSString * capitalString  = [[DataManager.sharedInstance.suggestedFriendsUsernames objectAtIndex:indexPath.row] uppercaseString];
                //cell.nameLabel.text = capitalString;
                //cell.thumbnailImageView.image = [DataManager.sharedInstance.suggestedFriendsProfilePics objectAtIndex:indexPath.row];
                //cell.emailLbl.text = [DataManager.sharedInstance.suggestedFriendsEmails objectAtIndex:indexPath.row];
                
                [cell populateDataSuggestions:capitalString withEmail:[DataManager.sharedInstance.suggestedFriendsEmails objectAtIndex:indexPath.row] andIndexPath:indexPath.row andArray:[DataManager sharedInstance].suggestedFbFriends andTargetArray:DataManager.sharedInstance.suggestedFriendsProfilePics];
            }
        }
        
        else if(selectedSegment == 1 )
        {
            cell.actionDeterminationFlag = 2;
           
            if([foundUserEmail count]>0)
            {
                NSString * capitalString  = [[foundUsername objectAtIndex:indexPath.row] uppercaseString];
                //cell.nameLabel.text = capitalString;
                //cell.thumbnailImageView.image = [foundUserProfilePicture objectAtIndex:indexPath.row];
                //cell.emailLbl.text = [foundUserEmail objectAtIndex:indexPath.row];
                
                [cell populateDataSuggestions:capitalString withEmail:[foundUserEmail objectAtIndex:indexPath.row] andIndexPath:indexPath.row andArray:searchedUserIds andTargetArray:foundUserProfilePicture];
            }
            
        }
        
        else if(selectedSegment ==2)
        {
            
            
            if([reqSenderEmails count]>0)
            {
                cell.actionDeterminationFlag = 3;
                titleString = [self generateTitleString:FBF_BTN_ACCEPT];
                UIImage *btnIcon = [UIImage imageNamed:titleString];
                [cell.btnAddOrInivte setBackgroundImage:btnIcon forState:UIControlStateNormal];
                NSString * capitalString  = [[reqSenderNames objectAtIndex:indexPath.row] uppercaseString];
               // cell.nameLabel.text = capitalString;
                //cell.emailLbl.text = [reqSenderEmails objectAtIndex:indexPath.row];
                
                //cell.thumbnailImageView.image = [reqSenderProfilePictures objectAtIndex:indexPath.row];
                pendingRequests = [[NSMutableArray alloc] initWithArray:[DataManager sharedInstance].pendingFriendRequests];
                [cell populateDataSuggestions:capitalString withEmail:[reqSenderEmails objectAtIndex:indexPath.row] andIndexPath:indexPath.row andArray:pendingRequests andTargetArray:reqSenderProfilePictures];
            }
        }

    
    
    return cell;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 66;
}

-(IBAction)segmentedControlTapped:(UISegmentedControl *)sender
{
    switch (self.friendsSections.selectedSegmentIndex)
    {
        case 0:
            
            selectedSegment=0;
            self.friendsSearchBar.text = @"";
            break;
        case 1:
            
            selectedSegment=1;
            self.friendsSearchBar.text = @"";
            break;
        case 2:
            
            selectedSegment=2;
            self.friendsSearchBar.text = @"";
            break;
        default:
            break;
    }
    [self switchTables];
    

}


-(void) switchTables
{
    NSString *titleString = [self generateTitleString:FBF_SEGMENT0_UNSELECTED];
    UIImage *segImage0 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage0 forSegmentAtIndex:0];
    
    titleString = [self generateTitleString:FBF_SEGMENT1_UNSELECTED];
    UIImage *segImage1 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage1 forSegmentAtIndex:1];
    
    titleString = [self generateTitleString:FBF_SEGMENT2_UNSELECTED];
    UIImage *segImage2 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage2 forSegmentAtIndex:2];
    
    titleString = [self generateTitleString:FBF_SEGMENT0_SELECTED];
    UIImage *segImage0HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    titleString = [self generateTitleString:FBF_SEGMENT1_SELECTED];
    UIImage *segImage1HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    titleString = [self generateTitleString:FBF_SEGMENT2_SELECTED];
    UIImage *segImage2HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if(selectedSegment==0)
    {
        CGRect frame= self.tableViewFriendsList.frame;
        [self.tableViewFriendsList setFrame:CGRectMake(0, 177, frame.size.width,  frame.size.height )];
        [self.friendsSections setImage:segImage0HoverState forSegmentAtIndex:0];
        [self.friendsSections setImage:segImage1 forSegmentAtIndex:1];
        [self.friendsSections setImage:segImage2 forSegmentAtIndex:2];
        self.friendsSearchBar.hidden = NO;
        self.seperatorLine.hidden = NO;
        [foundUsername removeAllObjects];
        [foundUserProfilePicture removeAllObjects];
        [foundUserEmail removeAllObjects];
        DataManager.sharedInstance.foundUsers = [[NSMutableArray alloc] init];
        hideBtnFlags = DataManager.sharedInstance.suggestedHideBtnFlags;
        [self.tableViewFriendsList reloadData];
    }
    
    else if (selectedSegment==1)
    {
        CGRect frame= self.tableViewFriendsList.frame;
        [self.tableViewFriendsList setFrame:CGRectMake(0, 177, frame.size.width,  frame.size.height )];
        [self.friendsSections setImage:segImage1HoverState forSegmentAtIndex:1];
        [self.friendsSections setImage:segImage0 forSegmentAtIndex:0];
        [self.friendsSections setImage:segImage2 forSegmentAtIndex:2];
        self.friendsSearchBar.hidden = NO;
        self.seperatorLine.hidden = NO;
        [DataManager.sharedInstance.selectedContacts removeAllObjects];
        [self.tableViewFriendsList reloadData];
        
    }
    
    else if (selectedSegment==2)
    {
        CGRect frame= self.tableViewFriendsList.frame;
        [self.tableViewFriendsList setFrame:CGRectMake(0, 129, frame.size.width,  frame.size.height )];
        [self.friendsSections setImage:segImage2HoverState forSegmentAtIndex:2];
        [self.friendsSections setImage:segImage0 forSegmentAtIndex:0];
        [self.friendsSections setImage:segImage1 forSegmentAtIndex:1];
        self.friendsSearchBar.hidden = YES;
        self.seperatorLine.hidden = YES;
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        [foundUsername removeAllObjects];
        [foundUserProfilePicture removeAllObjects];
        [foundUserEmail removeAllObjects];
        DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
        [self getPendingRequests];
        [self.tableViewFriendsList reloadData];
    }
    
}



-(IBAction)backBtnTapped:(id)sender
{
    if(DataManager.sharedInstance.isFirstFbLogin == YES)
    {
        MainScreenViewController * frontViewController = [[MainScreenViewController alloc] init];
        RearViewController *rearViewController = [[RearViewController alloc] init];
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
        revealController.delegate = self;
        revealController.rearViewRevealWidth = 101;
        DataManager.sharedInstance.isFirstFbLogin = NO;
        
        [self.navigationController pushViewController:revealController animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    

}
- (void)reloadMyTable {
    [self.tableViewFriendsList reloadData];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(selectedSegment == 2)
        return YES;
    else
        return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * selectedContactId = [DataManager.sharedInstance.pendingFriendRequests objectAtIndex:indexPath.row];
    [self startAnimation];
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *username, NSError *error) {
            
            if(!error)
            {
                NSMutableArray *pendingRequestsOfCurrentUser = [[NSMutableArray alloc] initWithArray:username[@"pendingRequests"]];
                NSUInteger indexOfObject = [pendingRequestsOfCurrentUser indexOfObject:selectedContactId];
                [pendingRequestsOfCurrentUser removeObject:selectedContactId];
                NSArray * updatedRequests = pendingRequestsOfCurrentUser;
                username[@"pendingRequests"] = updatedRequests;
                DataManager.sharedInstance.pendingFriendRequests = [[NSMutableArray alloc] initWithArray: updatedRequests];
                pendingRequests = DataManager.sharedInstance.pendingFriendRequests;
                [DataManager.sharedInstance.reqSenderEmails removeObjectAtIndex:indexOfObject];
                [DataManager.sharedInstance.reqSenderProfilePictures removeObjectAtIndex:indexOfObject];
                [DataManager.sharedInstance.reqSenderNames removeObjectAtIndex:indexOfObject];
                updatedRequests = DataManager.sharedInstance.reqSenderEmails;
                reqSenderEmails = [[NSMutableArray alloc] initWithArray:updatedRequests];
                updatedRequests = DataManager.sharedInstance.reqSenderNames;
                reqSenderNames = [[NSMutableArray alloc] initWithArray:updatedRequests];
                updatedRequests = DataManager.sharedInstance.reqSenderProfilePictures;
                reqSenderProfilePictures = [[NSMutableArray alloc] initWithArray:updatedRequests];
                [username saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
                    if(!error)
                    {
                        
                        [self stopAnimation];
                        NSString *successString = @"Friend request removed";
                        
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:successString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                        [self getFriendsUsernames];
                        [self.tableViewFriendsList reloadData];
                        
                    }
                    else
                    {
                        [self stopAnimation];
                        NSString *errorString = @"Request could not be removed";
                        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Failed" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [errorAlertView show];
                    }
                }];
                [username refresh];
            }
            else{
                //error
            }
        }];

       

        
    }
}
-(void) getFriendsUsernames
{
    NSMutableArray * objectIDs = [[NSMutableArray alloc] initWithArray: DataManager.sharedInstance.retrievedFriends];
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    //UIImage *profilePictureData;
    [reqSenderProfilePictures removeAllObjects];
    [reqSenderEmails removeAllObjects];
    [reqSenderNames removeAllObjects];
    [DataManager.sharedInstance.friendsEmailAdresses removeAllObjects];
     [DataManager.sharedInstance.friendsUsernames removeAllObjects];
    [DataManager.sharedInstance.friendsProfilePictures removeAllObjects];
    NSUInteger friendsCount = [objectIDs count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:objectIDs[i]];
        [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
        [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
        
        imageFile = [username objectForKey:@"profilePicture"];
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        [DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
    }
    [self getPendingRequests];
    
    
}

-(void) getPendingRequests
{
    [self startAnimation];
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    //PFObject * object = [query getFirstObject];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
     {
         if(!error)
         {
             DataManager.sharedInstance.pendingFriendRequests= object[@"pendingRequests"];
             [self getRequestSendersProfile];
             
         }
     }];
    
}

-(void) getRequestSendersProfile
{
    NSMutableArray * objectIDs = [[NSMutableArray alloc] initWithArray: DataManager.sharedInstance.pendingFriendRequests];
    PFQuery *query = [PFUser query];
    
    [DataManager.sharedInstance.reqSenderNames removeAllObjects];
    [DataManager.sharedInstance.reqSenderEmails removeAllObjects];
    [DataManager.sharedInstance.reqSenderProfilePictures removeAllObjects];
    NSUInteger requestsCount = [objectIDs count];
    for(int i = 0; i<requestsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:objectIDs[i]];
        [DataManager.sharedInstance.reqSenderNames addObject:username[@"username"]];
        [DataManager.sharedInstance.reqSenderEmails addObject:username[@"email"]];
        //imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageNamed:@"dummyImage"];
        [DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        
    }
    [self.tableViewFriendsList reloadData];
    [self getMessages];
}


-(void) searchBtnTapped
{
    if(selectedSegment == 1)
    {
    hideBtnFlags = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
    if(self.friendsSearchBar.text.length<3)
    {
        NSString * errorString = @"Enter at last three characters to search";
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
    else if(self.friendsSearchBar.text.length>2)
    {
        [self startAnimation];
        
        [foundUsername removeAllObjects];
        [foundUserProfilePicture removeAllObjects];
        [foundUserEmail removeAllObjects];
        NSString * usernameToBeSearched = [self.friendsSearchBar.text lowercaseString];
        
        PFQuery * query2 = [PFUser query];
        PFQuery * query1 = [PFUser query];
        [query2 whereKey:@"email" containsString:usernameToBeSearched];
        [query1 whereKey:@"username" containsString:usernameToBeSearched];
        PFQuery * mainQuery = [PFQuery orQueryWithSubqueries:@[query1,query2]];
        //DataManager.sharedInstance.foundUsers = [mainQuery findObjects];
        
        [mainQuery findObjectsInBackgroundWithBlock:^(NSArray * foundUsers1, NSError * error)
         {
             PFUser * user = [PFUser currentUser];
             if(!error)
             {
                 DataManager.sharedInstance.foundUsers = foundUsers1;
                 NSArray * targetsRequests = [[NSArray alloc] init];
                 PFQuery * query = [PFQuery queryWithClassName:@"Social"];
                 PFObject * targetUser;
                 NSMutableArray *objectos = [[NSMutableArray alloc] init];
                 if([DataManager.sharedInstance.foundUsers count]>0)
                 {
                    for(PFUser * foundUser in DataManager.sharedInstance.foundUsers)
                     {
                         user = foundUser;
                         [query whereKey:@"user" equalTo:foundUser];
                         user = foundUser;
                         targetUser=[query getFirstObject];
                         targetsRequests = targetUser[@"pendingRequests"];
                         if(![DataManager.sharedInstance.blockedContacts containsObject:user.objectId] && ![targetUser[@"blockedContacts"] containsObject:[PFUser currentUser].objectId])
                         {
                             if (![user.objectId  isEqualToString:[PFUser currentUser].objectId])
                             {
                                 [foundUsername addObject:user[@"username"]];
                                 [foundUserEmail addObject:user[@"email"]];
                                 [objectos addObject:user.objectId];
                                 //resultProfilePictureData = [user objectForKey:@"profilePicture"];
                                 //NSData *imageData = [resultProfilePictureData getData];
                                 //UIImage * resultProfilePic = [UIImage imageWithData:imageData];
                                 UIImage *resultProfilePic = [UIImage imageNamed:@"dummyImage.png"];
                                 
                                 //For hiding add button
                                 if(resultProfilePic!=nil)
                                 {
                                     [foundUserProfilePicture addObject:resultProfilePic];
                                 }
                                 else if(resultProfilePic==nil)
                                 {
                                     [foundUserProfilePicture addObject:[UIImage imageNamed:@"dummyImage.png"]];
                                 }
                                 if([DataManager.sharedInstance.retrievedFriends containsObject:user.objectId])
                                 {
                                     //Friend exists
                                     [hideBtnFlags addObject:@"1"];
                                 }
                                 
                                 if([DataManager.sharedInstance.pendingFriendRequests containsObject:user.objectId])
                                 {
                                     //request is pending
                                     [hideBtnFlags addObject:@"2"];
                                 }
                                 
                                 if(![DataManager.sharedInstance.retrievedFriends containsObject:user.objectId] && ![DataManager.sharedInstance.pendingFriendRequests containsObject:user.objectId] && ![user.objectId isEqualToString:[PFUser currentUser].objectId]  && ![targetsRequests containsObject:[PFUser currentUser].objectId])
                                 {
                                     //user is okay
                                     [hideBtnFlags addObject:@"0"];
                                 }
                                 if ([targetsRequests containsObject:[PFUser currentUser].objectId])
                                 {
                                     //user's already recieved a friend request
                                     [hideBtnFlags addObject:@"4"];
                                 }
                             }
                         }
                     }
                     NSLog(@"%@", hideBtnFlags);
                     DataManager.sharedInstance.foundUsers = foundUsers1;
                     [self stopAnimation];
                     searchedUserIds = [[NSArray alloc] initWithArray:objectos];
                     [self.tableViewFriendsList reloadData];
                 }
                 else if([DataManager.sharedInstance.foundUsers count]<1)
                 {
                     [self stopAnimation];
                     NSString * errorString = @"No Matches found";
                     UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                     [errorAlertView show];
                     
                 }
                 
             }
             
         }];
    }
    }

    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self searchBtnTapped];
    return YES;
}


-(void) refreshLists
{
    PFUser * user = [PFUser currentUser];
    // PFObject * social = [PFObject objectWithClassName:@"Social"];
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

-(void) btnAddClicked:(UIButton *) sender
{
    
    [self startAnimation];
    NSString * lowerString;
    sender.enabled = NO;
    if(selectedSegment==0)
    {
        lowerString = [[DataManager.sharedInstance.suggestedFriendsEmails objectAtIndex:sender.tag] lowercaseString];
    }
    else if(selectedSegment == 1)
    {
        lowerString = [[foundUserEmail objectAtIndex:sender.tag] lowercaseString];
    }
    else if(selectedSegment == 2)
    {
        lowerString = [[reqSenderEmails objectAtIndex:sender.tag] lowercaseString];
    }
    
    
    NSString * selectedContact= lowerString;
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:selectedContact];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers1, NSError * error){
        NSString * objectIDD;
        PFUser * contact = [PFUser user];
        if([foundUsers1 count]  == 1)
        {
            for (PFUser *foundUser in foundUsers1)
            {
                objectIDD = foundUser.objectId;
                contact = foundUser;
                NSLog(@"Contact: %@", contact);
            }
        }
        if(selectedSegment == 0 || selectedSegment == 1)
        {
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
                         sender.enabled = NO;
                         NSString * errorString;
                         if([targetsId isEqualToString:[PFUser currentUser].objectId])
                         {
                             errorString = @"Can't add your own ID";
                         }
                         else if(pendingRequestCheck ==YES)
                         {
                             errorString = @"Pending request exists. Please see your pending requests";
                             if([[DataManager sharedInstance].suggestedHideBtnFlags count]>0)
                             {
                                 [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                             if([hideBtnFlags count]>0)
                             {
                                  [hideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                            
                         }
                         else if(friendListCheck == YES)
                         {
                             errorString = @"User's already exists in Friend List";
                             if([hideBtnFlags count]>0)
                             {
                                 [hideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"1"];
                             }
                             if([[DataManager sharedInstance].suggestedHideBtnFlags count]>0)
                             {
                                  [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"1"];
                             }
                            
                         }
                         else if(sentRequestCheck)
                         {
                             errorString = @"You have already sent a request to this user";
                             if([hideBtnFlags count]>0)
                             {
                                 [hideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                             if([[DataManager sharedInstance].suggestedHideBtnFlags count]>0)
                             {
                                 [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                             
                         }
                         [self stopAnimation];
                         UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                         [errorAlertView show];
                         [self.tableViewFriendsList reloadData];
                         
                     }
                     
                     else if(![targetsId isEqualToString:[PFUser currentUser].objectId]&&pendingRequestCheck ==NO && friendListCheck == NO &&sentRequestCheck ==NO)
                     {
                         NSArray * targetsBlockedContacts = [[NSArray alloc] initWithArray:username[@"blockedContacts"]];
                         BOOL currentUserBlocked = [targetsBlockedContacts containsObject: [PFUser currentUser].objectId];
                         NSArray * myBlockedContacts = [[NSArray alloc] initWithArray:DataManager.sharedInstance.blockedContacts];
                         BOOL targetsStatus = [myBlockedContacts containsObject:targetsId];
                         if(currentUserBlocked ==YES)
                         {
                             [self stopAnimation];
                             NSString * errorString = @"User has blocked you";
                             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                             
                             [errorAlertView show];
                         }
                         else if(targetsStatus ==YES)
                         {
                             [self stopAnimation];
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
                             
                             sender.enabled = NO;
                             NSString * senderName =  [PFUser currentUser].username;
                             NSLog(@"%@", senderName);
                             [DataManager sendAddRequestNotification:senderName totalRequests:[pendingRequestsOfTargetUser count] andReceiverID:targetsId];
                             
                             [self stopAnimation];
                             if([hideBtnFlags count]>0)
                             {
                                 [hideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                             
                             if(selectedSegment==0 && [[DataManager sharedInstance].suggestedHideBtnFlags count]>0)
                             {
                                 [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             }
                             [self.tableViewFriendsList reloadData];
                             NSString *titleString = [self generateTitleString:FBF_BTN_PENDING];
                             [sender setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                             
                             sender.enabled = NO;
                             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                             [errorAlertView show];
                         }
                         
                         
                     }
                 }
                 
             }];
            
            
        }
        else if(selectedSegment == 2)
        {
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
                         
                         [DataManager.sharedInstance.reqSenderNames removeObjectAtIndex:sender.tag];
                         [DataManager.sharedInstance.reqSenderProfilePictures removeObjectAtIndex:sender.tag];
                         [DataManager.sharedInstance.reqSenderEmails removeObjectAtIndex:sender.tag];
                         username[@"nativeFriendsIds"] = updatedFriends;
                         reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
                         reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
                         reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
                         
                         [username saveInBackground];
                         NSLog(@"DONE");
                         //TO FIX CRASH
                         [[DataManager sharedInstance].messages addObject:@""];
                         
                         [self stopAnimation];
                         [self getFriendsUsernames];
                         requestAccepted = YES;
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
                                     [DataManager sendRequestAcceptedNotification:[PFUser currentUser].username andReceiverID:objectIDD];
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

-(void) getMessages
{
    PFQuery * query1 = [PFQuery queryWithClassName:@"Messages"];
    [DataManager.sharedInstance.messages removeAllObjects];
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
             
             
         }
         if(requestAccepted == YES)
         {
             [self.tableViewFriendsList reloadData];
             NSString * errorString = @"Friend Request Accepted";
             UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             [errorAlertView show];
             requestAccepted = NO;
             
         }
         [self stopAnimation];
     }];
}
-(void) setUpTheme
{
    themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    NSString *themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    
    if(themeNumber==nil)
    {
        themeId = @"theme1";
    }
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    
    _navigationBar.image = [UIImage imageNamed:[self generateTitleString:BG_TOP_BAR_GROUP]];
    [_btnBack setImage:[UIImage imageNamed:[self generateTitleString:BTN_BACK]] forState:UIControlStateNormal];
    
    NSString *seg0 = [self generateTitleString:FBF_SEGMENT0_SELECTED];
    
    //selectedSegment = 0;
    
    
    if(selectedSegment == 0)
    {
        [self.friendsSections setSelectedSegmentIndex:0];
        
        UIImage *segImage0 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.friendsSections setImage:segImage0 forSegmentAtIndex:0];
        
        seg0 = [self generateTitleString:FBF_SEGMENT1_UNSELECTED];
        UIImage *segImage1 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.friendsSections setImage:segImage1 forSegmentAtIndex:1];
        seg0 = [self generateTitleString:FBF_SEGMENT2_UNSELECTED];
        UIImage *segImage2 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.friendsSections setImage:segImage2 forSegmentAtIndex:2];
        //hideBtnFlags = sharedClass.sharedInstance.suggestedHideBtnFlags;
        NSLog(@"Suggested hide btn Flags: %@ & size: %lu",DataManager.sharedInstance.suggestedHideBtnFlags, (unsigned long)[DataManager.sharedInstance.suggestedHideBtnFlags count]);
        hideBtnFlags = [NSMutableArray arrayWithArray:DataManager.sharedInstance.suggestedHideBtnFlags];
        NSLog(@"Hide button flags now: %@", hideBtnFlags);
    }
    else if(selectedSegment == 2)
    {
        seg0 = [self generateTitleString:FBF_SEGMENT0_UNSELECTED];
        UIImage *segImage0 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.friendsSections setImage:segImage0 forSegmentAtIndex:0];
        
        seg0 = [self generateTitleString:FBF_SEGMENT1_UNSELECTED];
        UIImage *segImage1 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.friendsSections setImage:segImage1 forSegmentAtIndex:1];
        
        seg0 = [self generateTitleString:FBF_SEGMENT2_SELECTED];
        UIImage *segImage2 = [[UIImage imageNamed:seg0] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [self.friendsSections setImage:segImage2 forSegmentAtIndex:2];
        [self.friendsSections setSelectedSegmentIndex:2];
        [self segmentedControlTapped:nil];
    }
    
}

-(NSString *) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return  titleString;
}
@end
