//
//  MainScreenViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 17/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "MainScreenViewController.h"
#import "GroupShoutOutViewController.h"
#import "SingleShoutOutViewController.h"

@interface MainScreenViewController ()

@end

@implementation MainScreenViewController
@synthesize tableViewMainFriendList;
@synthesize indexer;

-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    NSIndexPath *selectedRowIndexPath = [self.tableViewMainFriendList indexPathForSelectedRow];
    [super viewWillAppear:animated];
    // clears selection
    searchBarOpened = NO;
    if (selectedRowIndexPath) {
        [self.tableViewMainFriendList reloadRowsAtIndexPaths:@[selectedRowIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendRequestAccepted:) name:SET_READY_FOR_RELOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:FRIEND_REQUEST_ACCEPTED_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shoutOutSent)
                                                 name:GROUP_SHOUT_OUT_DONE
                                               object:nil];
    
        //[self setUpMainScreen];
    NSLog(@"Theme Specs:%@", DataManager.sharedInstance.themeSpecs);
    //self.mainScreenBackgroundImgView.image = [UIImage imageNamed:[DataManager.sharedInstance.themeSpecs objectAtIndex:0]];
    [_btnNotifications addTarget:self action:@selector(btnNotificationsTapped) forControlEvents:UIControlEventTouchUpInside];
   
    themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    if(themeNumber == nil)
    {
        themeNumber = @"1";
    }
    NSString * themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    [self setUpTheme];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    
    
    self.searchBar.hidden = YES;
    [self stopAnimation];
    frameDefault = self.tableViewMainFriendList.frame;
    [self dismissKeyboard];
    [tableViewMainFriendList reloadData];

    if([DataManager sharedInstance].requestBadge!=0)
    {
        self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    }
    else
    {
        self.badgeNotification.text = @"0";
    }
    
    if([self.badgeNotification.text isEqualToString:@"0"] || [self.badgeNotification.text isEqualToString:@""])
    {
        NSString *themeNumbero = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
        NSString *titleString = [NSString stringWithFormat:@"theme%@_main_notification",themeNumbero];
        self.badgeNotification.hidden = YES;
        self.badgeBackgroundView.hidden = YES;
        [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"] && ![self.badgeNotification.text isEqualToString:@""])
    {
        NSString *themeNumbero = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
        NSString *titleString = [NSString stringWithFormat:@"theme%@_btn_notification",themeNumbero];
        self.badgeNotification.hidden = NO;
        self.badgeBackgroundView.hidden = NO;
        [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    }

    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_FRIEND_REQUEST_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FRIEND_REQUEST_ACCEPTED_NOTIFICATION
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GROUP_SHOUT_OUT_DONE
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SET_READY_FOR_RELOAD object:nil];
}

-(void) viewDidLayoutSubviews
{
    
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        _scroller.bounces = NO;
        _scroller.backgroundColor = [UIColor clearColor];
        [_scroller setContentSize:contentSize];
    }
    
    [self highlightBadge];
    
}

-(void) friendRequestAccepted: (NSNotification * )_ntf
{
    //reload friend screen on friend request accepted.
    activity1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity1.frame = CGRectMake(round((self.view.frame.size.width - 25) / 2), round((self.view.frame.size.height - 25) / 2), 25, 25);
    activity1.hidesWhenStopped = YES;
    activity1.tag = 666;
    [activity1 startAnimating];
    [self.view addSubview:activity1];
    
    //[self setUpMainScreen];
    //[tableViewMainFriendList reloadData];
}

