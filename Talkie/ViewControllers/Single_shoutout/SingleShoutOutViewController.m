//
//  SingleShoutOutViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 09/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "SingleShoutOutViewController.h"

@interface SingleShoutOutViewController ()

@end

@implementation SingleShoutOutViewController
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    //self.backgroundView.image = [UIImage imageNamed:[DataManager.sharedInstance.themeSpecs objectAtIndex:1]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest2:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        //[_btnNotifications setImage:[UIImage imageNamed:@"theme1_main_notification.png"] forState:UIControlStateNormal];
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
        //[_btnNotifications setImage:[UIImage imageNamed:@"theme1_btn_notification.png"] forState:UIControlStateNormal];
    }
    
    NSString *themeId = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    if([themeId isEqualToString:@"2"])
    {
        self.friendProfilePicture.clipsToBounds = YES;
    }
    else if([themeId isEqualToString:@"3"])
    {
        self.friendProfilePicture.layer.cornerRadius = self.friendProfilePicture.frame.size.width / 2;
        self.friendProfilePicture.clipsToBounds = YES;
    }
    else
    {
        self.friendProfilePicture.layer.cornerRadius = 9.0f;
        self.friendProfilePicture.clipsToBounds = YES;
        
    }


}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_FRIEND_REQUEST_NOTIFICATION
                                                  object:nil];
}
-(void) viewDidLayoutSubviews
{
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        self.scroller.bounces = NO;
        self.scroller.backgroundColor = [UIColor clearColor];
        [self.scroller setContentSize:contentSize];
    }
    
}

