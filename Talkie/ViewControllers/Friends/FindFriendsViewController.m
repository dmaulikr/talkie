//
//  ManageFriendsForEmailLoginViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 24/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FindFriendsViewController.h"

@interface FindFriendsViewController ()

@end

@implementation FindFriendsViewController
@synthesize selectedSegment;
@synthesize tableViewFriendsList;
@synthesize friendsSearchBar;
- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    NSIndexPath *selectedRowIndexPath = [self.tableViewFriendsList indexPathForSelectedRow];
    [super viewWillAppear:animated]; // clears selection
    if (selectedRowIndexPath) {
        [self.tableViewFriendsList reloadRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];

    
}
- (void)newFriendRequest:(NSNotification*)_ntf
{
   if(selectedSegment == 1)
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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    NSString *titleString = [self generateTitleString:FIND_FRIENDS_SEG0_SELECTED];
    UIImage *segImage1HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage1HoverState forSegmentAtIndex:0];
    
    titleString = [self generateTitleString:FIND_FRIENDS_SEG1_UNSELECTED];
    UIImage *segImage2 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage2 forSegmentAtIndex:1];
    
    UIImage * dividerLine = [UIImage imageNamed:@"theme1_green_separatorline.png"];
    [self.friendsSections setDividerImage:dividerLine forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    frameDefault= self.tableViewFriendsList.frame;
    
    self.friendsSearchBar.returnKeyType = UIReturnKeySearch;
    self.tableViewFriendsList.dataSource = self;
    self.tableViewFriendsList.delegate = self;
    self.tableViewFriendsList.backgroundView = nil;
    self.friendsSearchBar.delegate = self;
    searchResultFriends = [[NSMutableArray alloc] init];
    searchResultEmails = [[NSMutableArray alloc] init];
    searchResultProfilePictures = [[NSMutableArray alloc] init];
    addedFriends = [[NSMutableArray alloc] init];
    CGRect frame= self.friendsSections.frame;
    [self.friendsSections setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width,  44 )];
    [self.tableViewFriendsList setBackgroundColor:[UIColor clearColor]];
    
    if(self.requestCount.text==nil)
    {
        self.requestCount.text = @"0";
    }
    if([self.requestCount.text isEqualToString:@"0"])
    {
        self.badgeBackground.hidden = YES;
        self.requestCount.hidden = YES;
    }

    [self updateData];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = YES;
    if(selectedSegment == 0)
    {
        [self.friendsSections setSelectedSegmentIndex:0];
    }
    else if(selectedSegment == 1)
    {
        [self.friendsSections setSelectedSegmentIndex:1];
        [self segmentControlTapped:nil];
    }
    [self setUpTheme];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(selectedSegment == 0)
    {
        if([DataManager.sharedInstance.foundUsers count]>0)
        {
            if([hideBtnFlags count] == 0)
            {
                for(int i = 0;i<[DataManager.sharedInstance.foundUsers count];i++)
                {
                    [hideBtnFlags addObject:@"0"];
                }
            }
            return [DataManager.sharedInstance.foundUsers count];
        }
        else
            return 0;
    }
    else if(selectedSegment ==1)
    {
        if([DataManager.sharedInstance.pendingFriendRequests count]>0)
        {
        return [DataManager.sharedInstance.reqSenderEmails count];
        }
        else
            return 0;
    }
    else
        return 0 ;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *titleString = [self generateTitleString:FIND_FRIENDS_SEG0_UNSELECTED];
    UIImage *segImage1 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage1 forSegmentAtIndex:0];
    
    titleString = [self generateTitleString:FIND_FRIENDS_SEG1_UNSELECTED];
    UIImage *segImage2 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage2 forSegmentAtIndex:1];
    
    titleString = [self generateTitleString:FIND_FRIENDS_SEG0_SELECTED];
    UIImage *segImage1HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    titleString = [self generateTitleString:FIND_FRIENDS_SEG1_SELECTED];
    UIImage *segImage2HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    FriendListTableViewCell *cell = [self.tableViewFriendsList dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        NSArray *cellView = [[NSBundle mainBundle] loadNibNamed:@"FriendListTableViewCell" owner:nil options:nil];
        cell = (FriendListTableViewCell *)[cellView objectAtIndex:0];
        cell.backgroundView = nil;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        cell.btnAddOrInivte.tag = indexPath.row;
        [cell.btnAddOrInivte addTarget:self action:@selector(btnAddClicked:) forControlEvents:UIControlEventTouchUpInside];
        if([hideBtnFlags count]>0)
        {
            //TO DEAL WITH SENT REQUEST ON TABLE RELOAD
            
            if([addedFriends count]>0)
            {
                if([[addedFriends objectAtIndex:indexPath.row] isEqualToString:[NSString stringWithFormat:@"%lu",indexPath.row]])
                {
                    cell.btnAddOrInivte.enabled = NO;
                    titleString = [self generateTitleString:FBF_BTN_PENDING];
                    [cell.btnAddOrInivte setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
                }

            }
            
            if([hideBtnFlags count]>indexPath.row)
            {
                if([[hideBtnFlags objectAtIndex:indexPath.row] isEqualToString:@"1"])
                {
                    cell.btnAddOrInivte.enabled = NO;
                    titleString = [self generateTitleString:FBF_BTN_ADDED];
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
    //self.friendsSections.ta
    if (selectedSegment == 0)
    {
        [self.friendsSections setImage:segImage1HoverState forSegmentAtIndex:0];
        [self.friendsSections setImage:segImage2 forSegmentAtIndex:1];
        self.friendsSearchBar.hidden = NO;
        self.inputLine.hidden = NO;
        cell.actionDeterminationFlag = 2;
        
        if([nativeFriends count]>0)
        {
            
            NSString * capitalString  = [[nativeFriends objectAtIndex:indexPath.row] uppercaseString];
            //cell.nameLabel.text = capitalString;
            //cell.thumbnailImageView.image = [profilePictures objectAtIndex:indexPath.row];
            //cell.emailLbl.text = [emailLists objectAtIndex:indexPath.row];
            [cell populateDataSuggestions:capitalString withEmail:[emailLists objectAtIndex:indexPath.row] andIndexPath:indexPath.row andArray:searchedUserIds andTargetArray:profilePictures];
            
        }
    }
    
    else if(selectedSegment == 1 )
    {
        [self.friendsSections setImage:segImage2HoverState forSegmentAtIndex:1];
        [self.friendsSections setImage:segImage1 forSegmentAtIndex:0];
        cell.actionDeterminationFlag = 3;
        self.friendsSearchBar.hidden = YES;
        self.inputLine.hidden = YES;
        if([reqSenderEmails count]!=0)
        {
            cell.actionDeterminationFlag = 3;
            titleString = [self generateTitleString:FBF_BTN_ACCEPT];
            UIImage *btnIcon = [UIImage imageNamed:titleString];
            [cell.btnAddOrInivte setBackgroundImage:btnIcon forState:UIControlStateNormal];
            NSString * capitalString  = [[reqSenderNames objectAtIndex:indexPath.row] uppercaseString];
           // cell.nameLabel.text = capitalString;
            //cell.emailLbl.text = [reqSenderEmails objectAtIndex:indexPath.row];
            self.requestCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)cell.badgeCount];
            //cell.thumbnailImageView.image = [reqSenderProfilePictures objectAtIndex:indexPath.row];
            [cell populateDataSuggestions:capitalString withEmail:[reqSenderEmails objectAtIndex:indexPath.row] andIndexPath:indexPath.row andArray:DataManager.sharedInstance.pendingFriendRequests andTargetArray:reqSenderProfilePictures];
           
        }

        
    }
    
 return cell;
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 66;
}

-(IBAction)segmentControlTapped:(id)sender
{
    NSString *titleString = [self generateTitleString:FIND_FRIENDS_SEG0_UNSELECTED];
    UIImage *segImage1 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.friendsSections setImage:segImage1 forSegmentAtIndex:0];
    
    titleString = [self generateTitleString:FIND_FRIENDS_SEG1_UNSELECTED];
    UIImage *segImage2 = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    titleString = [self generateTitleString:FIND_FRIENDS_SEG0_SELECTED];
    UIImage *segImage1HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    titleString = [self generateTitleString:FIND_FRIENDS_SEG1_SELECTED];
    UIImage *segImage2HoverState = [[UIImage imageNamed:titleString] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    switch (self.friendsSections.selectedSegmentIndex)
    {
        case 0:
        
            selectedSegment=0;
            self.friendsSearchBar.hidden = NO;
            self.inputLine.hidden = NO;
            [self.friendsSections setImage:segImage1HoverState forSegmentAtIndex:0];
            [self.friendsSections setImage:segImage2 forSegmentAtIndex:1];
            
            break;
        case 1:
            selectedSegment=1;
            [self.friendsSections setImage:segImage1 forSegmentAtIndex:0];
            [self.friendsSections setImage:segImage2HoverState forSegmentAtIndex:1];
            self.friendsSearchBar.hidden = YES;
            self.inputLine.hidden = YES;
            break;
        default:
            break;
    }
    [self switchTables];
}
-(void) switchTables
{
    if(selectedSegment==0)
    {
        
        CGRect frame= self.tableViewFriendsList.frame;
        [self.tableViewFriendsList setFrame:CGRectMake(0, 177, frame.size.width,  frame.size.height )];
        [nativeFriends removeAllObjects];
        [emailLists removeAllObjects];
        [profilePictures removeAllObjects];
        DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        [DataManager.sharedInstance.selectedContacts removeAllObjects];
        [self.tableViewFriendsList reloadData];
    }
    
    else if (selectedSegment==1)
    {
        
       
        CGRect frame= self.tableViewFriendsList.frame;
        [self.tableViewFriendsList setFrame:CGRectMake(0, 129, frame.size.width,  frame.size.height )];
        [nativeFriends removeAllObjects];
        [emailLists removeAllObjects];
        [profilePictures removeAllObjects];
        self.badgeBackground.hidden = YES;
        self.requestCount.hidden = YES;
        DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
        self.friendsSearchBar.text = @"";
        [addedFriends removeAllObjects];
        
        [reqSenderEmails removeAllObjects];
        [reqSenderNames removeAllObjects];
        [reqSenderProfilePictures removeAllObjects];
        [self getPendingRequests];
        
         
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        [DataManager.sharedInstance.selectedContacts removeAllObjects];
        //[self.tableViewFriendsList reloadData];
        
    }
    
}


-(IBAction)btnBackTapped:(id)sender
{
    [nativeFriends removeAllObjects];
    [emailLists removeAllObjects];
    [profilePictures removeAllObjects];
    DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)updateData{
    reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
    reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
    reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
    nativeFriends = [[NSMutableArray alloc] init];
    emailLists = [[NSMutableArray alloc] init];
    profilePictures = [[NSMutableArray alloc] init];
    pendingRequests = [NSMutableArray arrayWithArray:DataManager.sharedInstance.pendingFriendRequests];
    
}
- (void)reloadMyTable {
    [self updateData];
    [self.tableViewFriendsList reloadData];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the apply specified item to be editable.
    
    if(selectedSegment == 1) // such like indexPath.row == 1,... or whatever.
        return YES;
    else
        return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self startAnimation];
    NSString * selectedContactId = [DataManager.sharedInstance.pendingFriendRequests objectAtIndex:indexPath.row];
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
                NSLog(@"selected contact:%@", selectedContactId);
                PFQuery * query = [PFUser query];
                PFObject * targetUser;
                targetUser = [query getObjectWithId:selectedContactId];
                PFQuery * socialTarget = [PFQuery queryWithClassName:@"Social"];
                [socialTarget whereKey:@"user" equalTo:targetUser];
                PFObject * targetSocial = [socialTarget getFirstObject];
                NSMutableArray * targetsSentRequests = [[NSMutableArray alloc] initWithArray:targetSocial[@"sentRequests"]];
                [targetsSentRequests removeObject:[PFUser currentUser].objectId];
                targetSocial[@"sentRequests"] = targetsSentRequests;
                [targetSocial save];
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
                        self.requestCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)[DataManager.sharedInstance.pendingFriendRequests count]];
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
               
            }
        }];
        
        
        
    }
}
-(void) getFriendsUsernames
{
    NSMutableArray * objectIDs = [[NSMutableArray alloc] initWithArray: DataManager.sharedInstance.retrievedFriends];
    PFQuery *query = [PFUser query];
    [nativeFriends removeAllObjects];
    [profilePictures removeAllObjects];
    [emailLists removeAllObjects];
    [DataManager.sharedInstance.friendsEmailAdresses removeAllObjects];
    [DataManager.sharedInstance.friendsUsernames removeAllObjects];
    [DataManager.sharedInstance.friendsProfilePictures removeAllObjects];
    NSUInteger friendsCount = [objectIDs count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:objectIDs[i]];
        [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
        [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
        //imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        //UIImage *imageFromData = [UIImage imageWithData:imageData];
        //[DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
        [DataManager.sharedInstance.friendsProfilePictures addObject:[UIImage imageNamed:@"dummyImage"]];
    }
}


-(void) getPendingRequests
{
    [self startAnimation];
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
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
        //UIImage *imageFromData = [UIImage imageWithData:imageData];
        //[DataManager.sharedInstance.reqSenderProfilePictures addObject:imageFromData];
        [DataManager.sharedInstance.reqSenderProfilePictures addObject:[UIImage imageNamed:@"dummyImage"]];
        reqSenderNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderNames];
        reqSenderEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderEmails];
        reqSenderProfilePictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.reqSenderProfilePictures];
        //[self.tableViewFriendsList reloadData];
    }
    [self stopAnimation];
    [self.tableViewFriendsList reloadData];
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self searchBtnTapped];
    return YES;
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