-(void) showDropDownMenu: (UIButton *) sender
{
    self.btnDragDownMenu.hidden = YES;
    
    if (!menuView) {
        menuView = [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:nil options:nil][0];
        [self.view addSubview:menuView];
        [menuView.hideButton addTarget:self action:@selector(hideMenu:) forControlEvents:UIControlEventTouchUpInside];
        menuView.delegate = self;
        //[menuView.hideButton setBackgroundColor:self.btnShowMenu.backgroundColor];
    }
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    [menuView adjustHeightWithSingleCellHeight:100 numberOfCells:[allThemesInfo count]];
    
    CGRect btnFrame = self.btnDragDownMenu.frame;
    __block CGRect menuFrame = menuView.frame;
    
    CGFloat menuBtnEndPosition = btnFrame.origin.y + btnFrame.size.height;
    menuFrame.origin.y = menuBtnEndPosition - menuFrame.size.height;
    menuView.startingYAxis = menuFrame.origin.y;
    menuView.frame = menuFrame;
    menuView.hidden = NO;
    menuFrame.origin.y = 0; // Intended Position
    menuView.btnBack.hidden = YES;
    //[self.view bringSubviewToFront:menuView];
    
    menuView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        menuView.frame = menuFrame;
    } completion:^(BOOL finished) {
        menuView.open  = YES;
        self.btnDragDownMenu.hidden = NO;
        menuView.userInteractionEnabled = YES;
    }];
    
}
- (void)hideMenu:(id)sender {
    
    menuView.userInteractionEnabled = NO;
    
    CGRect btnFrame = self.btnDragDownMenu.frame;
    __block CGRect menuFrame = menuView.frame;
    
    CGFloat menuBtnEndPosition = btnFrame.origin.y + btnFrame.size.height;
    menuFrame.origin.y = menuBtnEndPosition - menuFrame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        menuView.frame = menuFrame;
        
    } completion:^(BOOL finished) {
        menuView.open = NO;
        menuView.hidden = YES;
        self.btnDragDownMenu.hidden = NO;
        menuView.userInteractionEnabled = YES;
    }];
    
}


-(void) navigateBack
{

}
-(void) themeSelected: (NSIndexPath *) indexPath
{
    NSLog(@"%ld",(long)indexPath.item);
    themeNumber = [NSString stringWithFormat:@"%li",(long)(indexPath.row+1)];
    [self getThemeData:themeNumber];
    [self setUpTheme];
}

- (void)newFriendRequest:(NSNotification*)_ntf {
    int badge = [self.badgeNotification.text intValue];
    NSLog(@"%@",self.badgeNotification.text);
    if(badge>0)
    {
        badge = badge+[DataManager sharedInstance].requestBadge;
        self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)badge];
    }
    else
    {
        self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    }
    
    [DataManager sharedInstance].requestBadge = 0;
    NSString *themeNumbero = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    NSString *titleString = [NSString stringWithFormat:@"theme%@_btn_notification",themeNumbero];
    [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        self.badgeBackgroundView.hidden = YES;
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
        self.badgeBackgroundView.hidden = NO;
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.tableViewMainFriendList.backgroundColor = [UIColor clearColor];
    self.tableViewMainFriendList.dataSource = self;
    self.tableViewMainFriendList.delegate = self;
    //[self.view addSubview:self.tableViewMainFriendList];
    //[self.view addSubview:self.bottomButtonView];
    self.indexer = 0;
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    SWRevealViewController *revealController = [self revealViewController];
    _searchBar.delegate = self;
    themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    if(themeNumber == nil)
    {
        themeNumber = @"1";
    }

    NSString * themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    self.mainScreenBackgroundImgView.image = [UIImage imageNamed:[self generateTitleString:BG_MAIN]];
    
    [self.btnDragDownMenu addTarget:self action:@selector(showDropDownMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [revealController tapGestureRecognizer];
    [_btnSideMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    //[self setUpMainScreen];
    self.searchBar.hidden = YES;
    frameDefault = self.tableViewMainFriendList.frame;
    [self stopAnimation];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    [self setUpTheme];
    [self dismissKeyboard];
    UIApplication *application = [UIApplication sharedApplication];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [PFInstallation currentInstallation].badge = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }

   // [self highlightBadge];

   
}
-(void)menuItemSelected:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.item);
    themeNumber = [NSString stringWithFormat:@"%li",(long)(indexPath.row+1)];
    [self getThemeData:themeNumber];
    [self setUpTheme];
}

