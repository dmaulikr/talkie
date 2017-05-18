//
//  MoreViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 13/12/2014.
//  Copyright (c) 2014 Muhammad Jabbar. All rights reserved.
//

#import "MoreViewController.h"
#import "PrivacyPolicyViewController.h"
#import "TermsOfServicesViewController.h"
#import "AppDelegate.h"
@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpTheme];
}
-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}
- (IBAction)btnPrivacyPolicyTapped:(id)sender
{
    PrivacyPolicyViewController * privacyVC = [[PrivacyPolicyViewController alloc] init];
    [self.navigationController pushViewController:privacyVC animated:YES];
}
- (IBAction)btnTOSTapped:(id)sender
{
    TermsOfServicesViewController * TermsVC = [[TermsOfServicesViewController alloc] init];
    [self.navigationController pushViewController:TermsVC animated:YES];
}
- (IBAction)btnLogoutTapped:(id)sender
{
    DataManager.sharedInstance.user = nil;
    DataManager.sharedInstance.retrievedFriends = [[NSMutableArray alloc] init];
    
    
    DataManager.sharedInstance.friendsUsernames = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.friendsProfilePictures removeAllObjects];
    DataManager.sharedInstance.friendsProfilePictures = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.friendsEmailAdresses removeAllObjects];
    DataManager.sharedInstance.friendsEmailAdresses = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.pendingFriendRequests removeAllObjects];
    DataManager.sharedInstance.pendingFriendRequests = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.reqSenderNames removeAllObjects];
    DataManager.sharedInstance.reqSenderNames = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.reqSenderEmails removeAllObjects];
    DataManager.sharedInstance.reqSenderEmails = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.reqSenderProfilePictures removeAllObjects];
    DataManager.sharedInstance.reqSenderProfilePictures = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.blockedContacts removeAllObjects];
    DataManager.sharedInstance.blockedContacts = [[NSMutableArray alloc]init];
    
    
    DataManager.sharedInstance.foundUsers = [[NSArray alloc] init];
    DataManager.sharedInstance.requestBadge = 0;
    DataManager.sharedInstance.userDidReadTheNotification = NO;
    DataManager.sharedInstance.addRequestReceived = NO;
    
    [DataManager.sharedInstance.sentRequests removeAllObjects];
    DataManager.sharedInstance.sentRequests = [[NSMutableArray alloc] init];
    
    DataManager.sharedInstance.isFbUser = NO;
    DataManager.sharedInstance.suggestedFbFriends = [[NSArray alloc] init];
    
    [DataManager.sharedInstance.fbFriends removeAllObjects];
    DataManager.sharedInstance.fbFriends = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.suggestedFriendsEmails removeAllObjects];
    DataManager.sharedInstance.suggestedFriendsEmails = [[NSMutableArray alloc] init];
    
    [ DataManager.sharedInstance.suggestedFriendsProfilePics removeAllObjects];
    DataManager.sharedInstance.suggestedFriendsProfilePics = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.suggestedFriendsUsernames removeAllObjects];
    DataManager.sharedInstance.suggestedFriendsUsernames = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.selectedContacts removeAllObjects];
    DataManager.sharedInstance.selectedContacts = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.themeAudios removeAllObjects];
    DataManager.sharedInstance.themeAudios = [[NSMutableArray alloc] init];
    
    [DataManager.sharedInstance.themeSpecs removeAllObjects];
    DataManager.sharedInstance.themeSpecs = [[NSMutableArray alloc]init];
    
    [DataManager.sharedInstance.messages removeAllObjects];
    DataManager.sharedInstance.messages = [[NSMutableArray alloc]init];
    DataManager.sharedInstance.groupShoutOutAuthorized = NO;
    
    [DataManager.sharedInstance.suggestedHideBtnFlags removeAllObjects];
    DataManager.sharedInstance.suggestedHideBtnFlags = [[NSMutableArray alloc] init];
    
    [PFUser logOut];
    LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    //AppDelegate *app = [[UIApplication sharedApplication] delegate];
    //app.window.rootViewController = login;
    NSMutableArray *viewControllers = [[NSMutableArray alloc] initWithArray:[self.navigationController viewControllers]];
    [viewControllers replaceObjectAtIndex:0 withObject:login];
    self.navigationController.viewControllers = viewControllers;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) prefersStatusBarHidden
{
    return YES;
}
-(void) setUpTheme
{
    _navigationBar.image = [UIImage imageNamed:[self generateTitleString:BG_TOP_BAR]];
    [_btnBack setImage:[UIImage imageNamed:[self generateTitleString:BTN_BACK]] forState:UIControlStateNormal];
}
-(NSString *) generateTitleString: (NSString *) key
{
    NSString *titleString = [[DataManager sharedInstance].themeInfo objectForKey:key];
    return titleString;
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