-(void)dismissKeyboard {
    [self.friendsSearchBar resignFirstResponder];
}

-(void) searchBtnTapped
{
    hideBtnFlags = [[NSMutableArray alloc] init];
    DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
    searchedUserIds = [[NSArray alloc] init];
    if(self.friendsSearchBar.text.length<3)
    {
        NSString * errorString = @"Enter at last three characters to search";
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
    else if(self.friendsSearchBar.text.length>2)
    {
        [self startAnimation];
       
        [searchResultFriends removeAllObjects];
        [searchResultEmails removeAllObjects];
        [searchResultProfilePictures removeAllObjects];
        NSString * usernameToBeSearched = [self.friendsSearchBar.text lowercaseString];
       
        PFQuery * query2 = [PFUser query];
        PFQuery * query1 = [PFUser query];
        [query2 whereKey:@"email" containsString:usernameToBeSearched];
        [query1 whereKey:@"username" containsString:usernameToBeSearched];
        PFQuery * mainQuery = [PFQuery orQueryWithSubqueries:@[query1,query2]];
        
        
        [mainQuery findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error)
         {
             PFUser * user = [PFUser currentUser];
             PFObject * targetUser;
             
             if(!error)
             {
                 DataManager.sharedInstance.foundUsers = foundUsers;
                 NSMutableArray *objectIdso = [[NSMutableArray alloc] init];
                 for(int i = 0;i<[foundUsers count];i++)
                 {
                     [addedFriends addObject:@" "];
                     
                     PFObject *usero = [foundUsers objectAtIndex:i];
                     
                     [objectIdso addObject:usero.objectId];
                 }
                 NSArray * targetsRequests = [[NSArray alloc] init];
                 PFQuery * query = [PFQuery queryWithClassName:@"Social"];
                 if([DataManager.sharedInstance.foundUsers count]>0)
                 {
                 for(PFUser * foundUser in DataManager.sharedInstance.foundUsers)
                 {
                     [query whereKey:@"user" equalTo:foundUser];
                     user = foundUser;
                     targetUser=[query getFirstObject];
                     targetsRequests = targetUser[@"pendingRequests"];
                     
                     if(![DataManager.sharedInstance.blockedContacts containsObject:user.objectId] && ![targetUser[@"blockedContacts"] containsObject:[PFUser currentUser].objectId])
                     {
                         if (![user.objectId  isEqualToString:[PFUser currentUser].objectId])
                         {
                             [searchResultFriends addObject:user[@"username"]];
                             [searchResultEmails addObject:user[@"email"]];
                             
                             resultProfilePictureData = [user objectForKey:@"profilePicture"];
                             //NSData *imageData = [resultProfilePictureData getData];
                             UIImage * resultProfilePic = [UIImage imageNamed:@"dummyImage"];
                             
                             
                             //For hiding add button
                             if(resultProfilePic!=nil)
                             {
                                 [searchResultProfilePictures addObject:resultProfilePic];
                             }
                             else if(resultProfilePic==nil)
                             {
                                 [searchResultProfilePictures addObject:[UIImage imageNamed:@"dummyImage.png"]];
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
                             
                             if(![DataManager.sharedInstance.retrievedFriends containsObject:user.objectId] && ![DataManager.sharedInstance.pendingFriendRequests containsObject:user.objectId] && ![user.objectId isEqualToString:[PFUser currentUser].objectId] && ![targetsRequests containsObject:[PFUser currentUser].objectId])
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
                     DataManager.sharedInstance.foundUsers = searchResultFriends;
                     nativeFriends = searchResultFriends;
                     profilePictures = searchResultProfilePictures;
                     emailLists = searchResultEmails;
                     [self stopAnimation];
                     searchedUserIds = [[NSArray alloc] initWithArray:objectIdso];
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
-(void) refreshLists
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
             DataManager.sharedInstance.sentRequests = social[@"sentRequests"];
             [self getRequestSendersProfile];
         }
     }];
}

-(void) btnAddClicked:(UIButton *) sender
{
    [self startAnimation];
    NSString * lowerString;
    sender.enabled=NO;
    if(selectedSegment==0)
    {
         lowerString = [[nativeFriends objectAtIndex:sender.tag] lowercaseString];
        [addedFriends replaceObjectAtIndex:sender.tag withObject:[NSString  stringWithFormat:@"%lu",sender.tag]];
    }
    else if(selectedSegment == 1)
    {
        lowerString = [[reqSenderNames objectAtIndex:sender.tag] lowercaseString];
    }
   
    
    
    NSString * selectedContact= lowerString;
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:selectedContact];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error){
        NSString * objectIDD;
        PFUser * contact = [PFUser user];
        if([foundUsers count]  == 1)
        {
            for (PFUser *foundUser in foundUsers)
            {
                objectIDD = foundUser.objectId;
                contact = foundUser;
            }
        }
        if(selectedSegment == 0)
        {
            sender.enabled = YES;
            PFQuery * query2 = [PFQuery queryWithClassName:@"Social"];
            [query2 whereKey:@"user" equalTo:contact];
            NSString * sendersObjectId = [PFUser currentUser].objectId;
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
                         }
                         else if(friendListCheck == YES)
                         {
                             errorString = @"User's already exists in Friend List";
                         }
                         else if(sentRequestCheck)
                         {
                             errorString = @"You have already sent a request to this user";
                         }
                         [self stopAnimation];
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
                             
                             NSString * senderName =  DataManager.sharedInstance.myName;
                             NSLog(@"%@", senderName);
                             [DataManager sendAddRequestNotification:senderName totalRequests:[pendingRequestsOfTargetUser count] andReceiverID:targetsId];
                             [hideBtnFlags replaceObjectAtIndex:sender.tag withObject:@"4"];
                             
                             [self stopAnimation];
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
        else if(selectedSegment == 1)
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
                         [self stopAnimation];
                         NSString *errorString = @"Friend request accepted";
                         [DataManager sendRequestAcceptedNotification:[PFUser currentUser].username andReceiverID:objectIDD];
                         //TO FIX CRASH
                         [[DataManager sharedInstance].messages addObject:@""];
                         
                         [self getFriendsUsernames];
                         [self.tableViewFriendsList reloadData];
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
-(void) setUpTheme
{
    _navigationBar.image = [UIImage imageNamed:[self generateTitleString:BG_TOP_BAR_GROUP]];
    [_btnBack setImage:[UIImage imageNamed:[self generateTitleString:BTN_BACK]] forState:UIControlStateNormal];
    
}

-(NSString *) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return  titleString;
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