-(void) dismissKeyboard
{
    CGRect frame= frameDefault;
    self.searchBar.hidden = YES;
    _searchBar.text = @"";
    self.searchBar.tag = 1;
    [self.tableViewMainFriendList setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    [self.searchBar resignFirstResponder];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(searchBarOpened == YES)
    {
        return [searchedTags count];
    }
    return [DataManager.sharedInstance.retrievedFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    MainScreenTableViewCell *cell = (MainScreenTableViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        
        NSArray *cellView = [[NSBundle mainBundle] loadNibNamed:@"MainScreenTableViewCell" owner:nil options:nil];
        cell = (MainScreenTableViewCell *)[cellView objectAtIndex:0];
        cell.delegate = self;
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];
        [cell.btnShoutOut addTarget:self action:@selector(sendShoutOut:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
    }
    if([DataManager.sharedInstance.friendsUsernames count]>0)
    {
        
        if(searchBarOpened == NO)
        {
            NSString * capitalCase = [[DataManager.sharedInstance.friendsUsernames objectAtIndex:indexPath.row] uppercaseString];
            NSString * capitalMessage = @"";
            
            if([DataManager.sharedInstance.messages count]>indexPath.row)
            {
                NSString* elmessago = [[[DataManager sharedInstance] messages] objectAtIndex:indexPath.row];
                capitalMessage = [elmessago uppercaseString];
            }
            
            if(indexer>=[cell.imageFrames count])
            {
                indexer = 0;
            }
            indexer = indexPath.row % 7;
            //cell.usernameLbl.text = capitalCase;
            //cell.lastMessageLbl.text = capitalMessage;
            cell.profilePicture.contentMode = UIViewContentModeRedraw;
            //cell.profilePicture.image = [DataManager.sharedInstance.friendsProfilePictures objectAtIndex:indexPath.row];
            [cell populateData:capitalCase withMessage:capitalMessage andPicture:[DataManager.sharedInstance.friendsProfilePictures objectAtIndex:indexPath.row]andIndexPath:(int)indexPath.row];
            
            NSString * themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
            if([themeNumber length] == 0)
            {
                themeId = @"theme1";
            }
            
            NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
            
            [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
            NSString *separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_SEPARATOR];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.seperatorLine.image = [UIImage imageNamed:separatorImage];
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:BTN_SHOUTOUT_SMALL];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            [cell.btnShoutOut setBackgroundImage:[UIImage imageNamed:separatorImage] forState:UIControlStateNormal];
            cell.btnShoutOut.tag = indexPath.row;
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_BORDER];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.profilePictureFrame.image = [UIImage imageNamed:separatorImage];
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_ROUNDICON];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.roundIcon.image = [UIImage imageNamed:separatorImage];
            
            indexer++;
            
        }
        
        else
        {
            NSString * capitalCase = [[searchedName objectAtIndex:indexPath.row] uppercaseString];
            NSString * capitalMessage = @"";
            if([DataManager.sharedInstance.messages count]>indexPath.row)
            {
                NSString* elmessago = [searchedMessage objectAtIndex:indexPath.row];
                capitalMessage = [elmessago uppercaseString];
            }
            
            if(indexer>=[cell.imageFrames count])
            {
                indexer = 0;
            }
            indexer = indexPath.row % 7;
            //cell.usernameLbl.text = capitalCase;
            //cell.lastMessageLbl.text = capitalMessage;
            cell.profilePicture.contentMode = UIViewContentModeRedraw;
            //cell.profilePicture.image = [searchedProfilePicture objectAtIndex:indexPath.row];
            [cell populateData:capitalCase withMessage:capitalMessage andPicture:[searchedProfilePicture objectAtIndex:indexPath.row]andIndexPath:(int)indexPath.row];
            NSString * themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
            if([themeNumber length] == 0)
            {
                themeId = @"theme1";
            }
            
            NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
            
            [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
            NSString *separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_SEPARATOR];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.seperatorLine.image = [UIImage imageNamed:separatorImage];
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:BTN_SHOUTOUT_SMALL];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            [cell.btnShoutOut setBackgroundImage:[UIImage imageNamed:separatorImage] forState:UIControlStateNormal];
            cell.btnShoutOut.tag = indexPath.row;
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_BORDER];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.profilePictureFrame.image = [UIImage imageNamed:separatorImage];
            
            separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_ROUNDICON];
            separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)indexer];
            cell.roundIcon.image = [UIImage imageNamed:separatorImage];
            
            indexer++;
            
        }

    }
    
        return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 77;
}

