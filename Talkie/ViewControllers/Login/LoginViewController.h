//
//  LoginForkViewController.h
//  Talkie
//
//  Created by sajjad mahmood on 19/11/2014.
//  Copyright (c) 2014 DynamicLogix. All rights reserved.
//


@interface LoginViewController : UIViewController 
{
    NSMutableArray * fbFriendIds;
    
    NSMutableArray * fbFriendsProfilePics;
    NSString *themeNumber;
    BOOL userFound;
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong) NSMutableArray *fbFriendsArray;
@property (weak, nonatomic) IBOutlet UIImageView *emojiImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end