//
//  FriendsManagementViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 13/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "FriendsManagementViewController.h"

@interface FriendsManagementViewController ()

@end

@implementation FriendsManagementViewController
@synthesize tableView;

-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    [super viewWillAppear:animated]; // clears selection
    if (selectedRowIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [self mergeLists];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    [self.view addSubview:self.tableView];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    [self mergeLists];
    [self calculateFriends];
    self.btnNext.hidden = YES;
    indexer = 0;
    [self setUpTheme];
    
}
-(void) mergeLists
{
    //To merge friends and blocked contacts
    combinedList = [[NSMutableArray alloc] init];
    combinedListEmails = [[NSMutableArray alloc] init];
    combinedListNames = [[NSMutableArray alloc] init];
    combinedListPictures = [[NSMutableArray alloc] init];
    combinedList = [[DataManager.sharedInstance.retrievedFriends arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedContacts] mutableCopy];
    combinedListEmails = [NSMutableArray arrayWithArray:DataManager.sharedInstance.friendsEmailAdresses];
    combinedListNames = [NSMutableArray arrayWithArray:DataManager.sharedInstance.friendsUsernames];
    combinedListPictures = [NSMutableArray arrayWithArray:DataManager.sharedInstance.friendsProfilePictures];
    
    combinedListEmails = [[combinedListEmails arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedEmails] mutableCopy];
    combinedListNames = [[combinedListNames arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedNames] mutableCopy];
    combinedListPictures = [[combinedListPictures arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedPictures] mutableCopy];
    pointOfMerger = ([DataManager.sharedInstance.friendsUsernames count])-1;
    NSLog(@"Point of merger: %lu", pointOfMerger);
    NSLog(@"Combined: %@", combinedListNames);
    
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void) calculateFriends
{
    NSString * countString = [NSString stringWithFormat:@"%lu", (unsigned long)[DataManager.sharedInstance.retrievedFriends count]];
    NSString * lblCountText = [NSString stringWithFormat:@"You have %@ friends", countString];
    self.lblCount.text = lblCountText;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   
    //return [sharedClass.sharedInstance.retrievedFriends count];
    return [combinedList count];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    FriendManagementTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        NSArray *cellView = [[NSBundle mainBundle] loadNibNamed:@"FriendManagementTableViewCell" owner:nil options:nil];
        cell = (FriendManagementTableViewCell *)[cellView objectAtIndex:0];
        cell.delegate = self;
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];
        NSString *title = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_BORDER];
        title = [NSString stringWithFormat:@"%@%lu",title,indexer];
        cell.thumbnailImageFrame.image = [UIImage imageNamed:title];
        indexer++;
        
    }
    //NSString * capitalName = [[sharedClass.sharedInstance.friendsUsernames objectAtIndex:indexPath.row] uppercaseString];
    if([DataManager.sharedInstance.friendsUsernames count]>0)
    {
        NSString * capitalName = [[combinedListNames objectAtIndex:indexPath.row] uppercaseString];
        NSLog(@"capital name: %@", capitalName);
        //cell.usernameLbl.text = capitalName;
        cell.btnUnfriend.tag = indexPath.row;
        cell.btnBlock.tag = indexPath.row;
        if(indexPath.row>pointOfMerger)
        {
            cell.btnUnfriend.hidden = YES;
            cell.btnBlock.hidden = YES;
            cell.btnUnblock = [[UIButton alloc] initWithFrame:CGRectMake(255, 12, 60, 30)];
            [cell addSubview:cell.btnUnblock];
            titleString = [self generateTitleString:MANAGE_FRIENDS_BTN_UNBLOCK];
            [cell.btnUnblock setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
            cell.btnUnblock.tag = indexPath.row;
        }

        [cell.btnUnfriend addTarget:self action:@selector(btnUnfriendClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnBlock addTarget:self action:@selector(btnBlockClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnUnblock addTarget:self action:@selector(btnUnBlockClicked:) forControlEvents:UIControlEventTouchUpInside];
        //cell.thumbnailImageView.image = [combinedListPictures objectAtIndex:indexPath.row];
        //cell.emailLbl.text = [combinedListEmails objectAtIndex:indexPath.row];
        [cell populateData:capitalName withEmail:[combinedListEmails objectAtIndex:indexPath.row] andPicture:[combinedListPictures objectAtIndex:indexPath.row] andIndexPath:(int)indexPath.row];
    }
    else
    {
        NSString * capitalName = [[combinedListNames objectAtIndex:indexPath.row] uppercaseString];
        NSLog(@"capital name: %@", capitalName);
        //cell.usernameLbl.text = capitalName;
        cell.btnUnfriend.hidden = YES;
        cell.btnBlock.hidden = YES;
        cell.btnUnblock = [[UIButton alloc] initWithFrame:CGRectMake(255, 12, 60, 30)];
        [cell addSubview:cell.btnUnblock];
        titleString = [self generateTitleString:MANAGE_FRIENDS_BTN_UNBLOCK];
        [cell.btnUnblock setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        cell.btnUnblock.tag = indexPath.row;
        [cell.btnUnfriend addTarget:self action:@selector(btnUnfriendClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnBlock addTarget:self action:@selector(btnBlockClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnUnblock addTarget:self action:@selector(btnUnBlockClicked:) forControlEvents:UIControlEventTouchUpInside];
        //cell.thumbnailImageView.image = [combinedListPictures objectAtIndex:indexPath.row];
        //cell.emailLbl.text = [combinedListEmails objectAtIndex:indexPath.row];
        [cell populateData:capitalName withEmail:[combinedListEmails objectAtIndex:indexPath.row] andPicture:[combinedListPictures objectAtIndex:indexPath.row] andIndexPath:(int)indexPath.row];
    }
    
    if(indexer==7)
    {
        indexer = 0;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 76;
}

- (void)reloadMyTable {
    [self.tableView reloadData];
    
    [self calculateFriends];
}

-(IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) btnUnBlockClicked: (UIButton *) sender
{
    [self startAnimation];
    // NSString * lowerString = [sharedClass.sharedInstance.friendsUsernames objectAtIndex:sender.tag];
    NSString * lowerString = [combinedListNames objectAtIndex:sender.tag];
    NSString * friendToBeUnblocked = lowerString;
    sender.enabled = NO;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:friendToBeUnblocked];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error)
     {
         NSString * objectIDD;
         PFUser *contact;
         if(!error)
         {
             if([foundUsers count]  == 1)
             {
                 for (PFUser *foundUser in foundUsers)
                 {
                     objectIDD = foundUser.objectId;
                     contact = foundUser;
                 }
             }
             
             PFQuery * query3 = [PFQuery queryWithClassName:@"Social"];
             [query3 whereKey:@"user" equalTo:[PFUser currentUser]];
             [query3 getFirstObjectInBackgroundWithBlock:^(PFObject * targetUser, NSError * error)
              {
                  if(!error)
                  {
                      [self calculateFriends];
                      NSMutableArray * blockedContacts = [[NSMutableArray alloc]  initWithArray: targetUser[@"blockedContacts"]];
                      [blockedContacts removeObject:objectIDD];
                      targetUser[@"blockedContacts"] = blockedContacts;
                      DataManager.sharedInstance.blockedContacts = blockedContacts;
                      combinedList = [[DataManager.sharedInstance.retrievedFriends arrayByAddingObjectsFromArray:DataManager.sharedInstance.blockedContacts] mutableCopy];
                      [combinedListNames removeObjectAtIndex:sender.tag];
                      [combinedListPictures removeObjectAtIndex:sender.tag];
                      [combinedListEmails removeObjectAtIndex:sender.tag];
                      [targetUser saveInBackground];
                      [self.tableView reloadData ];
                      [self stopAnimation];
                      UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Contact UnBlocked" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                      //self.btnBlock.enabled = YES;
                      [errorAlertView show];
                  }
                  
              }];
             
             
             NSLog(@"friends now: %@", DataManager.sharedInstance.retrievedFriends);
         }
     }];

}
-(void) btnUnfriendClicked: (UIButton *) sender
{
    [self startAnimation];
    NSString *objectID = [combinedList objectAtIndex:sender.tag];
    sender.enabled = NO;
    PFQuery *query = [PFUser query];
    NSString * nameToBeUnfriended = [combinedListNames objectAtIndex:sender.tag];
    if([DataManager.sharedInstance.suggestedFriendsUsernames containsObject:nameToBeUnfriended])
    {
        
        for(int i = 0; i<[DataManager.sharedInstance.suggestedFriendsUsernames count];i++)
        {
            if([DataManager.sharedInstance.suggestedFriendsUsernames[i] isEqualToString:nameToBeUnfriended])
            {
                [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:i withObject:@"0"];
                break;
            }
        }
        
        
    }
    [query whereKey:@"objectId" equalTo:objectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error)
     {
         NSString * objectIDD;
         PFUser * contact;
         if(!error)
         {
             if([foundUsers count]  == 1)
             {
                 for (PFUser *foundUser in foundUsers)
                 {
                     objectIDD = foundUser.objectId;
                     contact = foundUser;
                 }
             }
             //Reomving myself from target's list
             PFQuery * query2 = [PFQuery queryWithClassName:@"Social"];
             [query2 whereKey:@"user" equalTo:contact];
            [query2 getFirstObjectInBackgroundWithBlock:^(PFObject * targetUser,NSError * error)
              {
                  if(!error)
                  {
                      NSMutableArray * targetFriends = [[NSMutableArray alloc]  initWithArray: targetUser[@"nativeFriendsIds"]];
                      [targetFriends removeObject:[PFUser currentUser].objectId];
                      targetUser[@"nativeFriendsIds"] = targetFriends;
                      [targetUser saveInBackground];

                  }
              }];
             
             //removing target from my list
             PFQuery * query3 = [PFQuery queryWithClassName:@"Social"];
             [query3 whereKey:@"user" equalTo:[PFUser currentUser]];
             [query3 getFirstObjectInBackgroundWithBlock:^(PFObject *targetUser, NSError * error)
              {
                  if(!error)
                  {
                      
                      NSMutableArray * targetFriends = [[NSMutableArray alloc]  initWithArray: targetUser[@"nativeFriendsIds"]];
                      [targetFriends removeObject:objectIDD];
                      targetUser[@"nativeFriendsIds"] = targetFriends;
                      DataManager.sharedInstance.retrievedFriends = targetFriends;
                      
                      
                      [DataManager.sharedInstance.friendsEmailAdresses removeObjectAtIndex:sender.tag];
                      [DataManager.sharedInstance.friendsProfilePictures removeObjectAtIndex:sender.tag];
                      [DataManager.sharedInstance.friendsUsernames removeObjectAtIndex:sender.tag];
                      //TO FIX CRASH BUG
                      [[DataManager sharedInstance].messages removeObjectAtIndex:sender.tag];
                      
                      [self mergeLists];
                      
                      [targetUser saveInBackground];
                      [self calculateFriends];
                      [self.tableView reloadData];
                      [self stopAnimation];
                      UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Friend Removed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                      [errorAlertView show];
                  }
              }];
             
             NSLog(@"Combo now: %@", combinedList);

         }
     }];
    

}

-(void) btnBlockClicked: (UIButton *) sender
{
    [self startAnimation];
    NSString * lowerString = [combinedListNames objectAtIndex:sender.tag];
    NSString * friendToBeUnfriended = lowerString;
    sender.enabled = NO;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:friendToBeUnfriended];
    [query findObjectsInBackgroundWithBlock:^(NSArray * foundUsers, NSError * error)
     {
         NSString * objectIDD;
         PFUser *contact;
         if(!error)
         {
             if([foundUsers count]  == 1)
             {
                 for (PFUser *foundUser in foundUsers)
                 {
                     objectIDD = foundUser.objectId; 
                     contact = foundUser;
                 }
             }
             
             PFQuery * query2 = [PFQuery queryWithClassName:@"Social"];
             [query2 whereKey:@"user" equalTo:contact];
             [query2 getFirstObjectInBackgroundWithBlock:^(PFObject * targetUser, NSError * error)
             {
                 if(!error)
                 {
                     NSMutableArray * targetFriends = [[NSMutableArray alloc]  initWithArray: targetUser[@"nativeFriendsIds"]];
                     [targetFriends removeObject:[PFUser currentUser].objectId];
                     targetUser[@"nativeFriendsIds"] = targetFriends;
                     [targetUser saveInBackground];

                 }
             }];
             PFQuery * query3 = [PFQuery queryWithClassName:@"Social"];
             [query3 whereKey:@"user" equalTo:[PFUser currentUser]];
             [query3 getFirstObjectInBackgroundWithBlock:^(PFObject * targetUser, NSError * error)
              {
                  if(!error)
                  {
                      NSMutableArray * targetFriends = [[NSMutableArray alloc]  initWithArray: targetUser[@"nativeFriendsIds"]];
                      [targetFriends removeObject:objectIDD];
                      targetUser[@"nativeFriendsIds"] = targetFriends;
                      //retrieving blocked contacts details
                      NSString * blockedEmail= [combinedListEmails objectAtIndex:sender.tag];
                      NSString * blockedName = [combinedListNames objectAtIndex:sender.tag];
                      UIImage * blockedImage = [combinedListPictures objectAtIndex:sender.tag];
                      DataManager.sharedInstance.retrievedFriends = targetFriends;
                      [DataManager.sharedInstance.friendsEmailAdresses removeObjectAtIndex:sender.tag];
                      [DataManager.sharedInstance.friendsProfilePictures removeObjectAtIndex:sender.tag];
                      [DataManager.sharedInstance.friendsUsernames removeObjectAtIndex:sender.tag];
                      //TO FIX CRASH BUG
                      [[DataManager sharedInstance].messages removeObjectAtIndex:sender.tag];
                      
                      [self calculateFriends];
                      NSMutableArray * blockedContacts = [[NSMutableArray alloc]  initWithArray: targetUser[@"blockedContacts"]];
                      [blockedContacts addObject:objectIDD];
                      targetUser[@"blockedContacts"] = blockedContacts;
                      //updating blocked section
                      DataManager.sharedInstance.blockedContacts = blockedContacts;
                      [DataManager.sharedInstance.blockedNames addObject:blockedName];
                      [DataManager.sharedInstance.blockedPictures addObject:blockedImage];
                      [DataManager.sharedInstance.blockedEmails addObject:blockedEmail];
                      [self mergeLists];
                      [targetUser saveInBackground];
                      [self.tableView reloadData ];
                      [self stopAnimation];
                      UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Friend Blocked" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                      [errorAlertView show];
                  }

              }];
             
             
             NSLog(@"friends now: %@", DataManager.sharedInstance.retrievedFriends);
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
-(void) setUpTheme
{
    _navigationBar.image = [UIImage imageNamed:[self generateTitleString:BG_TOP_BAR]];
    [_btnBack setImage:[UIImage imageNamed:[self generateTitleString:BTN_BACK]] forState:UIControlStateNormal];
    
}

-(NSString *) generateTitleString: (NSString*) key
{
    NSString *titleStringo;
    titleStringo = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return  titleStringo;
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