- (void)reloadMyTable {
    [self.tableViewMainFriendList reloadData];
    
}

-(IBAction)mainShoutOutBtnTapped:(id)sender
{
    GroupShoutOutViewController * frontViewController = [[GroupShoutOutViewController alloc] init];
    
    DataManager.sharedInstance.blurredImage = [self takeSnapshotOfView:self.view];
    RearViewController *rearViewController = [[RearViewController alloc] init];
    frontViewController.delegate = self;
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
    revealController.delegate = self;
    revealController.rearViewRevealWidth = 101;
    [self.navigationController pushViewController:revealController animated:YES];
    
    
}

-(IBAction)btnAddFriendsTapped:(id)sender
{
    //[self startAnimation];
    self.badgeNotification.text = @"0";
    DataManager.sharedInstance.requestBadge = 0;
    if(DataManager.sharedInstance.isFbUser == NO)
    {
        FindFriendsViewController *addFriendsScreen = [[FindFriendsViewController alloc] init];
        addFriendsScreen.selectedSegment = 0;
         [self.navigationController pushViewController:addFriendsScreen animated:YES];
        if(DataManager.sharedInstance.addRequestReceived == YES)
        {
           // addFriendsScreen.selectedSegment = 1;
            DataManager.sharedInstance.addRequestReceived = NO;
            //[self stopAnimation];
           
            
        }
    
       
    }
    else
    {
        [self startAnimation];
        FBFindFriendsViewController * findFriendsVC = [[FBFindFriendsViewController alloc] init];
        findFriendsVC.selectedSegment = 0;
        [self.navigationController pushViewController:findFriendsVC animated:YES];
        if(DataManager.sharedInstance.addRequestReceived == YES)
        {
            //findFriendsVC.selectedSegment = 2;
            DataManager.sharedInstance.addRequestReceived = NO;
            [self stopAnimation];
        }
        
    }
    
}
-(void) btnNotificationsTapped
{
    if(![_badgeNotification.text isEqualToString:@"0"] && ![_badgeNotification.text isEqualToString:@""])
    {
        [_btnNotifications setImage:[UIImage imageNamed:@"theme1_main_notification.png"] forState:UIControlStateNormal];
        self.badgeNotification.text = @"0";
        [DataManager sharedInstance].requestBadge = 0;
        [PFInstallation currentInstallation].badge = 0;
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
        if(DataManager.sharedInstance.isFbUser == NO)
        {
            FindFriendsViewController *addFriendsScreen = [[FindFriendsViewController alloc] init];
            addFriendsScreen.selectedSegment = 0;
            [self.navigationController pushViewController:addFriendsScreen animated:YES];
            if(DataManager.sharedInstance.addRequestReceived == YES)
            {
                addFriendsScreen.selectedSegment = 1;
                DataManager.sharedInstance.addRequestReceived = NO;
                //[self stopAnimation];
                
                
            }
            
            
        }
        else
        {
            [self startAnimation];
            FBFindFriendsViewController * findFriendsVC = [[FBFindFriendsViewController alloc] init];
            findFriendsVC.selectedSegment = 0;
            [self.navigationController pushViewController:findFriendsVC animated:YES];
            if(DataManager.sharedInstance.addRequestReceived == YES)
            {
                findFriendsVC.selectedSegment = 2;
                DataManager.sharedInstance.addRequestReceived = NO;
                [self stopAnimation];
            }
            
        }
    }
    

}
-(IBAction)btnSearchTapped:(UIButton *)sender
{
    
    CGRect frame= frameDefault;
    if(self.searchBar.tag == 1)
    {
        self.searchBar.hidden = NO;
        self.searchBar.tag = 0;
        [self.tableViewMainFriendList setFrame:CGRectMake(frame.origin.x, 122, frame.size.width, frame.size.height )];
        searchBarOpened = YES;
        searchedTags = [[NSMutableArray alloc] init];
        searchedProfilePicture = [[NSMutableArray alloc] init];
        searchedName = [[NSMutableArray alloc] init];
        searchedMessage = [[NSMutableArray alloc] init];
        searchedEmail = [[NSMutableArray alloc] init];
        
    }
    else if(self.searchBar.tag == 0)
    {
        self.searchBar.hidden = YES;
        self.searchBar.tag = 1;
        [self.tableViewMainFriendList setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        searchBarOpened = NO;
        [self dismissKeyboard];
        _searchBar.text = @"";
        [searchedEmail removeAllObjects];
        [searchedMessage removeAllObjects];
        [searchedName removeAllObjects];
        [searchedProfilePicture removeAllObjects];
        [searchedTags removeAllObjects];
        [self.tableViewMainFriendList reloadData];
    }

}

- (IBAction)replaceMe:(id)sender
{
}

-(void) reloadMainScreenTable
{
    [self.tableViewMainFriendList reloadData];
}

-(void) setUpMainScreen
{
    [self startAnimation];
    [self refreshMainScreen];
}

-(void) startAnimation
{
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
}

-(void) stopAnimation
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator hidesWhenStopped];
}