-(void) setTitles
{
    //SET TITLES OF audio FROM PLIST
    
    NSArray *audioMessages = [[NSArray alloc] initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
    NSString * upperString;
    
    for (int i = 0; i < [audioMessages count];i++)
    {
        upperString = [NSString stringWithFormat:@"    %@",[audioMessages objectAtIndex:i]];
        if(i == 0)
        {
            [self.btnAudio1 setTitle:upperString forState:UIControlStateNormal];
        }
        if(i == 1)
        {
            [self.btnAudio2 setTitle:upperString forState:UIControlStateNormal];
        }
        if( i == 2)
        {
            [self.btnAudio3 setTitle:upperString forState:UIControlStateNormal];
        }
        if(i == 3)
        {
            [self.btnAudio4 setTitle:upperString forState:UIControlStateNormal];
        }
    }
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //[self.view addSubview:self.lowerBtnView];
    btnDragDownMenu = [[UIButton alloc] initWithFrame:CGRectMake(136.0, 25.0, 48, 52.5)];
    [btnDragDownMenu setBackgroundImage:[UIImage imageNamed:@"theme1_main_logo_button.png"] forState:UIControlStateNormal];
    [btnDragDownMenu addTarget:self action:@selector(showDropDownMenu:) forControlEvents:UIControlEventTouchUpInside];
    [_btnDragDownHandle addTarget:self action:@selector(showDropDownMenu:) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:btnDragDownMenu];
    [self.btnPlay1 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay2 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay3 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay4 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio1 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio2 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio3 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio4 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    NSString * targetName = [[DataManager.sharedInstance.friendsUsernames objectAtIndex:self.indexOfUser] uppercaseString];
    //self.friendProfilePicture.layer.cornerRadius = 9.0f;
    //self.friendProfilePicture.clipsToBounds = YES;
    self.friendProfilePicture.image = [DataManager.sharedInstance.friendsProfilePictures objectAtIndex:self.indexOfUser];
    self.lblName.text = targetName;
    [_btnNotifications addTarget:self action:@selector(btnNotificationsTapped) forControlEvents:UIControlEventTouchUpInside];
    SWRevealViewController *revealController = [self revealViewController];
    
    
    [revealController tapGestureRecognizer];
    [self.btnSideMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    _btnSideMenu.tag = 0;
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    //self.backgroundView.image = [UIImage imageNamed:[DataManager.sharedInstance.themeSpecs objectAtIndex:1]];
    //[self setTitles];
    
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu",(unsigned long)DataManager.sharedInstance.requestBadge];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        [_btnNotifications setImage:[UIImage imageNamed:@"theme1_main_notification.png"] forState:UIControlStateNormal];
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
        [_btnNotifications setImage:[UIImage imageNamed:@"theme1_btn_notification.png"] forState:UIControlStateNormal];
    }
   
    themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    [self setUpTheme];
    menuView = [[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:nil options:nil][0];

    menuView.delegate = self;
    
}

-(void) btnNotificationsTapped
{
    if(![_badgeNotification.text isEqualToString:@"0"])
    {
        [_btnNotifications setImage:[UIImage imageNamed:@"theme1_main_notification.png"] forState:UIControlStateNormal];
        self.badgeNotification.text = @"0";
        DataManager.sharedInstance.requestBadge = 0;
        if(DataManager.sharedInstance.isFbUser == NO)
        {
            FindFriendsViewController *addFriendsScreen = [[FindFriendsViewController alloc] init];
            addFriendsScreen.selectedSegment = 0;
            [self.navigationController pushViewController:addFriendsScreen animated:YES];
            if(DataManager.sharedInstance.addRequestReceived == YES)
            {
                addFriendsScreen.selectedSegment = 1;
                DataManager.sharedInstance.addRequestReceived = NO;
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


-(void) navigateBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL) prefersStatusBarHidden
{
    return YES;
}

-(void) playSound: (UIButton *) sender
{
    NSString *audioPath;
    NSArray *fileNames = [[NSArray alloc] initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:AUDIO_FILE_NAME]];

    audioPath = [[NSBundle mainBundle] pathForResource:[fileNames objectAtIndex:(sender.tag-1)] ofType:@"mp3" ];
    NSArray* foo = [[fileNames objectAtIndex:(sender.tag-1)] componentsSeparatedByString: @"."];
    NSString * bar = [foo objectAtIndex:0];
    audioPath = [[NSBundle mainBundle] pathForResource:bar ofType:@"mp3" ];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&error];
    [self.audioPlayer play];
}
-(IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) btnMessageTapped: (UIButton *) sender
{
    NSString * btnSendUnselected = [self generateTitleString:BTN_SEND_SINGLE_UNSELECTED];
    NSString *btnSendSelected = [self generateTitleString:BTN_SEND_SINGLE_SELECTED];
    NSString *titleBarSelected = [self generateTitleString:BTN_AUDIO_BAR_SELECTED];
    NSString *titleBarUnselected = [self generateTitleString:BTN_AUDIO_BAR_UNSELECTED_SINGLE];
    NSString *btnPlaySelected = [self generateTitleString:BTN_PLAY_SELECTED];
    NSString *btnPlayUnselected = [self generateTitleString:BTN_PLAY_UNSELECTED];
    UIColor *colorUnselect = [self generateColor:COLOR_SINGLE_SEND_UNSELECTED];
    UIColor *colorSelect = [self generateColor:COLOR_SINGLE_SEND_SELECTED];
    NSArray *audioFileName = [[NSArray alloc] initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:AUDIO_FILE_NAME]];
    if(lastSelectedAudioTag==sender.tag)
    {
        [sender setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
        [sender setTitleColor:colorUnselect forState:UIControlStateNormal];
        [self.btnSendPush setBackgroundImage:[UIImage imageNamed:btnSendUnselected] forState:UIControlStateNormal];
        if(sender.tag == 1)
        {
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
        }
        else if (sender.tag ==2)
        {
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
        }
        else if(sender.tag == 3)
        {
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
        }
        else if(sender.tag == 4)
        {
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
        }
        self.selectedAudio = @"";
        lastSelectedAudioTag = 5;
    }
    
    
    else if(sender.tag != lastSelectedAudioTag)
    {
        if(sender.tag == 1)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX PLAY BUTTONS
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
            [self.btnSendPush setBackgroundImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            [_btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            //sender.tag = 11;
            self.selectedAudio = [audioFileName objectAtIndex:0];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 0;
        }
        
        else if(sender.tag == 2)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX PLAY BUTTONS
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
            [self.btnSendPush setBackgroundImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            [_btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            //sender.tag = 12;
            self.selectedAudio = [audioFileName objectAtIndex:1];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 1;
        }
        
        else if(sender.tag == 3)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX PLAY BUTTONS
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
            [self.btnSendPush setBackgroundImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            [_btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            //sender.tag = 13;
            self.selectedAudio = [audioFileName objectAtIndex:2];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 2;
        }
        else if(sender.tag == 4)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
           
            
            //FIX PLAY BUTTONS
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
            [self.btnSendPush setBackgroundImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            [_btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [_btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            //sender.tag = 14;
            self.selectedAudio = [audioFileName objectAtIndex:3];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 3;
        }
        
        
        
    }

}
-(IBAction)sendPush:(id)sender
{
    if([self.selectedAudio length]>0)
    {
        [self startAnimation];
        NSString * targetId = [self.lblName.text lowercaseString];
        NSString * targetUsername = targetId;
        PFQuery * userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:targetId];
        PFObject * target = [userQuery getFirstObject];
        targetId = target.objectId;
        [self verifyPushStatus];
        //[self setUpMainScreen];
        
        if([DataManager.sharedInstance.retrievedFriends containsObject: targetId])
        {
            NSString * message = [NSString stringWithFormat:@"%@ sent a shout out to %@", [PFUser currentUser].username, targetUsername];
            [DataManager sendPushNotification:targetId withMessage:message andAudio:self.selectedAudio];
            NSArray *audioMessages = [[NSArray alloc] initWithArray: [[DataManager sharedInstance].themeInfo objectForKey:AUDIO_MESSAGES]];
            [DataManager.sharedInstance.messages replaceObjectAtIndex:self.indexOfUser withObject:[audioMessages objectAtIndex:(lastSelectedAudioTag - 1)]];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            if([DataManager.sharedInstance.suggestedFriendsUsernames containsObject:[DataManager.sharedInstance.friendsUsernames objectAtIndex:self.indexOfUser]])
            {
                for(int i = 0;i<[DataManager.sharedInstance.suggestedFriendsUsernames count];i++)
                {
                    if([DataManager.sharedInstance.suggestedFriendsUsernames[i] isEqualToString:[DataManager.sharedInstance.friendsUsernames objectAtIndex:self.indexOfUser]])
                    {
                        [DataManager.sharedInstance.suggestedHideBtnFlags replaceObjectAtIndex:i withObject:@"0"];
                        break;
                    }
                }
            }
            [DataManager.sharedInstance.friendsProfilePictures removeObjectAtIndex:self.indexOfUser];
            [DataManager.sharedInstance.friendsUsernames removeObjectAtIndex:self.indexOfUser];
            [DataManager.sharedInstance.friendsEmailAdresses removeObjectAtIndex:self.indexOfUser];
            [DataManager.sharedInstance.messages removeObjectAtIndex:self.indexOfUser];
            
            NSString * alertString = @"Target user has deleted you";
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [errorAlertView show];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
        
        //[self.tableViewMainFriendList reloadData];
        [self stopAnimation];
        NSLog(@"push sent");
        
    }
    else
    {
        NSString * alertString = @"Please select an audio to send";
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:alertString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];

    }
    
}

-(void) verifyPushStatus
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    PFObject * object = [query getFirstObject];
    DataManager.sharedInstance.retrievedFriends = object[@"nativeFriendsIds"];
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

- (void)newFriendRequest2:(NSNotification*)_ntf {
    
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    NSString *themeNumber2 = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    NSString *titleString = [NSString stringWithFormat:@"theme%@_btn_notification",themeNumber2];

    [self.btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
        
    }
    
}

-(void) setUpTheme
{
    
    NSString *themeId = [NSString stringWithFormat:@"theme%@",themeNumber];
    if(themeNumber==nil)
    {
        themeId = @"theme1";
    }
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    NSString *titleString;
    titleString = [self generateTitleString:BG_SINGLE];
    _backgroundView.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_BACK_SINGLE];
    [_btnBack setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BG_TOP_BAR_SINGLE];
    _navigationBar.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:PROFILE_BORDER_SINGLE];
    _frame.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_BELL];
    [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SETTING];
    [_btnSideMenu setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_PULL_DOWN_SINGLE];
    [btnDragDownMenu setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnDragDownHandle setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:PROFILE_SEPARATORSINGLE];
    _seperatorLine.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BG_HALF_CIRCLE_SINGLE];
    _halfCircle.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_PLAY_UNSELECTED];
    [_btnPlay1 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay2 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay3 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay4 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SEND_SINGLE_UNSELECTED];
    [_btnSendPush setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_AUDIO_BAR_UNSELECTED_SINGLE];
    UIColor *color = [self generateColor:COLOR_SINGLE_SEND_UNSELECTED];
    
    [_btnAudio1 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio1 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio2 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio2 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio3 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio3 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio4 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio4 setTitleColor:color forState:UIControlStateNormal];
    
    NSString *imageShape = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([imageShape isEqualToString:@"square"])
    {
        self.friendProfilePicture.clipsToBounds = YES;
        _friendProfilePicture.layer.cornerRadius = 0.0;
    }
    else if([imageShape isEqualToString:@"round"])
    {
        self.friendProfilePicture.layer.cornerRadius = self.friendProfilePicture.frame.size.width / 2;
        self.friendProfilePicture.clipsToBounds = YES;
    }
    else
    {
        self.friendProfilePicture.layer.cornerRadius = 9.0f;
        self.friendProfilePicture.clipsToBounds = YES;
        
    }

    PFUser * user = [PFUser currentUser];
    user[@"themeId"] = themeNumber;
    [user saveInBackground];
    [[DataManager sharedInstance].defaults setObject:themeNumber forKey:@"themeId"];
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    [[DataManager sharedInstance].defaults synchronize];
    [self setTitles];
}

-(NSString*) generateTitleString: (NSString*) key
{
    NSString *titleString;
    titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return titleString;
}

-(void) themeSelected: (NSIndexPath *) indexPath
{
    NSLog(@"%ld",(long)indexPath.item);
    themeNumber = [NSString stringWithFormat:@"%lu",(indexPath.row+1)];
    [self setUpTheme];
}

-(UIColor *) generateColor: (NSString *)key
{
    NSArray *rbgUnselected = [[NSArray alloc] initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:key]];
    float r = [[rbgUnselected objectAtIndex:0] floatValue];
    float g = [[rbgUnselected objectAtIndex:1] floatValue];
    float b = [[rbgUnselected objectAtIndex:2] floatValue];
    
    UIColor *color = [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0];
    return color;
    
}

-(void) showDropDownMenu: (UIButton *) sender
{
    //btnDragDownMenu.hidden = YES;
    _btnDragDownHandle.hidden = YES;
    [self.view addSubview:menuView];
    [menuView.hideButton addTarget:self action:@selector(hideMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    [menuView adjustHeightWithSingleCellHeight:100 numberOfCells:[allThemesInfo count]];
    menuView.delegate = self;
    CGRect btnFrame = btnDragDownMenu.frame;
    __block CGRect menuFrame = menuView.frame;
    
    CGFloat menuBtnEndPosition = btnFrame.origin.y + btnFrame.size.height;
    menuFrame.origin.y = menuBtnEndPosition - menuFrame.size.height;
    menuView.startingYAxis = menuFrame.origin.y;
    menuView.frame = menuFrame;
    menuView.hidden = NO;
    menuFrame.origin.y = 0; // Intended Position
    
    //[self.view bringSubviewToFront:menuView];
    
    menuView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25 animations:^{
        menuView.frame = menuFrame;
    } completion:^(BOOL finished) {
        menuView.open  = YES;
        btnDragDownMenu.hidden = NO;
        menuView.userInteractionEnabled = YES;
    }];
    
}
- (void)hideMenu:(id)sender {
    
    menuView.userInteractionEnabled = NO;
    
    CGRect btnFrame = btnDragDownMenu.frame;
    __block CGRect menuFrame = menuView.frame;
    
    CGFloat menuBtnEndPosition = btnFrame.origin.y + btnFrame.size.height;
    menuFrame.origin.y = menuBtnEndPosition - menuFrame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        menuView.frame = menuFrame;
        
    } completion:^(BOOL finished) {
        menuView.open = NO;
        menuView.hidden = YES;
        //btnDragDownMenu.hidden = NO;
        _btnDragDownHandle.hidden = NO;
        menuView.userInteractionEnabled = YES;
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
