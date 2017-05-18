//
//  LoginWithEmailViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "EmailLoginViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface EmailLoginViewController () <UITextFieldDelegate,SWRevealViewControllerDelegate>
{
    
    
    __weak IBOutlet TPKeyboardAvoidingScrollView *scrollView;
}


@end

@implementation EmailLoginViewController
-(void) viewWillAppear:(BOOL)animated
{
[[self navigationController] setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void) viewDidLayoutSubviews
{
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }
    else
    {
        CGSize contentSize = CGSizeMake(320, 568);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //[scrollView contentSizeToFit];
    [self.view addSubview:scrollView];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.btnLoginWithEmail.enabled = NO;
    self.usernameOrEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self.usernameOrEmailTextField addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventAllEditingEvents];
    [self.passwordTextField addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventAllEditingEvents];
    self.usernameOrEmailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    UIColor *color = [UIColor whiteColor];
    NSString * userNamePlaceHolder = @"USERNAME OR EMAIL";
    self.usernameOrEmailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: userNamePlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
    NSString * passwordPlaceHolder = @"PASSWORD";
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString: passwordPlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
   
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btnBackTapped:(id)sender
{

    LoginViewController * loginVC = [self.navigationController.viewControllers objectAtIndex:0];
    loginVC.emojiImageView.image = [UIImage imageNamed:@"talkie.png"];
    [self.navigationController popViewControllerAnimated:YES];

    
}

-(IBAction)btnLoginTapped:(id)sender
{
    
    [self startAnimation];
    self.btnLoginWithEmail.enabled = NO;
    NSString *userName = self.usernameOrEmailTextField.text;
    userName = [userName lowercaseString];
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *emailIdentifier = @"@";
    [self startAnimation];
    if ([userName rangeOfString:emailIdentifier].location != NSNotFound) {
    //"username" contains the email identifier @, therefore this is an email. Pull down the username.
    PFQuery *query = [PFUser query];
    [query whereKey:@"email" equalTo:userName];
        _usernameOrEmailTextField.userInteractionEnabled = NO;
        _passwordTextField.userInteractionEnabled = NO;
        NSArray *foundUsers = [query findObjects];
        
        if([foundUsers count]  == 1)
        {
            for (PFUser *foundUser in foundUsers)
            {
                userName = [foundUser username];
                
            }
        }
    }
    [PFUser logInWithUsernameInBackground:userName password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user)
        {
            DataManager.sharedInstance.user = [PFUser currentUser];
            
            PFInstallation * myInstallation = [PFInstallation currentInstallation];
            myInstallation[@"userId"] = user.objectId;
            [myInstallation saveInBackground];
            PFFile * imageFile = [DataManager.sharedInstance.user objectForKey:@"profilePicture"];
            NSData *imageData = [imageFile getData];
            DataManager.sharedInstance.profilePicture = [UIImage imageWithData:imageData];
            DataManager.sharedInstance.myName = userName;
            
           [DataManager.sharedInstance.defaults setObject:user[@"themeId"] forKey:@"themeId"];
            [self getFriendList];
            
        }
        else {
            //Something bad has ocurred
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            self.btnLoginWithEmail.enabled = YES;
            _passwordTextField.userInteractionEnabled = YES;
            _usernameOrEmailTextField.userInteractionEnabled = YES;
            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [self stopAnimation];
            [errorAlertView show];
            
            
        }
    }];

}

-(IBAction)btnResetPasswordTapped:(id)sender
{

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Reset Password" message:@"Please enter your email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeEmailAddress;
    alertTextField.placeholder = @"abc@example.com";
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString * emailAddress = [[alertView textFieldAtIndex:0] text];
    [emailAddress lowercaseString];
    BOOL  foundEmail = NO;
    [self startAnimation];
    PFQuery *query = [PFUser query];
    NSString * targetId;
    [query whereKey:@"email" equalTo:emailAddress];
    NSArray *foundUsers = [query findObjects];
    if([foundUsers count]  == 1)
    {
        for (PFUser *foundUser in foundUsers)
        {
            targetId = [foundUser objectId];
            foundEmail = YES;
        }
    }
    if(foundEmail == YES)
    {
        PFQuery *query = [PFUser query];
        
        [query getObjectInBackgroundWithId:targetId block:^(PFObject *username, NSError *error)
         {
             [PFUser requestPasswordResetForEmailInBackground:emailAddress];
             NSLog(@"RequestSent");
             UIAlertView *successAlertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Password Reset request sent" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
             [self stopAnimation];
             [successAlertView show];
             
         }];
    }
    else{
        NSLog(@"Email address is not registered");
        UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Email is invalid or unregistered" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [errorAlertView show];
        [self stopAnimation];
    }
    
}