-(void) refreshMainScreen
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
    {
        if(!error)
        {
            DataManager.sharedInstance.retrievedFriends = object[@"nativeFriendsIds"];
            [self getFriendsUsernames];
            
        }
    }];
}
-(void) getFriendsUsernames
{
    PFQuery *query = [PFUser query];
    PFFile * imageFile;
    [[DataManager sharedInstance].friendsEmailAdresses removeAllObjects];
    [[DataManager sharedInstance].friendsProfilePictures removeAllObjects];
    [[DataManager sharedInstance].friendsUsernames removeAllObjects];
    NSUInteger friendsCount = [DataManager.sharedInstance.retrievedFriends count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.retrievedFriends[i]];
        [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
        [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
        imageFile = [username objectForKey:@"profilePicture"];
        NSData *imageData = [imageFile getData];
        UIImage *imageFromData = [UIImage imageWithData:imageData];
        [DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
        
    }
    [self getMessages];
    
}

-(void) sendShoutOut: (UIButton *) sender
{
    
    SingleShoutOutViewController * singleShoutOutVC = [[SingleShoutOutViewController alloc] init];
    singleShoutOutVC.indexOfUser = sender.tag;
    if(searchBarOpened == YES && [searchedEmail count]>0)
    {
        singleShoutOutVC.indexOfUser = [[searchedTags objectAtIndex:sender.tag] integerValue];
        [self dismissKeyboard];
        RearViewController *rearViewController = [[RearViewController alloc] init];
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:singleShoutOutVC];
        revealController.delegate = self;
        revealController.rearViewRevealWidth = 101;
        [self.navigationController pushViewController:revealController animated:YES];
        
    }
    else
    {
        RearViewController *rearViewController = [[RearViewController alloc] init];
        
        SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:singleShoutOutVC];
        revealController.delegate = self;
        revealController.rearViewRevealWidth = 101;
        [self dismissKeyboard];
        [self.navigationController pushViewController:revealController animated:YES];
        
    }
   
}

-(void) verifyPushStatus
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject * object = [query getFirstObject];
    DataManager.sharedInstance.retrievedFriends = object[@"nativeFriendsIds"];
}

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@2 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    
    // Invert image coordinates
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
        
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

-(void) getMessages
{
    PFQuery * query1 = [PFQuery queryWithClassName:@"Messages"];
    [[DataManager sharedInstance].messages removeAllObjects];
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
             
             [self stopAnimation];
             UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[self.view viewWithTag:666];
             [tmpimg removeFromSuperview];
             [self.tableViewMainFriendList reloadData];
             
         }
     }];
    
    
}

-(void) startPushAnimation
{
    self.pushActivityIndicator.hidden = NO;
    [self.pushActivityIndicator startAnimating];
    
}

-(void) stopPushAnimation
{
    self.pushActivityIndicator.hidden = YES;
    [self.pushActivityIndicator stopAnimating];
}

-(void) sendGroupShoutOut
{
    [self startPushAnimation];
    self.btnShoutOut.enabled = NO;
    NSString * myname = [PFUser currentUser].username;
    
    NSString * msg = [NSString stringWithFormat:@"%@ sent you a shout out", myname];
    [DataManager sendGroupPushNotification:msg withAudio:DataManager.sharedInstance.selectedGroupShoutOut];
}

