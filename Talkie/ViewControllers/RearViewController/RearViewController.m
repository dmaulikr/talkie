//
//  RearViewController.m
//  Talkie
//
//  Created by Muhammad Jabbar on 11/26/14.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "RearViewController.h"
#import "MoreViewController.h"
#import "EditProfileViewController.h"
#import "TermsOfServicesViewController.h"
@interface RearViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation RearViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) viewWillAppear:(BOOL)animated
{
    [self setUpTheme];
}
-(void) newFriendRequest:(NSNotification*)_ntf
{
    self.badge.text = [NSString stringWithFormat:@"%lu", (long)(unsigned)DataManager.sharedInstance.requestBadge];
    
    self.badge.hidden = NO;
    self.badgeBackground.hidden = NO;
}
-(void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newFriendRequest:)
                                                 name:NEW_FRIEND_REQUEST_NOTIFICATION
                                               object:nil];
    if([self.badge.text isEqualToString: @"0"])
    {
        self.badge.hidden = YES;
        self.badgeBackground.hidden = YES;
    }
    else
    {
        self.badge.hidden = NO;
        self.badgeBackground.hidden = NO;
    }
    /*self.myImageView.image = DataManager.sharedInstance.profilePicture;
    self.myImageView.layer.cornerRadius = 10.0f;
    self.myImageView.clipsToBounds = YES;*/
    //[self setUpTheme];
    
    
    
}

-(void) viewDidDisappear:(BOOL)animated
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
        _scroller.bounces = NO;
        _scroller.backgroundColor = [UIColor clearColor];
        [_scroller setContentSize:contentSize];
    }

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_tableView setBackgroundView:nil];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    
    myDictionary = [[NSMutableDictionary alloc] init];
    
    [self setUpTheme];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma Mark TableView DataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIButton *btnMenuItem;
    
    
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle =  UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        btnMenuItem = [[UIButton alloc] initWithFrame:CGRectMake(10.5, 0, 79, 58.5)];
        NSString *key = [NSString stringWithFormat:@"button%lu",indexPath.row];
        [myDictionary setValue:btnMenuItem forKey:key];
        if((indexPath.row+1) ==1)
        {
            self.myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.5, 1, 39, 39)];//31,-4,39,39
            
        }
        if(indexPath.row ==2)
        {
            self.badge = [[UILabel alloc] initWithFrame:CGRectMake(71.95, 0, 16, 17)];
            [self.badge setFont:[UIFont fontWithName:@"OpenSans-ExtraBold.ttf" size:12]];
            self.badge.textColor = [UIColor whiteColor];
            self.badge.textAlignment = NSTextAlignmentCenter;
            
            self.badge.text = @"0";
            self.badgeBackground = [[UIImageView alloc] initWithFrame:CGRectMake(70.95, 0, 16 , 17)];
            self.badgeBackground.image = [UIImage imageNamed:@"theme1_findfriends_notifications.png"];
        }
            
        [cell addSubview:btnMenuItem];
        [btnMenuItem addTarget:self action:@selector(btnMenuItemTapped:) forControlEvents:UIControlEventTouchUpInside];
        btnMenuItem.tag = indexPath.row;
        
       
	}
    
    if((indexPath.row+1)==1)
    {
        
        NSString *imageShape = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
        
        if([imageShape isEqualToString:@"square"])
        {
            self.myImageView.clipsToBounds = YES;
            _myImageView.layer.cornerRadius = 0.0f;
        }
        else if([imageShape isEqualToString:@"round"])
        {
            self.myImageView.layer.cornerRadius = self.myImageView.frame.size.width / 2;
            self.myImageView.clipsToBounds = YES;
        }
        else if([imageShape isEqualToString:@"rounded_square"])
        {
            self.myImageView.layer.cornerRadius = 10.0f;
            self.myImageView.clipsToBounds = YES;
            
        }
        
        else
        {
            self.myImageView.layer.cornerRadius = 10.0f;
            self.myImageView.clipsToBounds = YES;
        }
        self.myImageView.image = [[DataManager sharedInstance] profilePicture];
        [cell addSubview:self.myImageView];
        
        
    }
    
    NSString *themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    if(themeNumber == nil)
    {
        themeNumber = @"1";
    }
   /* UIView *view = cell.contentView;
    for(id object in view.subviews)
    {
        if([object isKindOfClass:[UIButton class]])
        {
            btnMenuItem = object;
        }
    }*/
    
    /*NSArray *subviews = [cell.contentView subviews];
    
    for(int i = 0; i<[subviews count];i++)
    {
        if([[subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
        {
            btnMenuItem = [subviews objectAtIndex:i];
            NSString *titleString = [NSString stringWithFormat:@"theme%i_slidemenuitem%li.png",[themeNumber intValue],indexPath.row+1];
            NSLog(@"%@",titleString);
            [btnMenuItem setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
        }
    }*/
    
    

    /*for (UIView *v in cell.contentView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *textField = (UITextField *)v;
            [myDictionary setObject:textField.text forKey:indexPath];
            NSLog(@"%@",myDictionary);
        }
    }*/
    NSString *key = [NSString stringWithFormat:@"button%lu",indexPath.row];
    btnMenuItem = [myDictionary objectForKey:key];
    NSString *titleString = [NSString stringWithFormat:@"theme%i_slidemenuitem%li.png",[themeNumber intValue],indexPath.row+1];
    [btnMenuItem setImage:[UIImage imageNamed:titleString] forState:UIControlStateNormal];
    
    return cell;
}