- (void) getFriendList
{
    PFQuery * query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * username, NSError * error)
     {
         DataManager.sharedInstance.retrievedFriends = username[@"nativeFriendsIds"];
         DataManager.sharedInstance.pendingFriendRequests = username[@"pendingRequests"];
         DataManager.sharedInstance.blockedContacts = username[@"blockedContacts"];
         if([DataManager.sharedInstance.retrievedFriends count]>0)
         {
             [self getFriendsUsernames];
         }
         [self getPendingRequests];
         if([DataManager.sharedInstance.pendingFriendRequests count]>0)
         {
             [self getRequestSendersProfile];
         }
         
         if([DataManager.sharedInstance.blockedContacts count]>0)
         {
             [self getBlockedContactsProfile];
         }
         
         PFUser * user = [PFUser currentUser];
         NSString * themeId = user[@"themeId"];
         //TESTING
         [self getThemeData:themeId];
         
     }];
}
-(void) getBlockedContactsProfile
{
    PFQuery *query = [PFUser query];
    NSUInteger friendsCount = [DataManager.sharedInstance.blockedContacts count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.blockedContacts[i]];
        [DataManager.sharedInstance.blockedNames addObject:username[@"username"]];
        [DataManager.sharedInstance.blockedEmails addObject:username[@"email"]];
        //imageFile = [username objectForKey:@"profilePicture"];
        //NSData *imageData = [imageFile getData];
        //UIImage *imageFromData = [UIImage imageWithData:imageData];
        [DataManager.sharedInstance.blockedPictures addObject:[UIImage imageNamed:@"dummyImage.png"]];
        
    }

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

-(void)callbackWithResult:(NSData *)result error:(NSError *)error
{
    if (!error) {
        UIImage * profilePictureData = [UIImage imageWithData:result];
        [DataManager.sharedInstance.friendsProfilePictures addObject:profilePictureData];
    }
}
-(void) getFriendsUsernames
{
    PFQuery *query = [PFUser query];
    
    NSUInteger friendsCount = [DataManager.sharedInstance.retrievedFriends count];
    for(int i = 0; i<friendsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.retrievedFriends[i]];
        if(username!=nil)
        {
            [DataManager.sharedInstance.friendsUsernames addObject:username[@"username"]];
            [DataManager.sharedInstance.friendsEmailAdresses addObject:username[@"email"]];
            //imageFile = [username objectForKey:@"profilePicture"];
            //NSData *imageData = [imageFile getData];
            //UIImage *imageFromData = [UIImage imageWithData:imageData];
            //[DataManager.sharedInstance.friendsProfilePictures addObject:imageFromData];
            UIImage *imageNamed = [UIImage imageNamed:@"dummyImage"];
            [DataManager.sharedInstance.friendsProfilePictures addObject:imageNamed];
        }
        
        
        else
        {
            NSLog(@"%@", [[DataManager sharedInstance].retrievedFriends objectAtIndex:i]);
            [[DataManager sharedInstance].retrievedFriends removeObjectAtIndex:i];
            
            [[DataManager sharedInstance].friendsUsernames removeAllObjects];
            [[DataManager sharedInstance].friendsEmailAdresses removeAllObjects];
            [[DataManager sharedInstance].friendsProfilePictures removeAllObjects];
            PFQuery * query = [PFQuery queryWithClassName:@"Social"];
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            PFObject *objectToUpdate = [query getFirstObject];
            objectToUpdate[NATIVE_FRIENDS] = [DataManager sharedInstance].retrievedFriends;
            [objectToUpdate save];
            friendsCount--;
            i=0;
            i--;
            NSLog(@"%i",i);
            
            
        }
       
        
    }
    
    
}

-(void) getPendingRequests
{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Social"];
    [query whereKey:@"user" equalTo:user];
    PFObject * object = [query getFirstObject];
    DataManager.sharedInstance.pendingFriendRequests= object[@"pendingRequests"];
    
}

-(void) getRequestSendersProfile
{ PFQuery *query = [PFUser query];
    PFFile * imageFile;
    NSUInteger requestsCount = [DataManager.sharedInstance.pendingFriendRequests count];
    for(int i = 0; i<requestsCount;i++)
    {
        PFObject * username =  [query getObjectWithId:DataManager.sharedInstance.pendingFriendRequests[i]];
        [DataManager.sharedInstance.reqSenderNames addObject:username[@"username"]];
        [DataManager.sharedInstance.reqSenderEmails addObject:username[@"email"]];
        
        imageFile = [username objectForKey:@"profilePicture"];
        if(imageFile!=nil)
        {
            //NSData *imageData = [imageFile getData];
            //UIImage *imageFromData = [UIImage imageWithData:imageData];
            [DataManager.sharedInstance.reqSenderProfilePictures addObject:[UIImage imageNamed:@"dummyImage.png"]];
        }
        else {[DataManager.sharedInstance.reqSenderProfilePictures addObject:[UIImage imageNamed:@"dummyImage.png"]];}
    }
}