-(void) shoutOutSent
{
    [self stopPushAnimation];
    self.btnShoutOut.enabled = YES;
    [self.tableViewMainFriendList reloadData];
}

-(void) setUpTheme
{
    NSString *themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    NSString *titleString;
    if(themeNumber==nil)
    {
        themeId = @"theme1";
    }
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    
    
    titleString = [self generateTitleString:BTN_SETTING];
    [_btnSideMenu setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_BELL];
    [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SEARCH];
    [_btnSearch setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_PULLDOWN];
    [_btnDragDownMenu setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SHOUTOUT];
    [_btnShoutOut setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BG_MAIN];
    _mainScreenBackgroundImgView.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BG_TOP_BAR];
    _navigationBar.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_ADD];
    [_btnAddMenu setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    //WINDING UP
    PFUser * user = [PFUser currentUser];
    user[@"themeId"] = themeNumber;
    [user saveInBackground];
    [[DataManager sharedInstance].defaults setObject:themeNumber forKey:@"themeId"];
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    [[DataManager sharedInstance].defaults synchronize];
    
       

    [self.tableViewMainFriendList reloadData];
    
}

-(NSString*) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return titleString;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self yieldSearchResults:searchBar.text];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self yieldSearchResults:searchBar.text];
    [self dismissKeyboard];
}
-(void) yieldSearchResults: (NSString *)input
{
    if([input length]>2)
    {
        input = [input lowercaseString];
        [searchedEmail removeAllObjects];
        [searchedMessage removeAllObjects];
        [searchedName removeAllObjects];
        [searchedProfilePicture removeAllObjects];
        [searchedTags removeAllObjects];
        for(int i = 0 ; i < [[DataManager sharedInstance].friendsEmailAdresses count];i++)
        {
            NSString * name = [[DataManager sharedInstance].friendsUsernames objectAtIndex:i];
            if ([name rangeOfString:input].location == NSNotFound)
            {
                NSLog(@"%@ does not contain %@",name,input);
            }
            
            else
            {
                if(![searchedName containsObject:[[DataManager sharedInstance].friendsUsernames objectAtIndex:i]])
                {
                    [searchedName addObject:[[DataManager sharedInstance].friendsUsernames objectAtIndex:i]];
                    [searchedMessage addObject:[[DataManager sharedInstance].messages objectAtIndex:i]];
                    [searchedEmail addObject:[[DataManager sharedInstance].friendsEmailAdresses objectAtIndex:i]];
                    [searchedProfilePicture addObject:[[DataManager sharedInstance].friendsProfilePictures objectAtIndex:i]];
                    [searchedTags addObject:[NSString stringWithFormat:@"%i",i]];
                }
                
            }
        }
        if([searchedName count]>0)
        {
            [self.tableViewMainFriendList reloadData];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No matches found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        
    }
    
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
             
             PFQuery * query = [PFQuery queryWithClassName:@"Audio"];
             [query whereKey:@"theme" equalTo:object];
             DataManager.sharedInstance.themeAudios = [NSMutableArray arrayWithArray:[query findObjects]];
             
         }
     }];
}

-(void) reloadData
{
    UIActivityIndicatorView *tmpimg = (UIActivityIndicatorView *)[self.view viewWithTag:666];
    [tmpimg removeFromSuperview];

    [self.tableViewMainFriendList reloadData];
}


-(void) highlightBadge
{
    if([[DataManager sharedInstance].pendingFriendRequests count]>0)
    {
        [DataManager sharedInstance].requestBadge = (int)  [[DataManager sharedInstance].pendingFriendRequests count];
        [DataManager sharedInstance].addRequestReceived = YES;
        self.badgeNotification.text = [NSString stringWithFormat:@"%i", [DataManager sharedInstance].requestBadge ];
        [DataManager sharedInstance].requestBadge = 0;
        NSString *themeNumbero = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
        NSString *titleString = [NSString stringWithFormat:@"theme%@_btn_notification",themeNumbero];
        [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        self.badgeNotification.hidden = NO;
        self.badgeBackgroundView.hidden = NO;
        
    }
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
