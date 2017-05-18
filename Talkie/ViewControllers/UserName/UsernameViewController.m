//
//  UserNameSettingViewController.m
//  Talkie
//
//  Created by sajjad mahmood on 30/10/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//

#import "UsernameViewController.h"
#import "FBFindFriendsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


@interface UsernameViewController ()<UITextFieldDelegate>

@end

@implementation UsernameViewController

-(void) viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    profilePictureChosen = NO;
    validUsername = NO;
    self.activityIndicator.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;
    self.usernameInput.delegate = self;
    
    self.btnCompleteProfile.enabled = NO;
    [self.usernameInput addTarget:self action:@selector(formValidation) forControlEvents:UIControlEventEditingDidEnd];
    self.usernameInput.delegate = self;
    self.usernameInput.autocorrectionType = UITextAutocorrectionTypeNo;
    UIColor * color = [UIColor whiteColor];
    NSString * usernamePlaceHolder = @"USERNAME";
    self.usernameInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString: usernamePlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
    self.profilePictureFrame.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo
{
    [picker dismissModalViewControllerAnimated:YES];
    CGSize size = CGSizeMake(150, 150);
    UIImage * thumbNail = img;
    thumbNail = [self scaleImgOld:img convertToSize:size];
    imageData = UIImageJPEGRepresentation(thumbNail, 0.05f);
    [self.uploadBtn setBackgroundImage:thumbNail forState:UIControlStateNormal];
    self.profilePictureFrame.hidden = NO;
    self.uploadBtn.layer.cornerRadius = 11.5f;
    self.uploadBtn.clipsToBounds = YES;
    DataManager.sharedInstance.profilePicture = thumbNail;
    
}

- (UIImage *)scaleImgOld:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    profilePictureChosen = YES;
    self.usernameInput.enabled = YES;
    return destImage;
}

-(IBAction)chooseProfilePicture:(id)sender
{
    
    UIActionSheet *filterActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Operation"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Choose from gallery", @"Take Photo", nil];
    
    [filterActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
     imgPicker.delegate = self;
     imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    switch (buttonIndex) {
        case 0:
            [self presentViewController:imgPicker animated:YES completion:nil];
            profilePictureChosen = YES;
            [self formValidation];
            
            self.variableLabel.text = @"UPDATE PHOTO";
            if(validUsername == YES)
            {
                self.btnCompleteProfile.enabled = YES;
                self.warningLabel.text = @"";
            }

            break;
        case 1:
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera])
            {
                imgPicker.sourceType =
                UIImagePickerControllerSourceTypeCamera;
                imgPicker.mediaTypes = @[(NSString *) kUTTypeImage];
                imgPicker.allowsEditing = YES;
                [self presentViewController:imgPicker
                                   animated:YES completion:nil];
                profilePictureChosen = YES;
                self.variableLabel.text = @"UPDATE PHOTO";
                [self formValidation];
                if(validUsername == YES)
                {
                    self.btnCompleteProfile.enabled = YES;
                    self.warningLabel.text = @"";
                }
            }

            break;
        default:
            break;
    }
}