-(void)btnMenuItemTapped:(UIButton*)tappedButton{
    switch (tappedButton.tag)
    {
        case 0:
        {
            EditProfileViewController * editVC = [[EditProfileViewController alloc]init];
            [self.navigationController pushViewController:editVC animated:YES];
        }
            break;
        case 1:
            //change theme
        {
            TermsOfServicesViewController *aboutVC = [[TermsOfServicesViewController alloc] init];
            aboutVC.loadCustomUrl = YES;
            aboutVC.customUrl = TALKIE_NEW_FEATURES_URL_STRING;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
            break;
        case 2:
        {
            
            if(DataManager.sharedInstance.isFbUser == YES)
            {
                
                FBFindFriendsViewController * fbFindFriendsVC = [[FBFindFriendsViewController alloc] init];
                if(![self.badge.text isEqualToString:@"0"])
                {
                    fbFindFriendsVC.selectedSegment = 2;
                    DataManager.sharedInstance.requestBadge = 0;
                }
                [self.navigationController pushViewController:fbFindFriendsVC animated:YES];
            }
            else
            {
            FindFriendsViewController *mangeFriendVC = [[FindFriendsViewController alloc] init];
                if(![self.badge.text isEqualToString:@"0"])
                {
                    mangeFriendVC.selectedSegment = 1;
                    DataManager.sharedInstance.requestBadge = 0;
                }
            [self.navigationController pushViewController:mangeFriendVC animated:YES];
            }
        }

            break;
        case 3:
        {
            FriendsManagementViewController *manageVC = [[FriendsManagementViewController alloc] init];
            [self.navigationController pushViewController:manageVC animated:YES];
        }
            break;
        case 4:
        {
            //about
            TermsOfServicesViewController *aboutVC = [[TermsOfServicesViewController alloc] init];
            aboutVC.loadCustomUrl = YES;
            aboutVC.customUrl = TALKIE_ABOUT_URL_STRING;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
            break;
        case 5:
        {
            //faq
            TermsOfServicesViewController *aboutVC = [[TermsOfServicesViewController alloc] init];
            aboutVC.loadCustomUrl = YES;
            aboutVC.customUrl = TALKIE_FAQ_URL_STRING;
            [self.navigationController pushViewController:aboutVC animated:YES];
        }
            break;
        case 6:
        {
            MoreViewController * moreVC = [[MoreViewController alloc] init];
            [self.navigationController pushViewController:moreVC animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void) setUpTheme
{
    NSString *titleString;
    NSString *themeNumber = [[DataManager sharedInstance].defaults objectForKey:@"themeId"];
    if(themeNumber == nil)
    {
        themeNumber = @"1";
    }
    titleString = [NSString stringWithFormat:@"theme%@_sidemenu_bg",themeNumber];
    _backgroundView.image = [UIImage imageNamed:titleString];
    
    NSString *imageShape = [[DataManager sharedInstance].themeInfo objectForKey:IMAGE_SHAPE];
    
    if([imageShape isEqualToString:@"square"])
    {
        self.myImageView.clipsToBounds = YES;
        _myImageView.layer.cornerRadius = 0.0f;
    }
    else if([imageShape isEqualToString:@"round"])
    {
        self.myImageView.layer.cornerRadius = self.myImageView.frame.size.width / 2;
        self.myImageView.clipsToBounds = YES;
    }
    else if([imageShape isEqualToString:@"rounded_square"])
    {
        self.myImageView.layer.cornerRadius = 10.0f;
        self.myImageView.clipsToBounds = YES;
        
    }
    
    else
    {
        self.myImageView.layer.cornerRadius = 10.0f;
        self.myImageView.clipsToBounds = YES;
        
    }
    self.myImageView.image = DataManager.sharedInstance.profilePicture;
    [_tableView reloadData];
}
@end
