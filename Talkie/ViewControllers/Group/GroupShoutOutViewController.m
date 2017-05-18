//
//  GroupShoutOutViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 30/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "GroupShoutOutViewController.h"
#import "GroupShoutOutCollectionViewCell.h"
#import "CustomView.h"

@interface GroupShoutOutViewController ()

@end

@implementation GroupShoutOutViewController
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shoutOutSent)
                                                 name:GROUP_SHOUT_OUT_DONE
                                               object:nil];*/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest1:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];

   if([DataManager.sharedInstance.retrievedFriends count]<1)
   {
       self.btnShoutOut.enabled = NO;
   }
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        //[_btnNotifications setImage:[UIImage imageNamed:@"theme1_main_notification.png"] forState:UIControlStateNormal];
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
       // [_btnNotifications setImage:[UIImage imageNamed:@"theme1_btn_notification.png"] forState:UIControlStateNormal];
    }
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GROUP_SHOUT_OUT_DONE
                                                  object:nil];*/
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEW_FRIEND_REQUEST_NOTIFICATION
                                                  object:nil];
    
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
    
}

-(void) shoutOutAuthorized
{
    DataManager.sharedInstance.selectedGroupShoutOut = self.selectedAudio;
    [_delegate sendGroupShoutOut];
    [self.navigationController popViewControllerAnimated:YES];
}
-(BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    messageIsSelected = NO;
    self.backgroundImageView.image = [UIImage imageNamed:@"theme1_group_bg.png"];
    self.previousView.image = DataManager.sharedInstance.blurredImage;
    [_btnNotifications addTarget:self action:@selector(btnNotificationsTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UINib *nib;
    nib = [UINib nibWithNibName:@"GroupShoutOutCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"myCell"];
    self.frames = [NSArray arrayWithObjects:@"theme1_main_frame_blue.png",@"theme1_main_frame_orange.png",@"theme1_main_frame_yellow.png",@"theme1_main_frame_green.png",@"theme1_main_frame_purple.png",@"theme1_main_frame_firozi.png",@"theme1_main_frame_pink.png",nil];
   // [self.view addSubview:self.lowerBtnRowView];
    NSUInteger totalFriends = [DataManager.sharedInstance.retrievedFriends count];
    if(totalFriends>21)
    {
        NSUInteger remainingFriends = totalFriends-21;
        self.friendsCountLbl.text = [NSString stringWithFormat:@"+%lu Friends", (unsigned long)remainingFriends];
    }
    
    self.indexer = 0;
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    SWRevealViewController *revealController = [self revealViewController];
    
    
    [revealController tapGestureRecognizer];
    [self.btnSideMenu addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    _btnSideMenu.tag = 0;
    
    [self.btnAudio1 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio2 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio3 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnAudio4 addTarget:self action:@selector(btnMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnPlay1 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay2 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay3 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlay4 addTarget:self action:@selector(playSound:) forControlEvents:UIControlEventTouchUpInside];
    
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu",(unsigned long)DataManager.sharedInstance.requestBadge];
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
    
    [self setUpThemes];

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
-(void) shoutOutSent
{
    [self stopAnimation];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //NSString *searchTerm = self.searches[section];
    return [DataManager.sharedInstance.retrievedFriends count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupShoutOutCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    NSString *themeId = [NSString stringWithFormat:@"theme%@",[[DataManager sharedInstance].defaults objectForKey:@"themeId"]];
    NSDictionary *allThemesInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ThemesInfo" ofType:@"plist"]];
    
    [DataManager sharedInstance].themeInfo = [allThemesInfo objectForKey:themeId];
    if([themeId length]==0)
    {
        themeId = @"theme1";
    }
    NSString *imageSymmetry = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if([imageSymmetry isEqualToString:@"rounded_square"])
    {
        cell.profilePicture.layer.cornerRadius = 8.0f;
        cell.profilePicture.clipsToBounds = YES;
    }
    else if([imageSymmetry isEqualToString:@"square"])
    {
        cell.profilePicture.clipsToBounds = YES;
    }
    else if ([imageSymmetry isEqualToString:@"round"])
    {
        cell.profilePicture.layer.cornerRadius = cell.profilePicture.frame.size.width / 2;
        cell.profilePicture.clipsToBounds = YES;
    }
    
    self.indexer = indexPath.row % 7;
    cell.backgroundColor = [UIColor clearColor];
    cell.profilePicture.image = [DataManager.sharedInstance.friendsProfilePictures objectAtIndex:indexPath.row];
    //cell.profilePicture.layer.cornerRadius = 7.0f;
    //cell.profilePicture.clipsToBounds = YES;
    NSString *separatorImage = [[DataManager sharedInstance].themeInfo objectForKey:PROFILE_BORDER];
    separatorImage = [NSString stringWithFormat:@"%@%i",separatorImage,(int)self.indexer];
    cell.imageFrame.image = [UIImage imageNamed:separatorImage];
    self.indexer++;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

-(IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)btnShoutOutTapped:(id)sender
{
    if([self.selectedAudio length]>0)
    {
        
        UINib *nib = [UINib nibWithNibName:@"CustomView" bundle:nil];
        myView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        myView.tag = 101;
        myView.delegate = self;
        [self.view addSubview:myView];
    }
    else{
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Choose an audio message first" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
    }
   
}

-(void) btnMessageTapped: (UIButton *) sender
{
    NSString *titleBarUnselected = [self generateTitleString:GROUP_SEND_BAR_UNSELECTED];
    NSString *titleBarSelected = [self generateTitleString:GROUP_SEND_BAR_SELECTED];
    
    NSString *btnPlaySelected = [self generateTitleString:BTN_SEND_GROUP_SELECTED];
    NSString *btnPlayUnselected = [self generateTitleString:BTN_SEND_GROUP_UNSELECTED];
    
    UIColor *colorUnselect = [self generateColor:COLOR_GROUP_SEND_UNSELECTED];
    UIColor *colorSelect = [self generateColor:COLOR_GROUP_SEND_SELECTED];
    
    NSString *btnSendSelected = [self generateTitleString:BTN_SHOUT_OUT_GROUP_SELECTED];
    NSString *btnSendUnSelected = [self generateTitleString:BTN_SHOUT_OUT_GROUP_UNSELECTED];
    NSArray *audioFiles = [[NSArray alloc] initWithArray:[[DataManager sharedInstance].themeInfo objectForKey:AUDIO_FILE_NAME]];
    if(lastSelectedAudioTag==sender.tag)
    {
        [sender setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
         [self.btnShoutOut setImage:[UIImage imageNamed:btnSendUnSelected] forState:UIControlStateNormal];
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
        [sender setTitleColor:colorUnselect forState:UIControlStateNormal];
    }
    
    
    else if(sender.tag != lastSelectedAudioTag)
    {
        if(sender.tag == 1)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX OTHER FONTS
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            [self.btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            
            //FIX PLAY BUTTONS
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
            [self.btnShoutOut setImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            NSLog(@"Button is %@",self.btnShoutOut);
            
            //sender.tag = 11;
            self.selectedAudio = [audioFiles objectAtIndex:0];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 0;
        }
        
        else if(sender.tag == 2)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX OTHER FONTS
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            [self.btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            
            //FIX PLAY BUTTONS
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
             [self.btnShoutOut setImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            
            //sender.tag = 12;
            self.selectedAudio = [audioFiles objectAtIndex:1];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 1;
        }
        
        else if(sender.tag == 3)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio4 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX OTHER FONTS
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            [self.btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio4 setTitleColor:colorUnselect forState:UIControlStateNormal];
            
            //FIX PLAY BUTTONS
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
             [self.btnShoutOut setImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            NSLog(@"Button is %@",self.btnShoutOut);
            
            //sender.tag = 13;
            self.selectedAudio = [audioFiles objectAtIndex:2];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 2;
        }
        else if(sender.tag == 4)
        {
            [sender setBackgroundImage:[UIImage imageNamed:titleBarSelected] forState:UIControlStateNormal];
            //FIX OTHER BUTTONS
            [self.btnAudio1 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio2 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            [self.btnAudio3 setBackgroundImage:[UIImage imageNamed:titleBarUnselected] forState:UIControlStateNormal];
            //FIX OTHER FONTS
            [sender setTitleColor:colorSelect forState:UIControlStateNormal];
            [self.btnAudio1 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio2 setTitleColor:colorUnselect forState:UIControlStateNormal];
            [self.btnAudio3 setTitleColor:colorUnselect forState:UIControlStateNormal];
            
            //FIX PLAY BUTTONS
            [self.btnPlay4 setBackgroundImage:[UIImage imageNamed:btnPlaySelected] forState:UIControlStateNormal];
            [self.btnPlay1 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay2 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            [self.btnPlay3 setBackgroundImage:[UIImage imageNamed:btnPlayUnselected] forState:UIControlStateNormal];
            
            
             [self.btnShoutOut setImage:[UIImage imageNamed:btnSendSelected] forState:UIControlStateNormal];
            
            
            
            //sender.tag = 14;
            self.selectedAudio = [audioFiles objectAtIndex:3];
            lastSelectedAudioTag = sender.tag;
            DataManager.sharedInstance.selectedAudioIndex = 3;
        }



    }
    
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

- (void)newFriendRequest1:(NSNotification*)_ntf {
    
    self.badgeNotification.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    NSString *themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    NSString *titleString = [NSString stringWithFormat:@"theme%@_btn_notification",themeNumber];

    [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    if([self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = YES;
        
    }
    else if(![self.badgeNotification.text isEqualToString:@"0"])
    {
        self.badgeNotification.hidden = NO;
        
    }
    
}
-(void) setUpThemes
{
    NSString *titleString;
    titleString = [self generateTitleString:BTN_BACK_GROUP];
    [_btnBack setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    NSString * themeCheck = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    if(![themeCheck isEqualToString:@"rounded_square"])
    {
        titleString = [self generateTitleString:BG_GROUP];
        _backgroundImageView.image = [UIImage imageNamed:titleString];
    }
    titleString = [self generateTitleString:BG_TOP_BAR_GROUP];
    _navigationBar.image = [UIImage imageNamed:titleString];
    
    titleString = [self generateTitleString:BTN_BELL];
    [_btnNotifications setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SETTING];
    [_btnSideMenu setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_SHOUT_OUT_GROUP_UNSELECTED];
    [_btnShoutOut setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:BTN_PLAY_UNSELECTED];
    if([[[DataManager sharedInstance].themeInfo objectForKey:@"themename"] isEqualToString:@"Jungle"] || [[[DataManager sharedInstance].themeInfo objectForKey:@"themename"] isEqualToString:@"Irish"])
    {
        titleString = [self generateTitleString:BTN_SEND_GROUP_UNSELECTED];
        
    }

    [_btnPlay1 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay2 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay3 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnPlay4 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    titleString = [self generateTitleString:GROUP_SEND_BAR_UNSELECTED];
    UIColor *color = [self generateColor:COLOR_GROUP_SEND_UNSELECTED];
    
    [_btnAudio1 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio1 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio2 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio2 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio3 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio3 setTitleColor:color forState:UIControlStateNormal];
    
    [_btnAudio4 setBackgroundImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    [_btnAudio4 setTitleColor:color forState:UIControlStateNormal];
    
    [self setTitles];
    
    
}
-(NSString *) generateTitleString: (NSString *) key
{
    NSString *titleString;
    NSString *themeId = [NSString stringWithFormat:@"theme%@",[[DataManager sharedInstance].defaults objectForKey:@"themeId"]];
    NSDictionary *themeInfo = [[NSDictionary alloc] initWithDictionary:[DataManager sharedInstance].themeInfo];
    
    if([themeId length]==0)
    {
        themeId = @"theme1";
        
    }
    titleString = [themeInfo objectForKey:key];
    return titleString;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