-(IBAction)btnCompleteProfileTapped:(id)sender
{
    
    NSString * objectID = DataManager.sharedInstance.objectID;
    if(DataManager.sharedInstance.isFbUser == YES)
    {
        objectID = DataManager.sharedInstance.user.objectId;
    }
  
    [self startAnimation];
    PFQuery *query = [PFUser query];
    self.btnCompleteProfile.enabled = NO;
    [query getObjectInBackgroundWithId:objectID block:^(PFObject *username, NSError *error) {
        
        if(!error)
        {
            NSString * lowerCaseUsername =[self.usernameInput.text lowercaseString];
            NSString *trimmedUserName = [lowerCaseUsername stringByReplacingOccurrencesOfString:@" " withString:@""];
            DataManager.sharedInstance.myName = trimmedUserName;
            username[@"username"] = trimmedUserName;
            username[@"themeId"] = @"1";
            [[DataManager sharedInstance].defaults setObject:@"1" forKey:@"themeId"];
            if(DataManager.sharedInstance.isFbUser == YES)
            {
                [self getFacebookFriends];
            }
            
            if(DataManager.sharedInstance.isFbUser==NO)
            {
                PFObject * userRelation = [PFObject objectWithClassName:@"Social"];
                userRelation[@"user"] = username;
                NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
                userRelation[@"pendingRequests"] = emptyArray;
                userRelation[@"nativeFriendsIds"] = emptyArray;
                userRelation[@"blockedContacts"] = emptyArray;
                userRelation[@"fbFriendsIds"] = emptyArray;
                userRelation[@"sentRequests"] = emptyArray;
                [userRelation saveInBackgroundWithBlock:^(BOOL success, NSError * error)
                 {
                     NSLog(@"%@", userRelation);
                     if(error)
                     {
                         
                         NSLog(@"Error:%@", error);
                     }
                 }
                 ];

            }
            
            [username saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
                if (!error) {
                    NSString * lowerCaseUsername =[self.usernameInput.text lowercaseString];
                    NSString *trimmedUserName = [lowerCaseUsername stringByReplacingOccurrencesOfString:@" " withString:@""];
                    [PFUser currentUser].username = trimmedUserName;
                    [DataManager sharedInstance].myName = trimmedUserName;
                    if(DataManager.sharedInstance.isFbUser==NO)
                    {
                        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                        NSMutableArray * channels = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"individual-%@",[PFUser currentUser].objectId],[NSString stringWithFormat:@"group-%@", [PFUser currentUser].objectId], nil];
                        [currentInstallation setObject:[PFUser currentUser].objectId forKey:@"userId"];
                        [currentInstallation setObject:channels forKey:@"channels"];
                        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(!error)
                            {
                                NSLog(@"Installation Created");
                            }
                            else
                            {
                                NSLog(@"Error in installation: %@", error);
                            }
                            
                        }];
                    }
                    
                    PFQuery *query = [PFUser query];
                    PFUser *user = [PFUser currentUser];
                    
                    [query getObjectInBackgroundWithId:user.objectId block:^(PFObject *ProfilePicture, NSError *error) {
                        if(!error)
                        {
                            NSData *imageData1 = UIImagePNGRepresentation(DataManager.sharedInstance.profilePicture);
                            NSString *fileName = [NSString stringWithFormat:@"%@_iphone.png",[PFUser currentUser].objectId];
                            PFFile *imageFile = [PFFile fileWithName:fileName data:imageData1];
                            [ProfilePicture setObject:imageFile forKey:@"profilePicture"];

                            [ProfilePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                             {
                                 if(!error)
                                 {
                                     [self getThemeData:@"1"];
                                 }
                                 else
                                 {
                                     NSString *errorString = [[error userInfo] objectForKey:@"error"];
                                     UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                     [self stopAnimation];
                                     [errorAlertView show];
                                 }
                                 
                             }];
                        }
                        else
                        {
                            NSString *errorString = [[error userInfo] objectForKey:@"error"];
                            UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                            [self stopAnimation];
                            [errorAlertView show];
                        }
                    }];
                }
                else
                {
                    NSString *errorString = [[error userInfo] objectForKey:@"error"];
                    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [self stopAnimation];
                    [errorAlertView show];
                }
            }];
        }}];}

- (BOOL)prefersStatusBarHidden {
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

-(void) formValidation
{
    
    
    
    if(validUsername !=YES || profilePictureChosen!=YES)
    {
        self.btnCompleteProfile.enabled = NO;
    }
}

-(void) warningGenerator
{
    NSString *stricterFilterString = @"[A-Z0-9a-z]*";
    
    NSPredicate *usernameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    NSString *trimmedUserName = [self.usernameInput.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(self.usernameInput.text.length>2)
    {
        if(![usernameTest evaluateWithObject:trimmedUserName])
        {
           self.warningLabel.text = @"Please choose a valid username";
        }
        else if ([usernameTest evaluateWithObject:trimmedUserName])
        {
            validUsername = YES;
        }
    }
    else if(self.usernameInput.text.length<3)
    {
        self.warningLabel.text = @"Please choose a username of 3 characters at least";
    }
    if(profilePictureChosen!=YES && self.usernameInput.text.length>0 && validUsername==YES)
    {
        self.warningLabel.text = @"Please choose a profile picture";
    }

}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self warningGenerator];
    return YES;
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
    [self warningGenerator];
    if(validUsername == YES && profilePictureChosen == YES)
    {
        self.btnCompleteProfile.enabled = YES;
        self.warningLabel.text = @" ";
    }

    return YES;
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    validUsername = NO;
    self.warningLabel.text = @"";
    return YES;
}

-(void) dismissKeyboard
{
    [self.usernameInput resignFirstResponder];
}