-(void) formValidation
{
    
    NSString *stricterFilterString = @"[A-Z0-9a-z]*";
    validUserName = NO;
    NSString * lowerString = [self.usernameOrEmailTextField.text lowercaseString];
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString * trimmedString = [lowerString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(![usernameTest evaluateWithObject:trimmedString])
    {
        validUserName = NO;
        
    }
    if([emailPredicate evaluateWithObject:trimmedString])
    {
        validUserName = YES;
    }
    if([usernameTest evaluateWithObject:trimmedString])
    {
        validUserName = YES;
    }
    if(self.usernameOrEmailTextField.text.length >2 && self.passwordTextField.text.length>7)
    {
        if(validUserName == YES)
        {
        self.btnLoginWithEmail.enabled = YES;
        }
    }
    if(self.usernameOrEmailTextField.text.length<1 || self.passwordTextField.text.length<7 ||validUserName == NO)
    {
        self.btnLoginWithEmail.enabled = NO;
    }
}


- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text length] == 0){
        return NO;
    }
    return YES;
}


-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }
    else
    {
        CGSize contentSize = CGSizeMake(320, 568);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }

    return YES;
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self warningsGenerator];
    if(self.view.frame.size.height<568)
    {
        CGSize contentSize = CGSizeMake(320, 655);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }
    else
    {
        CGSize contentSize = CGSizeMake(320, 568);
        scrollView.contentSize = contentSize;
        scrollView.bounces = NO;
    }

    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.btnLoginWithEmail.enabled = NO;
    self.warningLabel.text = @"";
    [scrollView contentSizeToFit];
    scrollView.bounces = YES;
    return YES;
}

-(void) warningsGenerator
{
    NSString *stricterFilterString = @"[A-Z0-9a-z]*";
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString * lowerString = [self.usernameOrEmailTextField.text lowercaseString];
    NSString * trimmedString = [lowerString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(self.passwordTextField.text.length<1 || self.passwordTextField.text.length>7 ||self.usernameOrEmailTextField.text.length<3)
    {
        if(![usernameTest evaluateWithObject:trimmedString])
        {
            self.warningLabel.text = @"Please enter a valid username/email";
            //self.btnLoginWithEmail.enabled = NO;
            validUserName = NO;
            if([emailPredicate evaluateWithObject:trimmedString])
            {
                self.warningLabel.text=@"";
                validUserName = YES;
            }
        }
        if(self.usernameOrEmailTextField.text.length<3)
        {
            self.warningLabel.text = @"Please enter at least 3 characters";
            self.btnLoginWithEmail.enabled = NO;
            validUserName = NO;
        }
       
    }
    else if(self.passwordTextField.text.length<8 && self.usernameOrEmailTextField.text.length>2)
    {
        self.warningLabel.text = @"Please enter at least 8 characters";
        self.btnLoginWithEmail.enabled = NO;
    }

}


-(void) dismissKeyboard
{
    [self.usernameOrEmailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void) getThemeData: (NSString *) themeId
{
    PFQuery * query  = [PFQuery queryWithClassName:@"Theme"];
    
    [query whereKey:@"themeId" equalTo:themeId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError * error)
    {
        if(!error)
        {
            [DataManager.sharedInstance.themeSpecs addObject:object[@"mainBackground"]];
            [DataManager.sharedInstance.themeSpecs addObject:object[@"shoutOutBackground"]];
            
            [self getMessages];
           
            
            
        }
    }];
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
                             //CHAIPI
                             if(audioId!=nil)
                             {
                                 [[DataManager sharedInstance].messages addObject:audioId];
                             }
                             else
                             {
                                 [[DataManager sharedInstance].messages addObject:@" "];
                             }
                             //CHAIPI END
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
             
             MainScreenViewController * frontViewController = [[MainScreenViewController alloc] init];
             RearViewController *rearViewController = [[RearViewController alloc] init];
             
             SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
             revealController.delegate = self;
             revealController.rearViewRevealWidth = 101;
             
             
             [self.navigationController pushViewController:revealController animated:YES];
         }
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


#pragma Mark RevealViewController Delegate Methods
- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeftSideMostRemoved ) str = @"FrontViewPositionLeftSideMostRemoved";
    if ( position == FrontViewPositionLeftSideMost) str = @"FrontViewPositionLeftSideMost";
    if ( position == FrontViewPositionLeftSide) str = @"FrontViewPositionLeftSide";
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}


- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
   // NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
   // NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position
{
   // NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController;
{
   // NSLog( @"%@", NSStringFromSelector(_cmd) );
}

- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController;
{
  //  NSLog( @"%@", NSStringFromSelector(_cmd) );
}

- (void)revealController:(SWRevealViewController *)revealController panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress
{
   // NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}

- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress
{
   // NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}

- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress
{
   // NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}


@end