-(UIImage *)scaleImage:(UIImage *)image {
    
    float width = 150;
    float height = 150;
    CGSize  newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
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
             
             PFQuery * query = [PFQuery queryWithClassName:@"Audio"];
             [query whereKey:@"theme" equalTo:object];
             DataManager.sharedInstance.themeAudios = [NSMutableArray arrayWithArray:[query findObjects]];
             if(DataManager.sharedInstance.isFbUser == YES)
             {
                 FBFindFriendsViewController * fbVC = [[FBFindFriendsViewController alloc] init];
                 DataManager.sharedInstance.isFirstFbLogin = YES;
                 [self.navigationController pushViewController:fbVC animated:YES];
             }
             else
             {
                 MainScreenViewController * frontViewController = [[MainScreenViewController alloc] init];
                 RearViewController *rearViewController = [[RearViewController alloc] init];
                 
                 SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:rearViewController frontViewController:frontViewController];
                 revealController.delegate = self;
                 revealController.rearViewRevealWidth = 101;
                 
                 [self stopAnimation];
                 [self.navigationController pushViewController:revealController animated:YES];
             }
             
             
             
         }
     }];
}


-(void)getFacebookFriends{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
            NSArray *friendObjects = result[DATA];
            DataManager.sharedInstance.myName = [PFUser currentUser].username;
            NSMutableArray * fbFriends = [NSMutableArray array];
            if (friendObjects.count>0) {
                
                NSMutableArray *allFBFriends = [NSMutableArray array];
                
                for (NSDictionary *friendObject in friendObjects) {
                    
                    NSString *facebookId = friendObject[UNIQUE_ID];
                    NSString *firstName  = friendObject[FIRST_NAME_A];
                    NSString *lastName   = friendObject[LAST_NAME_A];
                    [fbFriends addObject:facebookId];
                    NSMutableDictionary *fbFriendDict = [@{FACEBOOK_ID:facebookId,FIRST_NAME:firstName} mutableCopy];
                    if (lastName) {
                        fbFriendDict[LAST_NAME] = lastName;
                    }
                    [allFBFriends addObject:fbFriendDict];
                }
                NSLog(@"%@", allFBFriends);
                
                DataManager.sharedInstance.fbFriends = fbFriends;
                PFQuery * suggestionQuery = [PFUser query];
                [suggestionQuery whereKey:@"fbId" containedIn:DataManager.sharedInstance.fbFriends];
                DataManager.sharedInstance.suggestedFbFriends = [suggestionQuery findObjects];
                if([DataManager.sharedInstance.suggestedFbFriends count]>0)
                {
                    PFFile * resultProfilePicture = [[PFFile alloc] init];
                    UIImage * resultProfilePic;
                    for(PFUser * foundUser in DataManager.sharedInstance.suggestedFbFriends)
                    {
                        //Dont suggest friends who are already friends.
                        if([DataManager.sharedInstance.retrievedFriends containsObject:foundUser.objectId])
                            {
                                [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"1"];
                            }
                            else if([DataManager.sharedInstance.pendingFriendRequests containsObject:foundUser.objectId])
                            {
                                [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"4"];
                            }
                            else if(![DataManager.sharedInstance.retrievedFriends containsObject:foundUser.objectId] && ![DataManager.sharedInstance.pendingFriendRequests containsObject:foundUser.objectId])
                            {
                                [DataManager.sharedInstance.suggestedHideBtnFlags addObject:@"0"];
                            }

                            [DataManager.sharedInstance.suggestedFriendsEmails addObject:foundUser[@"email"]];
                            [DataManager.sharedInstance.suggestedFriendsUsernames addObject:foundUser[@"username"]];
                            resultProfilePicture = [foundUser objectForKey:@"profilePicture"];
                            if(resultProfilePicture!=nil)
                            {
                                NSData *imageData2 = [resultProfilePicture getData];
                                resultProfilePic = [UIImage imageWithData:imageData2];
                                [DataManager.sharedInstance.suggestedFriendsProfilePics addObject:resultProfilePic];
                            }
                            else
                            {
                                [DataManager.sharedInstance.suggestedFriendsProfilePics addObject:[UIImage imageNamed:@"dummyImage.png"]];
                            }
                            
                        }
                }
                
            }
            else {
                //                _failure(error);
            }
        }
        else {
            //            _failure(error);
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

@end
